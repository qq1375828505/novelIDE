import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_ide/presentation/state/app_providers.dart';
import 'package:novel_ide/presentation/pages/ai/ai_chat_page.dart';
import 'package:novel_ide/presentation/pages/profile/profile_page.dart';
import 'package:novel_ide/data/models/novel_model.dart';
import 'package:novel_ide/data/models/chapter_model.dart';
import 'package:novel_ide/data/models/volume_model.dart';
import 'package:novel_ide/data/repositories/volume_repository.dart';
import 'package:novel_ide/data/repositories/chapter_repository.dart';
import 'package:novel_ide/presentation/pages/writing/editor_page.dart';

/// GPT风格单页面聊天应用
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _sidebarOpen = false;
  bool _modelDropdownOpen = false;
  
  // 作品树展开状态
  final Set<String> _expandedNovels = {};
  final Set<String> _expandedVolumes = {};
  final Map<String, List<Volume>> _loadedVolumes = {};
  final Map<String, List<Chapter>> _loadedChapters = {};
  
  // 模型列表
  static const List<_ModelItem> _models = [
    _ModelItem('GLM-4.7-Flash', '内置免费', isFree: true),
    _ModelItem('GLM-4.6V-Flash', '多模态', isFree: true),
    _ModelItem('GLM-4.1V-Thinking', '思考版', isFree: true),
    _ModelItem('GPT-4o', null),
    _ModelItem('Claude Sonnet', null),
    _ModelItem('DeepSeek V3', null),
    _ModelItem('本地 Ollama', null),
  ];
  
  String _selectedModel = 'GLM-4.7-Flash';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final novels = ref.watch(novelsProvider).valueOrNull ?? [];
    final selectedNovel = ref.watch(selectedNovelProvider);
    
    // GPT风格颜色
    const bgColor = Color(0xFF000000);
    const sidebarBg = Color(0xFF171717);
    const cardBg = Color(0xFF1A1A1A);
    const cardBg2 = Color(0xFF2A2A2A);
    const primaryColor = Color(0xFF10A37F);
    const textPrimary = Color(0xFFFFFFFF);
    const textSecondary = Color(0xFF888888);
    const textTertiary = Color(0xFF666666);
    const dividerColor = Color(0xFF2A2A2A);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 主内容区
          Column(
            children: [
              // 顶部栏
              _buildTopBar(
                context: context,
                bgColor: bgColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                primaryColor: primaryColor,
                cardBg: cardBg,
              ),
              // 聊天内容区
              const Expanded(
                child: AiChatPage(),
              ),
            ],
          ),
          
          // 侧边栏遮罩
          if (_sidebarOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _sidebarOpen = false),
                child: Container(color: Colors.black54),
              ),
            ),
          
          // 左侧侧边栏
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: _sidebarOpen ? 0 : -300,
            top: 0,
            bottom: 0,
            width: 280,
            child: _buildSidebar(
              context: context,
              sidebarBg: sidebarBg,
              cardBg: cardBg,
              cardBg2: cardBg2,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              textTertiary: textTertiary,
              primaryColor: primaryColor,
              dividerColor: dividerColor,
              novels: novels,
              selectedNovel: selectedNovel,
            ),
          ),
          
          // 模型选择下拉菜单
          if (_modelDropdownOpen)
            Positioned(
              top: 52,
              left: 0,
              right: 0,
              child: Center(
                child: _buildModelDropdown(
                  context: context,
                  cardBg: cardBg,
                  cardBg2: cardBg2,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  primaryColor: primaryColor,
                  dividerColor: dividerColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 顶部栏
  Widget _buildTopBar({
    required BuildContext context,
    required Color bgColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required Color cardBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // 菜单按钮
            IconButton(
              icon: const Icon(Icons.menu, color: textPrimary, size: 24),
              onPressed: () => setState(() => _sidebarOpen = true),
            ),
            // 标题区域（点击展开模型选择）
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _modelDropdownOpen = !_modelDropdownOpen),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '网文写作IDE',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F2F2F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedModel,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 新建按钮
            IconButton(
              icon: const Icon(Icons.edit, color: textPrimary, size: 22),
              onPressed: () {
                // TODO: 新建会话
              },
            ),
            // 设置按钮
            IconButton(
              icon: const Icon(Icons.settings, color: textPrimary, size: 22),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 左侧侧边栏
  Widget _buildSidebar({
    required BuildContext context,
    required Color sidebarBg,
    required Color cardBg,
    required Color cardBg2,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color primaryColor,
    required Color dividerColor,
    required List<Novel> novels,
    required Novel? selectedNovel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Border(right: BorderSide(color: dividerColor)),
      ),
      child: Column(
        children: [
          // 新会话按钮
          Padding(
            padding: const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: () {
                setState(() => _sidebarOpen = false);
                // TODO: 新建会话
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF333333)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: textPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '新会话',
                      style: TextStyle(color: textPrimary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 滚动内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 历史会话
                  _buildSectionLabel('历史会话', textSecondary),
                  _buildHistoryItem('都市神医开篇讨论', '今天 14:30', textPrimary, textTertiary, cardBg2),
                  _buildHistoryItem('大纲优化建议', '昨天 20:15', textPrimary, textTertiary, cardBg2),
                  _buildHistoryItem('角色关系梳理', '5月28日', textPrimary, textTertiary, cardBg2),
                  
                  const SizedBox(height: 8),
                  _buildSectionLabel('作品', textSecondary),
                  
                  // 作品树
                  ...novels.map((novel) => _buildNovelNode(
                    novel: novel,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textTertiary: textTertiary,
                    primaryColor: primaryColor,
                    cardBg2: cardBg2,
                    selectedNovel: selectedNovel,
                  )),
                  
                  const SizedBox(height: 8),
                  _buildSectionLabel('资料库', textSecondary),
                  
                  // 资料库分类
                  _buildMaterialNode('角色', 3, Icons.person, textPrimary, textTertiary, cardBg2),
                  _buildMaterialNode('设定', 2, Icons.settings, textPrimary, textTertiary, cardBg2),
                  _buildMaterialNode('伏笔', 1, Icons.lightbulb_outline, textPrimary, textTertiary, cardBg2),
                  _buildMaterialNode('势力', 0, Icons.account_balance, textPrimary, textTertiary, cardBg2),
                  _buildMaterialNode('道具', 0, Icons.inventory_2, textPrimary, textTertiary, cardBg2),
                  _buildMaterialNode('参考', 0, Icons.book, textPrimary, textTertiary, cardBg2),
                  _buildMaterialNode('记忆包', 0, Icons.psychology, textPrimary, textTertiary, cardBg2),
                ],
              ),
            ),
          ),
          
          // 底部导出/导入按钮
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _sidebarOpen = false);
                      // TODO: 导出
                    },
                    icon: const Icon(Icons.upload, size: 16),
                    label: const Text('导出'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: const BorderSide(color: Color(0xFF333333)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _sidebarOpen = false);
                      // TODO: 导入
                    },
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('导入'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: const BorderSide(color: Color(0xFF333333)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String time, Color textPrimary, Color textTertiary, Color cardBg2) {
    return GestureDetector(
      onTap: () {
        setState(() => _sidebarOpen = false);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: cardBg2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: textPrimary, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: TextStyle(color: textTertiary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNovelNode({
    required Novel novel,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color primaryColor,
    required Color cardBg2,
    required Novel? selectedNovel,
  }) {
    final isExpanded = _expandedNovels.contains(novel.id);
    final volumes = _loadedVolumes[novel.id];
    final isSelected = selectedNovel?.id == novel.id;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleNovelExpand(novel.id),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: isSelected ? cardBg2 : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  color: textTertiary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Icon(Icons.menu_book, color: textPrimary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    novel.title,
                    style: TextStyle(color: textPrimary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F2F2F),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${novel.chapterCount}章',
                    style: TextStyle(color: textSecondary, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && volumes != null)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: volumes.map((vol) => _buildVolumeNode(
                volume: vol,
                novel: novel,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                textTertiary: textTertiary,
                cardBg2: cardBg2,
              )).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildVolumeNode({
    required Volume volume,
    required Novel novel,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color cardBg2,
  }) {
    final isExpanded = _expandedVolumes.contains(volume.id);
    final chapters = _loadedChapters[volume.id];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleVolumeExpand(volume.id),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  color: textTertiary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                const Icon(Icons.folder, color: Color(0xFFFFC107), size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    volume.title,
                    style: TextStyle(color: textPrimary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && chapters != null)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: chapters.map((ch) => _buildChapterLeaf(
                chapter: ch,
                novel: novel,
                textPrimary: textPrimary,
                textTertiary: textTertiary,
                cardBg2: cardBg2,
              )).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildChapterLeaf({
    required Chapter chapter,
    required Novel novel,
    required Color textPrimary,
    required Color textTertiary,
    required Color cardBg2,
  }) {
    final status = ChapterStatus.values.firstWhere(
      (e) => e.name == chapter.status,
      orElse: () => ChapterStatus.draft,
    );
    
    Color badgeColor;
    String badgeText;
    switch (status) {
      case ChapterStatus.draft:
        badgeColor = const Color(0xFFFFC107);
        badgeText = '草稿';
        break;
      case ChapterStatus.completed:
        badgeColor = const Color(0xFF28A745);
        badgeText = '已完成';
        break;
      case ChapterStatus.empty:
        badgeColor = const Color(0xFF6C757D);
        badgeText = '未写';
        break;
    }
    
    return GestureDetector(
      onTap: () {
        ref.read(selectedNovelProvider.notifier).state = novel;
        ref.read(selectedChapterProvider.notifier).state = chapter;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorPage(novelId: novel.id, chapterId: chapter.id),
          ),
        );
        setState(() => _sidebarOpen = false);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            const Icon(Icons.description, color: Color(0xFF999999), size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                chapter.title,
                style: TextStyle(color: textPrimary, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeText,
                style: TextStyle(color: badgeColor, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialNode(String label, int count, IconData icon, Color textPrimary, Color textTertiary, Color cardBg2) {
    return GestureDetector(
      onTap: () {
        setState(() => _sidebarOpen = false);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        margin: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Icon(Icons.keyboard_arrow_right, color: textTertiary, size: 16),
            const SizedBox(width: 4),
            Icon(icon, color: textPrimary, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$label ($count)',
                style: TextStyle(color: textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 模型选择下拉菜单
  Widget _buildModelDropdown({
    required BuildContext context,
    required Color cardBg,
    required Color cardBg2,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required Color dividerColor,
  }) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: const Color(0xFF333333)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 32),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._models.map((model) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedModel = model.name;
                _modelDropdownOpen = false;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedModel == model.name ? cardBg2 : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    model.name,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                  ),
                  if (model.tag != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3A2A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        model.tag!,
                        style: const TextStyle(color: primaryColor, fontSize: 10),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (_selectedModel == model.name)
                    Icon(Icons.check, color: primaryColor, size: 18),
                ],
              ),
            ),
          )),
          Container(height: 1, color: dividerColor, margin: const EdgeInsets.symmetric(vertical: 4)),
          GestureDetector(
            onTap: () {
              setState(() => _modelDropdownOpen = false);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                '管理模型',
                style: TextStyle(color: primaryColor, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleNovelExpand(String novelId) async {
    if (_expandedNovels.contains(novelId)) {
      setState(() => _expandedNovels.remove(novelId));
    } else {
      setState(() => _expandedNovels.add(novelId));
      if (!_loadedVolumes.containsKey(novelId)) {
        final volumes = await ref.read(volumeRepoProvider).getVolumesByNovel(novelId);
        if (mounted) {
          setState(() {
            _loadedVolumes[novelId] = volumes;
          });
        }
      }
    }
  }

  void _toggleVolumeExpand(String volumeId) async {
    if (_expandedVolumes.contains(volumeId)) {
      setState(() => _expandedVolumes.remove(volumeId));
    } else {
      setState(() => _expandedVolumes.add(volumeId));
      if (!_loadedChapters.containsKey(volumeId)) {
        final chapters = await ref.read(chapterRepoProvider).getChaptersByVolume(volumeId);
        if (mounted) {
          setState(() {
            _loadedChapters[volumeId] = chapters;
          });
        }
      }
    }
  }
}

class _ModelItem {
  final String name;
  final String? tag;
  final bool isFree;
  
  const _ModelItem(this.name, this.tag, {this.isFree = false});
}
