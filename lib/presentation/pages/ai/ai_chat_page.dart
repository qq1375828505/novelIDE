import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:novel_ide/data/models/ai_config_model.dart';
import 'package:novel_ide/data/models/tomato_agent_model.dart';
import 'package:novel_ide/data/models/ai_chat_session_model.dart';
import 'package:novel_ide/data/models/proactive_question_model.dart';
import 'package:novel_ide/data/models/writing_skill_model.dart';
import 'package:novel_ide/data/models/tomato_preset_model.dart';
import 'package:novel_ide/presentation/state/app_providers.dart';
import 'package:novel_ide/data/services/ai_service.dart';
import 'package:novel_ide/data/services/novel_memory.dart';
import 'package:novel_ide/data/services/user_memory.dart';
import 'package:novel_ide/data/services/workspace_agent.dart';
import 'package:novel_ide/data/services/agent_tool_executors.dart';
import 'package:novel_ide/data/services/voice_service.dart';
import 'package:novel_ide/data/services/skill_matcher.dart';
import 'package:novel_ide/data/services/fuzzy_need_detector.dart';
import 'package:novel_ide/data/repositories/chat_history_repository.dart';
import 'package:novel_ide/presentation/pages/ai/voice_call_page.dart';
import 'package:novel_ide/presentation/pages/ai/full_text_review_page.dart';
import 'package:novel_ide/presentation/pages/ai/polish_engine_page.dart';
import 'package:novel_ide/presentation/pages/writing/proofread_page.dart';
import 'package:novel_ide/presentation/pages/stats/stats_page.dart';
import 'package:novel_ide/presentation/pages/profile/profile_page.dart';
import 'package:novel_ide/presentation/pages/tomato/agent_marketplace_page.dart';
import 'package:novel_ide/presentation/widgets/top_notification.dart';
import 'package:novel_ide/presentation/widgets/skill_indicator.dart';
import 'package:novel_ide/presentation/widgets/proactive_question_dialog.dart';

/// AI chat session model.
class AiChatSession {
  final String id;
  String title;
  List<Map<String, String>> messages;
  final DateTime createdAt;

  AiChatSession({
    required this.id,
    required this.title,
    List<Map<String, String>>? messages,
    DateTime? createdAt,
  })  : messages = messages != null ? List.from(messages) : [],
        createdAt = createdAt ?? DateTime.now();
}

/// GPT风格聊天页面 - 纯聊天消息列表 + 底部胶囊式输入框
class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> with WidgetsBindingObserver {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<AiChatSession> _sessions = [];
  AiChatSession? _currentSession;
  bool _isLoading = false;
  String _selectedModel = 'GLM-4.7-Flash';

  // 语音相关
  final VoiceService _voiceService = VoiceService();

  // 技能匹配记录：assistant消息索引 → 匹配到的技能列表
  final Map<int, List<WritingSkill>> _skillMatches = {};

  // 历史记录仓库
  final ChatHistoryRepository _historyRepo = ChatHistoryRepository();
  bool _isHistoryLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initVoice();
    _loadHistory();
    
    // 监听新建会话触发器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<int>(newSessionTriggerProvider, (previous, next) {
        if (next != previous && next > 0) {
          _newSession();
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _saveHistory();
    }
  }

  Future<void> _loadHistory() async {
    try {
      final savedSessions = await _historyRepo.loadSessions();
      if (savedSessions.isNotEmpty && mounted) {
        setState(() {
          _sessions.clear();
          for (final model in savedSessions) {
            _sessions.add(AiChatSession(
              id: model.id,
              title: model.title,
              messages: model.messages,
              createdAt: model.createdAt,
            ));
          }
          _currentSession = _sessions.first;
        });
      }
      _isHistoryLoaded = true;
    } catch (e) {
      debugPrint('Load history error: $e');
      _isHistoryLoaded = true;
    }
  }

  Future<void> _saveHistory() async {
    if (!_isHistoryLoaded) return;
    try {
      final models = _sessions.map((s) => AiChatSessionModel(
        id: s.id,
        title: s.title,
        messages: s.messages,
        createdAt: s.createdAt,
        updatedAt: DateTime.now(),
      )).toList();
      await _historyRepo.saveSessions(models);
    } catch (e) {
      debugPrint('Save history error: $e');
    }
  }

  Future<void> _initVoice() async {
    await _voiceService.init();
    if (mounted) setState(() {});
  }

  void _newSession() {
    final session = AiChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '新会话 ${_sessions.length + 1}',
    );
    setState(() {
      _sessions.insert(0, session);
      _currentSession = session;
      _skillMatches.clear();
    });
  }

  void _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    if (_currentSession == null) _newSession();

    final config = ref.read(effectiveAiConfigProvider);
    if (config == null) {
      TopNotification.error(context, '请先配置AI模型');
      return;
    }

    // 模糊需求检测
    final detector = FuzzyNeedDetector();
    final fuzzyType = await detector.detect(
      text,
      config: config,
      userMemory: await UserMemory.load().catchError((_) => ''),
      novelContext: ref.read(selectedNovelProvider) != null
          ? await NovelMemory.getForAiContext(
              ref.read(selectedNovelProvider)!.id,
              ref.read(selectedNovelProvider)!.title,
            ).catchError((_) => '')
          : null,
    );
    
    if (fuzzyType != null) {
      List<WritingSkill>? skills;
      try {
        final skillRepo = ref.read(skillRepoProvider);
        skills = await skillRepo.getAllSkills();
      } catch (_) {}

      final question = await detector.generateQuestion(
        text,
        fuzzyType,
        config: config,
        userMemory: await UserMemory.load().catchError((_) => ''),
        novelContext: ref.read(selectedNovelProvider) != null
            ? await NovelMemory.getForAiContext(
                ref.read(selectedNovelProvider)!.id,
                ref.read(selectedNovelProvider)!.title,
              ).catchError((_) => '')
            : null,
        availableSkills: skills,
      );

      if (question != null && mounted) {
        ProactiveSelection? selection;
        await ProactiveQuestionDialog.show(
          context,
          question: question,
          onSelected: (s) => selection = s,
          onSkipped: () => selection = null,
        );

        if (selection != null) {
          _inputCtrl.text = '$text\n\n[用户选择：${selection!.toAiContext()}]';
        }
      }
    }

    final shouldTriggerAgent = detector.shouldTriggerWorkspaceAgent(text);

    setState(() {
      _currentSession!.messages.add({'role': 'user', 'content': _inputCtrl.text.trim()});
      if (_currentSession!.messages.length == 1) {
        _currentSession!.title = text.length > 20 ? '${text.substring(0, 20)}...' : text;
      }
      _isLoading = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    try {
      final preset = ref.read(currentPresetProvider);
      var systemPrompt = preset?.systemPrompt ?? '你是一位专业的网文写作助手，擅长帮助作者构思剧情、润色文字、生成大纲和角色设定。请用中文回复。';

      List<WritingSkill> matchedSkills = [];
      try {
        final skillRepo = ref.read(skillRepoProvider);
        final allSkills = await skillRepo.getAllSkills();
        final enabled = allSkills.where((s) => s.isEnabled).toList();
        matchedSkills = SkillMatcher.match(text, enabled);
        if (matchedSkills.isNotEmpty) {
          systemPrompt = SkillMatcher.injectSkillContext(systemPrompt, matchedSkills);
        }
      } catch (_) {}

      String memoryContext = '';
      try {
        final novel = ref.read(selectedNovelProvider);
        if (novel != null) {
          memoryContext = await NovelMemory.getForAiContext(novel.id, novel.title);
        }
      } catch (_) {}

      String userMemoryContext = '';
      try {
        userMemoryContext = await UserMemory.getForAiContext();
      } catch (_) {}

      if (_currentSession!.messages.length > 600) {
        await _compactMessages(config);
      }

      final novel = ref.read(selectedNovelProvider);
      final needsAgent = shouldTriggerAgent;

      if (needsAgent) {
        final agent = WorkspaceAgent();
        if (novel != null) {
          registerAllToolExecutors(agent: agent, novelId: novel.id, novelTitle: novel.title);
        } else {
          registerGeneralToolExecutors(
            agent: agent,
            onSwitchNovel: (id) {
              final novels = ref.read(novelsProvider).valueOrNull ?? [];
              final novel = novels.where((n) => n.id == id).firstOrNull;
              if (novel != null) {
                ref.read(selectedNovelProvider.notifier).state = novel;
                loadNovelMaterials(ref, id);
              }
            },
          );
        }

        final effectiveSystemPrompt = novel != null
            ? '$systemPrompt\n\n小说记忆文件（当前状态）：\n$memoryContext$userMemoryContext'
            : '$systemPrompt\n\n$userMemoryContext';

        final response = await agent.chat(
          config: config,
          messages: _currentSession!.messages,
          systemPrompt: effectiveSystemPrompt,
        );

        final buffer = StringBuffer();
        if (response.toolResults.isNotEmpty) {
          buffer.writeln('🔧 **工具调用：**\n');
          for (final result in response.toolResults) {
            final icon = result.success ? '✅' : '❌';
            buffer.writeln('$icon ${result.toolName}：${result.message}');
          }
          buffer.writeln('\n---\n');
        }
        buffer.write(response.content);

        setState(() {
          _currentSession!.messages.add({'role': 'assistant', 'content': buffer.toString()});
          if (matchedSkills.isNotEmpty) {
            _skillMatches[_currentSession!.messages.length - 1] = matchedSkills;
          }
          _isLoading = false;
        });
      } else {
        final agent = WorkspaceAgent();
        final aiText = await agent.chatLite(
          config: config,
          messages: _currentSession!.messages,
          systemPrompt: '$systemPrompt\n\n$userMemoryContext',
        );

        setState(() {
          _currentSession!.messages.add({'role': 'assistant', 'content': aiText});
          if (matchedSkills.isNotEmpty) {
            _skillMatches[_currentSession!.messages.length - 1] = matchedSkills;
          }
          _isLoading = false;
        });
      }
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _currentSession!.messages.add({'role': 'assistant', 'content': '请求失败: $e'});
        _isLoading = false;
      });
    }
  }

  Future<void> _compactMessages(AiConfig config) async {
    try {
      final msgs = _currentSession!.messages;
      final toSummarize = msgs.take(30).map((m) => '${m['role']}: ${m['content']}').join('\n');
      final aiService = ref.read(aiServiceProvider);
      final summary = await aiService.send(
        config: config,
        systemPrompt: '你是一个对话摘要助手。请将以下对话压缩为简短的摘要（200字以内），保留关键信息和上下文。',
        userMessage: toSummarize,
        taskType: 'chat',
      );
      setState(() {
        _currentSession!.messages = [
          {'role': 'user', 'content': '以下是之前的对话摘要，请据此回复用户后续的问题：\n$summary'},
          ...msgs.skip(30),
        ];
      });
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveHistory();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  // GPT风格颜色
  static const bgColor = Color(0xFF000000);
  static const cardBg = Color(0xFF1A1A1A);
  static const cardBg2 = Color(0xFF2A2A2A);
  static const primaryColor = Color(0xFF10A37F);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF888888);
  static const textTertiary = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final messages = _currentSession?.messages ?? [];

    return Container(
      color: bgColor,
      child: Column(
        children: [
          // 聊天消息列表
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return _buildTypingIndicator();
                      }
                      final msg = messages[index];
                      final isUser = msg['role'] == 'user';
                      final matchedForThis = _skillMatches[index];
                      return _buildMessage(msg['content']!, isUser, matchedForThis, index);
                    },
                  ),
          ),
          // 底部胶囊式输入框
          _buildInputBar(),
        ],
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI头像
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: textPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text('AI', style: TextStyle(color: bgColor, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '欢迎使用网文写作IDE！',
              style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '我可以帮助你构思大纲、创建角色、润色文字、分析爽点分布。',
              style: TextStyle(color: textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // 快捷操作
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickChip('构思剧情', () => _quickSend('帮我构思一个有趣的剧情')),
                _buildQuickChip('起个书名', () => _quickSend('帮我起5个吸引人的书名')),
                _buildQuickChip('设计角色', () => _quickSend('帮我设计一个有意思的主角')),
                _buildQuickChip('生成大纲', () => _quickSend('帮我写一个小说大纲')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: cardBg2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: TextStyle(color: textPrimary, fontSize: 13)),
      ),
    );
  }

  void _quickSend(String text) {
    _inputCtrl.text = text;
    _sendMessage();
  }

  /// 消息气泡
  Widget _buildMessage(String content, bool isUser, List<WritingSkill>? skills, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (skills != null && skills.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 44),
            child: SkillIndicator(matchedSkills: skills),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isUser ? primaryColor : textPrimary,
                  borderRadius: BorderRadius.circular(isUser ? 14 : 4),
                ),
                child: Center(
                  child: Icon(
                    isUser ? Icons.person : Icons.smart_toy,
                    color: isUser ? textPrimary : bgColor,
                    size: 16,
                  ),
                ),
              ),
              // 内容
              Expanded(
                child: GestureDetector(
                  onLongPress: () => _showMessageMenu(content, index),
                  child: isUser
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: cardBg2,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            content,
                            style: TextStyle(color: textPrimary, fontSize: 15, height: 1.6),
                          ),
                        )
                      : SelectableText(
                          content,
                          style: TextStyle(color: textPrimary, fontSize: 15, height: 1.6),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 加载中指示器
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: textPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text('AI', style: TextStyle(color: bgColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => 
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: textTertiary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 底部胶囊式输入框
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, bgColor],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg2,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // + 按钮
            IconButton(
              icon: Icon(Icons.add, color: textSecondary, size: 22),
              onPressed: _showBottomSheet,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            // 输入框
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                maxLines: null,
                minLines: 1,
                style: TextStyle(color: textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: TextStyle(color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            // 发送/语音按钮
            _inputCtrl.text.isNotEmpty
                ? Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: textPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: bgColor, size: 18),
                      onPressed: _isLoading ? null : _sendMessage,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  )
                : Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.mic, color: textPrimary, size: 18),
                      onPressed: _handleMic,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  /// 显示底部弹窗菜单
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示条
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF444444),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 功能网格
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.0,
                  children: [
                    _buildSheetItem(Icons.mic, '语音输入', '语音转文字', () {
                      Navigator.pop(ctx);
                      _handleMic();
                    }),
                    _buildSheetItem(Icons.attach_file, '上传文件', 'TXT/DOCX/PDF', () {
                      Navigator.pop(ctx);
                      _handleFileUpload();
                    }),
                    _buildSheetItem(Icons.library_books, '选择资料', '发给AI上下文', () { Navigator.pop(ctx); _showMaterialPicker(); }),
                    _buildSheetItem(Icons.description, '选择模板', '写作模板库', () {
                      Navigator.pop(ctx);
                      _showWritingTemplates();
                    }),
                    _buildSheetItem(Icons.local_fire_department, '番茄写作', '风格预设', () {
                      Navigator.pop(ctx);
                      _showTomatoPresetPicker();
                    }),
                    _buildSheetItem(Icons.phone, '语音通话', '实时AI对话', () { Navigator.pop(ctx); _openVoiceCall(); }),
                    _buildSheetItem(Icons.bar_chart, '写作统计', '字数趋势', () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsPage()));
                    }),
                    _buildSheetItem(Icons.settings, '更多设置', '模型/外观/数据', () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                    }),
                    _buildSheetItem(Icons.fact_check, '全文审查', '设定/角色/逻辑', () {
                      Navigator.pop(ctx);
                      _navigateToFullTextReview();
                    }),
                    _buildSheetItem(Icons.auto_fix_high, '润色引擎', '章节精修', () {
                      Navigator.pop(ctx);
                      _navigateToPolishEngine();
                    }),
                    _buildSheetItem(Icons.spellcheck, '校对', '错别字/标点', () {
                      Navigator.pop(ctx);
                      _navigateToProofread();
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Agent列表
              _buildAgentSection(ctx),
              // Skill列表
              _buildSkillSection(ctx),
              // 番茄写作
              _buildTomatoSection(ctx),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理文件上传
  Future<void> _handleFileUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'docx', 'pdf'],
      );
      
      if (result == null || result.files.isEmpty) return;
      
      final filePath = result.files.first.path;
      if (filePath == null) return;
      
      final file = File(filePath);
      if (!await file.exists()) return;
      
      // 读取文件内容
      String content = '';
      final ext = filePath.split('.').last.toLowerCase();
      
      if (ext == 'txt' || ext == 'md') {
        content = await file.readAsString();
      } else {
        // 对于 docx/pdf，暂时只显示文件名
        TopNotification.show(context, '暂不支持该格式，请使用TXT文件');
        return;
      }
      
      if (content.length > 5000) {
        content = content.substring(0, 5000) + '\n...(内容过长已截断)';
      }
      
      // 将文件内容插入输入框
      setState(() {
        _inputCtrl.text = '[上传文件：${result.files.first.name}]\n\n$content\n\n请帮我分析以上内容。';
      });
      
      TopNotification.success(context, '已读取文件：${result.files.first.name}');
    } catch (e) {
      TopNotification.error(context, '读取文件失败: $e');
    }
  }

  Widget _buildSheetItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textPrimary, size: 24),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(color: textPrimary, fontSize: 13)),
            Text(subtitle, style: TextStyle(color: textTertiary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentSection(BuildContext ctx) {
    final agents = ref.watch(tomatoAgentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('Agent（智能体）', style: TextStyle(color: textSecondary, fontSize: 12)),
        ),
        SizedBox(
          height: 90,
          child: agents.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('暂无Agent', style: TextStyle(color: textTertiary, fontSize: 12)),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: agents.length + 1,
                  itemBuilder: (context, index) {
                    // 最后一项：更多Agent按钮
                    if (index == agents.length) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentMarketplacePage()));
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cardBg2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF333333)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.storefront, color: primaryColor, size: 20),
                              const SizedBox(height: 6),
                              Text('更多', style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }
                    final agent = agents[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _invokeAgent(agent);
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBg2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF333333)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(agent.icon, style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 6),
                            Text(agent.name, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(agent.description, style: TextStyle(color: textTertiary, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSkillSection(BuildContext ctx) {
    final skills = ref.watch(writingSkillsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('Skill（写作技巧）', style: TextStyle(color: textSecondary, fontSize: 12)),
        ),
        SizedBox(
          height: 90,
          child: skills.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('暂无写作技巧', style: TextStyle(color: textTertiary, fontSize: 12)),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: skills.length + 1,
                  itemBuilder: (context, index) {
                    // 最后一项：更多技巧按钮
                    if (index == skills.length) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillManagePage()));
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cardBg2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF333333)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: primaryColor, size: 20),
                              const SizedBox(height: 6),
                              Text('更多', style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }
                    final skill = skills[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _useSkill(skill);
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBg2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF333333)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.build, color: primaryColor, size: 20),
                            const SizedBox(height: 6),
                            Text(skill.name, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(skill.description ?? '', style: TextStyle(color: textTertiary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTomatoSection(BuildContext ctx) {
    final presets = ref.watch(tomatoPresetsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('番茄写作', style: TextStyle(color: textSecondary, fontSize: 12)),
        ),
        SizedBox(
          height: 90,
          child: presets.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('暂无番茄写作预设', style: TextStyle(color: textTertiary, fontSize: 12)),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: presets.length + 1,
                  itemBuilder: (context, index) {
                    // 最后一项：更多预设按钮
                    if (index == presets.length) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const StyleSelectorBar()));
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cardBg2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF333333)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: primaryColor, size: 20),
                              const SizedBox(height: 6),
                              Text('更多', style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }
                    final preset = presets[index];
                    final isApplied = ref.watch(currentPresetProvider)?.id == preset.id;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _applyPreset(preset);
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBg2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isApplied ? primaryColor : const Color(0xFF333333)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(preset.icon, style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 6),
                            Text(preset.name, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(preset.description, style: TextStyle(color: textTertiary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (isApplied)
                              Icon(Icons.check_circle, color: primaryColor, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _invokeAgent(TomatoAgent agent) {
    _inputCtrl.text = '请使用 ${agent.name} agent 帮我完成任务';
    _sendMessage();
  }

  void _useSkill(WritingSkill skill) {
    _inputCtrl.text = '请使用 ${skill.name} 技巧帮我完成写作任务';
    _sendMessage();
  }

  void _applyPreset(TomatoPreset preset) {
    ref.read(currentPresetProvider.notifier).state = preset;
    TopNotification.success(context, '已应用预设：${preset.name}');
  }

  void _openVoiceCall() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceCallPage()));
  }

  void _handleMic() async {
    if (_voiceService.isListening) {
      _voiceService.stop();
    } else {
      await _voiceService.start();
      if (mounted) setState(() {});
    }
  }

  void _showMaterialPicker() {
    // 实现资料选择器
  }

  void _showWritingTemplates() {
    // 实现写作模板选择器
  }

  void _showTomatoPresetPicker() {
    // 实现番茄写作预设选择器
  }

  void _navigateToFullTextReview() {
    final novel = ref.read(selectedNovelProvider);
    if (novel != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => FullTextReviewPage(novelId: novel.id)));
    }
  }

  void _navigateToPolishEngine() {
    final novel = ref.read(selectedNovelProvider);
    if (novel != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PolishEnginePage(novelId: novel.id)));
    }
  }

  void _navigateToProofread() {
    final novel = ref.read(selectedNovelProvider);
    if (novel != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProofreadPage(novelId: novel.id)));
    }
  }

  void _showMessageMenu(String content, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(color: const Color(0xFF444444), borderRadius: BorderRadius.circular(2)),
              ),
              ListTile(
                leading: Icon(Icons.copy, color: textPrimary),
                title: Text('复制', style: TextStyle(color: textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _copyMessage(content);
                },
              ),
              ListTile(
                leading: Icon(Icons.refresh, color: textPrimary),
                title: Text('重新生成', style: TextStyle(color: textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _regenerateMessage(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('撤回消息', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteMessage(index);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    TopNotification.success(context, '已复制到剪贴板');
  }

  void _regenerateMessage(int index) {
    if (index < _currentSession!.messages.length - 1) {
      final lastUserIndex = _currentSession!.messages.lastIndexWhere((m) => m['role'] == 'user', index - 1);
      if (lastUserIndex >= 0) {
        _inputCtrl.text = _currentSession!.messages[lastUserIndex]['content']!;
        _sendMessage();
      }
    }
  }

  void _deleteMessage(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        title: Text('撤回消息', style: TextStyle(color: textPrimary)),
        content: Text('确定要撤回这条消息吗？', style: TextStyle(color: textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentSession!.messages.removeAt(index);
                _skillMatches.remove(index);
              });
            },
            child: Text('撤回'),
          ),
        ],
      ),
    );
  }
}