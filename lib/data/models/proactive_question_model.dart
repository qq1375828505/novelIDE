import 'package:novel_ide/data/models/writing_skill_model.dart';

/// 主动提问类型
enum ProactiveQuestionType {
  novelGenre,      // 小说类型
  writingStyle,    // 写作风格
  agentSelection,  // 智能体选择
  skillSelection,  // 技能选择
  outputFormat,    // 输出格式
  custom,          // 自定义
}

/// 主动提问选项
class ProactiveOption {
  final String id;
  final String label;
  final String? description;
  final String? icon;
  final Map<String, dynamic>? metadata;

  const ProactiveOption({
    required this.id,
    required this.label,
    this.description,
    this.icon,
    this.metadata,
  });
}

/// 主动提问模型
class ProactiveQuestion {
  final String id;
  final String title;
  final String? subtitle;
  final ProactiveQuestionType type;
  final List<ProactiveOption> options;
  final bool allowCustomInput;
  final bool multiSelect;
  final String? customInputPlaceholder;
  final String? selectedSkillId;
  final String? selectedAgentId;

  const ProactiveQuestion({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    required this.options,
    this.allowCustomInput = true,
    this.multiSelect = false,
    this.customInputPlaceholder,
    this.selectedSkillId,
    this.selectedAgentId,
  });

  /// 从技能列表创建技能选择问题
  factory ProactiveQuestion.forSkills(List<WritingSkill> skills) {
    return ProactiveQuestion(
      id: 'skill_selection',
      title: '选择写作技能',
      subtitle: '请选择要使用的写作技能，AI将据此优化输出',
      type: ProactiveQuestionType.skillSelection,
      options: skills.map((s) => ProactiveOption(
        id: s.id,
        label: s.name,
        description: s.description,
        metadata: {'category': s.category},
      )).toList(),
      allowCustomInput: false,
      multiSelect: true,
    );
  }

  /// 创建小说类型选择问题
  static const novelGenreQuestion = ProactiveQuestion(
    id: 'novel_genre',
    title: '选择小说类型',
    subtitle: '请选择您想写的小说类型，AI将据此调整写作风格',
    type: ProactiveQuestionType.novelGenre,
    options: [
      ProactiveOption(id: 'xuanhuan', label: '玄幻', description: '修仙、异能、魔法世界'),
      ProactiveOption(id: 'dushi', label: '都市', description: '现代都市生活'),
      ProactiveOption(id: 'yanqing', label: '言情', description: '爱情故事'),
      ProactiveOption(id: 'lishi', label: '历史', description: '历史背景故事'),
      ProactiveOption(id: 'kehuan', label: '科幻', description: '未来科技、太空探索'),
      ProactiveOption(id: 'wuxia', label: '武侠', description: '江湖武林'),
      ProactiveOption(id: 'lingyi', label: '灵异', description: '鬼怪、悬疑'),
      ProactiveOption(id: 'junshi', label: '军事', description: '战争、军旅'),
    ],
    allowCustomInput: true,
    customInputPlaceholder: '其他类型...',
  );

  /// 创建智能体选择问题
  static const agentSelectionQuestion = ProactiveQuestion(
    id: 'agent_selection',
    title: '选择智能体',
    subtitle: '请选择要使用的智能体来执行任务',
    type: ProactiveQuestionType.agentSelection,
    options: [
      ProactiveOption(id: 'outline_generator', label: '番茄大纲生成器', description: '生成符合番茄风格的小说大纲'),
      ProactiveOption(id: 'character_generator', label: '番茄角色生成器', description: '生成角色设定和人设'),
      ProactiveOption(id: 'shuangdian_checker', label: '爽点密度检查器', description: '检查章节爽点分布'),
      ProactiveOption(id: 'water_detector', label: '水文检测器', description: '检测冗余内容'),
      ProactiveOption(id: 'title_generator', label: '爆款标题生成器', description: '生成吸引眼球的标题'),
    ],
    allowCustomInput: false,
  );
}

/// 用户选择结果
class ProactiveSelection {
  final ProactiveQuestion question;
  final List<ProactiveOption> selectedOptions;
  final String? customInput;

  ProactiveSelection({
    required this.question,
    required this.selectedOptions,
    this.customInput,
  });

  /// 转换为AI可理解的文本
  String toAiContext() {
    final buffer = StringBuffer();
    buffer.writeln('用户选择了：');
    for (final opt in selectedOptions) {
      buffer.writeln('- ${opt.label}');
      if (opt.description != null) {
        buffer.writeln('  ${opt.description}');
      }
    }
    if (customInput != null && customInput!.isNotEmpty) {
      buffer.writeln('- 自定义：$customInput');
    }
    return buffer.toString();
  }
}
