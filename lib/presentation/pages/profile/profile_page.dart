import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_ide/core/constants.dart';
import 'package:novel_ide/core/router.dart';
import 'package:novel_ide/core/theme/app_themes.dart';
import 'package:novel_ide/core/theme/skin_provider.dart';
import 'package:novel_ide/presentation/state/app_providers.dart';
import 'package:novel_ide/data/services/config_service.dart';
import 'package:novel_ide/presentation/pages/stats/stats_page.dart';
import 'package:novel_ide/presentation/pages/profile/app_config_page.dart';
import 'package:novel_ide/presentation/pages/profile/user_memory_page.dart';
import 'package:novel_ide/presentation/pages/profile/skill_manage_page.dart';
import 'package:novel_ide/presentation/pages/profile/voice_config_page.dart';
import 'package:novel_ide/data/services/announcement_service.dart';
import 'package:novel_ide/presentation/pages/profile/ai_config_list_page.dart';
import 'package:novel_ide/data/services/backup_service.dart';


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Widget _buildVoiceSubtitle(WidgetRef ref) {
    final voiceConfig = ref.watch(selectedVoiceConfigProvider);
    if (voiceConfig != null) {
      return Text('已配置：${voiceConfig.name}', style: TextStyle(fontSize: 12, color: Colors.teal[600]));
    }
    return Text('待添加 · 通话功能不可用', style: TextStyle(fontSize: 12, color: Colors.orange[600]));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    final wordGoal = ref.watch(wordGoalProvider);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                const Text('网文作者', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('单机版 · 数据本地存储', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ],
            ),
          ),
          const Divider(),
          _SectionHeader(title: 'AI 模型配置'),
          Consumer(
            builder: (context, ref, _) {
              final config = ref.watch(selectedAiConfigProvider);
              return ListTile(
                leading: const Icon(Icons.smart_toy_outlined),
                title: Text(config?.name ?? '未选择模型'),
                subtitle: Text(config?.modelName ?? '点击配置AI模型'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiConfigListPage())),
              );
            },
          ),
          const Divider(),

          _SectionHeader(title: 'AI 写作'),
          ListTile(
            leading: const Icon(Icons.psychology, color: AppColors.secondary),
            title: const Text('用户记忆'),
            subtitle: const Text('记录您的写作风格和AI偏好，AI对话时自动读取'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserMemoryPage()));
            },
          ),
          const SizedBox(height: 4),
          ListTile(
            leading: const Icon(Icons.record_voice_over, color: Colors.teal),
            title: const Text('语音模型'),
            subtitle: _buildVoiceSubtitle(ref),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceConfigPage()));
            },
          ),
          const SizedBox(height: 4),

          _SectionHeader(title: '番茄写作'),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: AppColors.tomatoRed),
            title: const Text('Agent'),
            subtitle: const Text('番茄大纲生成器、爽点检查器、水文检测器等'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.agents);
            },
          ),
          const SizedBox(height: 4),
          ListTile(
            leading: const Icon(Icons.edit_calendar),
            title: const Text('每日字数目标'),
            subtitle: Text('目标：$wordGoal字/天'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () {
                    final newGoal = (wordGoal - 500).clamp(500, 20000);
                    ref.read(wordGoalProvider.notifier).state = newGoal;
                    ConfigService.wordGoal = newGoal;
                  },
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$wordGoal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () {
                    final newGoal = (wordGoal + 500).clamp(500, 20000);
                    ref.read(wordGoalProvider.notifier).state = newGoal;
                    ConfigService.wordGoal = newGoal;
                  },
                ),
              ],
            ),
          ),
          // Stats entry
          ListTile(
            leading: const Icon(Icons.bar_chart, color: AppColors.primary),
            title: const Text('写作统计'),
            subtitle: const Text('查看字数趋势和打卡记录'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsPage()),
              );
            },
          ),
          // Skills entry
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Colors.deepPurple),
            title: const Text('Skill'),
            subtitle: const Text('管理和自定义AI写作技巧'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SkillManagePage()),
              );
            },
          ),
          const Divider(),

          _SectionHeader(title: '外观'),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('深色模式'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(darkModeProvider.notifier).state = value;
                ConfigService.isDarkMode = value;
              },
            ),
          ),
          // 主题皮肤选择器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette, size: 24),
                    const SizedBox(width: 16),
                    const Text('主题皮肤', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                _SkinSelector(),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text('字体设置'),
            subtitle: Text('字号：${fontSize.toInt()}px'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontSettingsDialog(context, ref),
          ),
          // Software config
          ListTile(
            leading: const Icon(Icons.code, color: Colors.teal),
            title: const Text('软件配置'),
            subtitle: const Text('修改配置文件自定义软件行为'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AppConfigPage()));
            },
          ),
          const Divider(),

          _SectionHeader(title: '数据管理'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('备份所有作品'),
            subtitle: const Text('导出为 .zip 压缩包'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final path = await BackupService.backup();
              if (context.mounted) {
                if (path != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('备份成功：$path'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('备份失败或已取消'), backgroundColor: Colors.orange),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('恢复备份'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: AppColors.error),
            title: const Text('清空所有数据', style: TextStyle(color: AppColors.error)),
            onTap: () => _showClearDataDialog(context, ref),
          ),
          const Divider(),

          // 公告入口
          ListTile(
            leading: const Icon(Icons.campaign, color: Colors.orange),
            title: const Text('公告'),
            subtitle: const Text('免费AI模型使用说明、注册指引'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAnnouncement(context),
          ),
          const SizedBox(height: 4),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            subtitle: const Text('网文写作IDE v1.0.0 · 完全单机运行'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 显示公告弹窗
  void _showAnnouncement(BuildContext context) {
    final announcement = AnnouncementService.getAnnouncement();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.campaign, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(announcement['title']!)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(announcement['content']!),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // TODO: 打开浏览器跳转注册链接
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        announcement['url']!,
                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showFontSettingsDialog(BuildContext context, WidgetRef ref) {
    final fontSize = ref.read(fontSizeProvider);
    final lineHeight = ref.read(lineHeightProvider);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('字体设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('字号'),
              Row(
                children: [
                  const Text('14', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: fontSize,
                      min: 14,
                      max: 24,
                      divisions: 10,
                      label: '${fontSize.toInt()}',
                      onChanged: (v) {
                        ref.read(fontSizeProvider.notifier).state = v;
                        ConfigService.fontSize = v;
                        setDialogState(() {});
                      },
                    ),
                  ),
                  const Text('24', style: TextStyle(fontSize: 12)),
                ],
              ),
              Text('当前：${fontSize.toInt()}px', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              const SizedBox(height: 16),
              const Text('行高'),
              Row(
                children: [
                  const Text('1.4', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: lineHeight,
                      min: 1.2,
                      max: 2.4,
                      divisions: 12,
                      label: lineHeight.toStringAsFixed(1),
                      onChanged: (v) {
                        ref.read(lineHeightProvider.notifier).state = v;
                        ConfigService.lineHeight = v;
                        setDialogState(() {});
                      },
                    ),
                  ),
                  const Text('2.4', style: TextStyle(fontSize: 12)),
                ],
              ),
              Text('当前：${lineHeight.toStringAsFixed(1)}', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('完成'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空所有数据'),
        content: const Text('此操作将删除所有作品、章节和设置，不可恢复。确定继续吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已清空')),
              );
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const Spacer(),
        ],
      ),
    );
  }
}


/// 主题皮肤选择器 — 2行4列网格卡片
class _SkinSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSkin = ref.watch(skinThemeProvider);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: AppSkins.all.length,
      itemBuilder: (context, index) {
        final skin = AppSkins.all[index];
        final isSelected = currentSkin.type == skin.type;

        return GestureDetector(
          onTap: () {
            ref.read(skinThemeProvider.notifier).setSkin(skin.type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: skin.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? skin.primary : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: skin.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 颜色预览条
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ColorDot(color: skin.primary, size: 14),
                    const SizedBox(width: 4),
                    _ColorDot(color: skin.secondary, size: 14),
                    const SizedBox(width: 4),
                    _ColorDot(color: skin.background, size: 14),
                  ],
                ),
                const SizedBox(height: 8),
                // 主题名
                Text(
                  skin.type.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: skin.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  skin.type.desc,
                  style: TextStyle(fontSize: 9, color: skin.textSecondary),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(Icons.check_circle, size: 14, color: skin.primary),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 小色点预览
class _ColorDot extends StatelessWidget {
  final Color color;
  final double size;
  const _ColorDot({required this.color, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 0.5),
      ),
    );
  }
}
