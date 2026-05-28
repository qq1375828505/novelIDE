import 'package:novel_ide/data/models/writing_skill_model.dart';

/// 技能匹配引擎
/// 根据用户输入文本，自动匹配相关的写作技能
class SkillMatcher {
  /// 最大同时匹配的技能数量
  static const int maxMatchCount = 3;

  /// 匹配用户消息中的关键词，返回命中的技能列表
  static List<WritingSkill> match(
    String userMessage,
    List<WritingSkill> enabledSkills,
  ) {
    if (userMessage.trim().isEmpty || enabledSkills.isEmpty) return [];

    final matched = <WritingSkill>[];
    for (final skill in enabledSkills) {
      if (skill.keywords.isEmpty) continue;
      for (final keyword in skill.keywords) {
        if (userMessage.contains(keyword)) {
          matched.add(skill);
          break; // 每个技能只匹配一次
        }
      }
      if (matched.length >= maxMatchCount) break;
    }
    return matched;
  }

  /// 将匹配到的技能内容注入系统提示词
  static String injectSkillContext(
    String systemPrompt,
    List<WritingSkill> matchedSkills,
  ) {
    if (matchedSkills.isEmpty) return systemPrompt;

    final buffer = StringBuffer();
    buffer.writeln(systemPrompt);
    buffer.writeln('\n【已启动技能参考】');
    for (final skill in matchedSkills) {
      buffer.writeln('\n## ${skill.name}（${skill.category}）');
      buffer.writeln(skill.content);
    }
    return buffer.toString();
  }
}
