import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:novel_ide/core/constants.dart';
import 'package:novel_ide/data/models/ai_config_model.dart';
import 'package:novel_ide/data/models/tomato_agent_model.dart';
import 'package:novel_ide/data/models/ai_chat_session_model.dart';
import 'package:novel_ide/data/models/proactive_question_model.dart';
import 'package:novel_ide/presentation/state/app_providers.dart';
import 'package:novel_ide/data/services/ai_service.dart';
import 'package:novel_ide/data/services/novel_memory.dart';
import 'package:novel_ide/data/services/user_memory.dart';
import 'package:novel_ide/data/services/workspace_agent.dart';
import 'package:novel_ide/data/services/agent_tool_executors.dart';
import 'package:novel_ide/data/services/workflow_engine.dart';
import 'package:novel_ide/data/services/voice_service.dart';
import 'package:novel_ide/data/services/skill_matcher.dart';
import 'package:novel_ide/data/services/fuzzy_need_detector.dart';
import 'package:novel_ide/data/models/writing_skill_model.dart';
import 'package:novel_ide/data/repositories/chat_history_repository.dart';
import 'package:novel_ide/presentation/pages/ai/voice_call_page.dart';
import 'package:novel_ide/presentation/widgets/top_notification.dart';
import 'package:novel_ide/presentation/widgets/skill_indicator.dart';
import 'package:novel_ide/presentation/widgets/proactive_question_dialog.dart';

/// AI 聊天会话模型
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

/// AI 对话页面 — ChatGPT 风格
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
  bool _showSidebar = false;
  bool _showModelDropdown = false;
  bool _showBottomSheet = false;
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
    if (mounted) setState(() {});
  }

  void _newSession() {
    final session = AiChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '新会话',
    );
    setState(() {
      _sessions.insert(0, session);
      _currentSession = session;
      _showSidebar = false;
      _skillMatches.clear();
    });
  }

  void _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    if (_currentSession == null) _newSession();

    final config = ref.read(selectedAiConfigProvider);
    if (config == null) {
      TopNotification.error(context, '请先在「我的」页面配置AI模型');
      return;
    }

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
      var systemPrompt = preset?.systemPrompt ?? '你是一个专业的网文写作助手，擅长帮助作者构思剧情、润色文字、生成大纲和角色设定。请用中文回复。';

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

  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(aiConfigsProvider);
    final selectedConfig = ref.watch(selectedAiConfigProvider);
    final messages = _currentSession?.messages ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 主聊天区域
          Column(
            children: [
              // 顶部栏
              _buildTopBar(),
              // 聊天区域
              Expanded(child: _buildChatView(messages)),
              // 输入区域
              _buildInputArea(),
            ],
          ),
          // 侧边栏
          _buildSidebar(),
          // 模型选择下拉
          if (_showModelDropdown) _buildModelDropdown(),
          // 底部菜单
          _buildBottomSheet(),
          // 遮罩层
          if (_showSidebar || _showModelDropdown || _showBottomSheet)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSidebar = false;
                  _showModelDropdown = false;
                  _showBottomSheet = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                setState(() => _showSidebar = !_showSidebar);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _showModelDropdown = !_showModelDropdown);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '网文写作IDE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F2F2F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedModel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, size: 14, color: Color(0xFFAAAAAA)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: _newSession,
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () {
                // TODO: 打开设置页面
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(List<Map<String, String>> messages) {
    if (messages.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.auto_awesome, size: 30, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '欢迎使用网文写作IDE！',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '我可以帮助你构思大纲、创建角色、润色文字、分析爽点分布。试试在下方输入框打字，或点击 + 探索更多功能。',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFAAAAAA),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _QuickAction(
              icon: '📚',
              label: '帮我构思剧情',
              onTap: () {
                _inputCtrl.text = '帮我构思一个有趣的剧情';
                _sendMessage();
              },
            ),
            const SizedBox(height: 12),
            _QuickAction(
              icon: '🎯',
              label: '生成小说大纲',
              onTap: () {
                _inputCtrl.text = '帮我写一个小说大纲';
                _sendMessage();
              },
            ),
            const SizedBox(height: 12),
            _QuickAction(
              icon: '👤',
              label: '设计主角设定',
              onTap: () {
                _inputCtrl.text = '帮我设计一个有意思的主角';
                _sendMessage();
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, size: 16, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    ...List.generate(3, (i) => AnimatedContainer(
                      duration: Duration(milliseconds: 150 * i + 150),
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF666666),
                        shape: BoxShape.circle,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          );
        }
        final msg = messages[index];
        final isUser = msg['role'] == 'user';
        final matchedForThis = _skillMatches[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, size: 16, color: Colors.black),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (matchedForThis != null && matchedForThis.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: SkillIndicator(matchedSkills: matchedForThis),
                      ),
                    Container(
                      padding: isUser
                          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                          : const EdgeInsets.symmetric(vertical: 4),
                      decoration: isUser
                          ? BoxDecoration(
                              color: const Color(0xFF2F2F2F),
                              borderRadius: BorderRadius.circular(20),
                            )
                          : null,
                      child: Text(
                        msg['content']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 12),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10A37F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 16, color: Colors.white),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(1),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2F2F2F),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: Color(0xFFAAAAAA), size: 28),
                onPressed: () {
                  setState(() => _showBottomSheet = true);
                },
              ),
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    hintStyle: TextStyle(color: Color(0xFF888888)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              if (_inputCtrl.text.trim().isEmpty)
                IconButton(
                  icon: const Icon(Icons.mic_none, color: Colors.white),
                  onPressed: () {
                    // TODO: 语音输入
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 4),
                  child: InkWell(
                    onTap: _sendMessage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, size: 18, color: Colors.black),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final novels = ref.watch(novelsProvider).valueOrNull ?? [];
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      left: _showSidebar ? 0 : -300,
      top: 0,
      bottom: 0,
      width: 300,
      child: Container(
        color: const Color(0xFF171717),
        child: SafeArea(
          child: Column(
            children: [
              // 头部
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _newSession,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF333333)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '+ 新会话',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 历史会话
              if (_sessions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    '历史会话',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                ...List.generate(_sessions.length, (index) {
                  final session = _sessions[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      session.title,
                      style: const TextStyle(
                        color: Color(0xFFDDDDDD),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${session.createdAt.hour}:${session.createdAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _currentSession = session;
                        _showSidebar = false;
                        _skillMatches.clear();
                      });
                    },
                  );
                }),
              ],
              // 作品
              if (novels.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    '作品',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                ...List.generate(novels.length, (index) {
                  final novel = novels[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      '📚 ${novel.title}',
                      style: const TextStyle(
                        color: Color(0xFFDDDDDD),
                        fontSize: 13,
                      ),
                    ),
                    trailing: const Text(
                      '3卷15章',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                    onTap: () {
                      ref.read(selectedNovelProvider.notifier).state = novel;
                      setState(() => _showSidebar = false);
                    },
                  );
                }),
              ],
              // 资料库
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  '资料库',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              ListTile(
                dense: true,
                title: Text(
                  '👤 角色',
                  style: const TextStyle(
                    color: Color(0xFFDDDDDD),
                    fontSize: 13,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () {
                    // TODO: 打开角色关系图
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '🤝 关系图',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF10A37F),
                    ),
                  ),
                ),
              ),
              ListTile(
                dense: true,
                title: Text(
                  '⚙️ 设定',
                  style: const TextStyle(
                    color: Color(0xFFDDDDDD),
                    fontSize: 13,
                  ),
                ),
              ),
              ListTile(
                dense: true,
                title: Text(
                  '💡 伏笔',
                  style: const TextStyle(
                    color: Color(0xFFDDDDDD),
                    fontSize: 13,
                  ),
                ),
              ),
              ListTile(
                dense: true,
                title: Text(
                  '🏛 势力',
                  style: const TextStyle(
                    color: Color(0xFFDDDDDD),
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              // 底部操作
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: 导出
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF333333)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '📤 导出',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: 导入
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF333333)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '📥 导入',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelDropdown() {
    return Positioned(
      top: 80,
      left: 50,
      right: 50,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: const Color(0xFF333333)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...[
              'GLM-4.7-Flash',
              'GLM-4.6V-Flash',
              'GLM-4.1V-Thinking',
            ].map((model) => ListTile(
                  dense: true,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          model,
                          style: TextStyle(
                            color: model == _selectedModel ? Colors.white : const Color(0xFFDDDDDD),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (model == 'GLM-4.7-Flash')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A2A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '内置免费',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF10A37F),
                            ),
                          ),
                        ),
                      if (model == _selectedModel)
                        const Icon(Icons.check, color: Color(0xFF10A37F)),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedModel = model;
                      _showModelDropdown = false;
                    });
                  },
                )),
            const Divider(height: 1, color: Color(0xFF333333)),
            ...[
              'GPT-4o',
              'Claude Sonnet',
              'DeepSeek V3',
              '本地 Ollama',
            ].map((model) => ListTile(
                  dense: true,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          model,
                          style: TextStyle(
                            color: model == _selectedModel ? Colors.white : const Color(0xFFDDDDDD),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (model == _selectedModel)
                        const Icon(Icons.check, color: Color(0xFF10A37F)),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedModel = model;
                      _showModelDropdown = false;
                    });
                  },
                )),
            const Divider(height: 1, color: Color(0xFF333333)),
            ListTile(
              dense: true,
              title: const Text(
                '⚙ 管理模型',
                style: TextStyle(
                  color: Color(0xFF10A37F),
                  fontSize: 13,
                ),
              ),
              onTap: () {
                setState(() => _showModelDropdown = false);
                // TODO: 打开模型管理
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    final agents = ref.read(tomatoAgentsProvider);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      left: 0,
      right: 0,
      bottom: _showBottomSheet ? 0 : -600,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽把手
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 14, bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF444444),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              // 快捷操作网格
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _BottomSheetItem(
                      icon: '🎙',
                      label: '语音输入',
                      subtitle: '语音转文字',
                      onTap: () {
                        setState(() => _showBottomSheet = false);
                      },
                    ),
                    _BottomSheetItem(
                      icon: '📎',
                      label: '上传文件',
                      subtitle: 'TXT/DOCX/PDF',
                      onTap: () {
                        setState(() => _showBottomSheet = false);
                        _pickFile();
                      },
                    ),
                    _BottomSheetItem(
                      icon: '📚',
                      label: '选择资料',
                      subtitle: '发给AI上下文',
                      onTap: () {
                        setState(() => _showBottomSheet = false);
                        _showMaterialPicker();
                      },
                    ),
                    _BottomSheetItem(
                      icon: '📋',
                      label: '选择模板',
                      subtitle: '写作模板库',
                      onTap: () {
                        setState(() => _showBottomSheet = false);
                      },
                    ),
                    _BottomSheetItem(
                      icon: '🍅',
                      label: '番茄写作',
                      subtitle: '风格预设',
                      onTap: () {
                        setState(() => _showBottomSheet = false);
                      },
                    ),
                    _BottomSheetItem(
                      icon: '💬',
                      label: '语音通话',
                      subtitle: '实时AI对话',
                      onTap: () {
                        setState(() => _showBottomSheet = false);
                        _openVoiceCall();
                      },
                    ),
                    _BottomSheetItem(
                      icon: '📊',
                      label: '写作统计',
                      subtitle: '字数趋势',
                      onTap: () {
                        setState(() => _showBottomSheet = false);
                      },
                    ),
                    _BottomSheetItem(
                      icon: '⚙',
                      label: '更多设置',
                      subtitle: '模型/外观/数据',
                      onTap: () {
                        setState(() => _showBottomSheet = false);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Agent网格
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🤖 Agent（智能体）',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: agents.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final agent = agents[index];
                          return _AgentCard(
                            name: agent.name,
                            desc: agent.description,
                            icon: agent.icon,
                            onTap: () {
                              setState(() => _showBottomSheet = false);
                              _invokeAgent(agent);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 选择文件
  void _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        // TODO: 处理文件
      }
    } catch (e) {
      debugPrint('File pick error: $e');
    }
  }

  /// 显示资料选择器
  void _showMaterialPicker() {
    final novel = ref.read(selectedNovelProvider);
    if (novel == null) {
      TopNotification.error(context, '请先选择一部小说');
      return;
    }
    // TODO: 显示资料选择器
  }

  /// 调用Agent
  Future<void> _invokeAgent(TomatoAgent agent) async {
    final config = ref.read(selectedAiConfigProvider);
    if (config == null) {
      TopNotification.error(context, '请先在「我的」页面配置AI模型');
      return;
    }

    if (_currentSession == null) _newSession();

    final userMessage = '请执行「${agent.name}」任务';
    setState(() {
      _currentSession!.messages.add({
        'role': 'user',
        content: '⚡ ${agent.name}\n$userMessage',
      });
      if (_currentSession!.messages.length == 1) {
        _currentSession!.title = agent.name;
      }
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final recentMsgs = _currentSession!.messages
          .where((m) => m != _currentSession!.messages.last)
          .toList();
      final contextMsgs = recentMsgs.length > 20
          ? recentMsgs.sublist(recentMsgs.length - 20)
          : recentMsgs;

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

      final aiService = ref.read(aiServiceProvider);

      final messages = <Map<String, String>>[
        {'role': 'system', 'content': '${agent.systemPrompt}\n$memoryContext$userMemoryContext'},
        ...contextMsgs.map((m) => {'role': m['role']!, 'content': m['content']!}),
        {'role': 'user', 'content': userMessage},
      ];

      final aiText = await aiService.chat(config, messages, taskType: 'agent');

      setState(() {
        _currentSession!.messages.add({
          'role': 'assistant',
          content: '【${agent.name}】\n$aiText',
        });
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _currentSession!.messages.add({
          'role': 'assistant',
          content: '【${agent.name}】调用失败: $e',
        });
        _isLoading = false;
      });
    }
  }

  /// 打开语音通话
  void _openVoiceCall() async {
    final voiceConfig = ref.read(selectedVoiceConfigProvider);
    if (voiceConfig == null) {
      TopNotification.error(context, '请先在设置中配置语音模型');
      return;
    }
    final config = ref.read(selectedAiConfigProvider);
    if (config == null) {
      TopNotification.error(context, '请先配置文本AI模型');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceCallPage(
          onCallEnd: (transcript, aiResponse) {
            if (_currentSession == null) _newSession();
            if (transcript.isNotEmpty) {
              setState(() {
                _currentSession!.messages.add({'role': 'user', 'content': '🎤 语音通话记录：\n$transcript'});
              });
            }
            if (aiResponse.isNotEmpty) {
              setState(() {
                _currentSession!.messages.add({'role': 'assistant', 'content': '🤖 AI回复：\n$aiResponse'});
              });
            }
          },
        ),
      ),
    );
    _scrollToBottom();
  }
}

/// 快捷操作组件
class _QuickAction extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF333333)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部菜单项
class _BottomSheetItem extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _BottomSheetItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFDDDDDD),
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Agent卡片
class _AgentCard extends StatelessWidget {
  final String name;
  final String desc;
  final String icon;
  final VoidCallback onTap;

  const _AgentCard({
    required this.name,
    required this.desc,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          border: Border.all(color: const Color(0xFF333333)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
