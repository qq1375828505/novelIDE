import 'package:flutter/material.dart';
import 'package:novel_ide/data/models/writing_skill_model.dart';

/// "已启动Skill" 提示气泡
/// 在AI回复之前显示，告知用户哪些Skill被自动触发
class SkillIndicator extends StatelessWidget {
  final List<WritingSkill> matchedSkills;

  const SkillIndicator({super.key, required this.matchedSkills});

  @override
  Widget build(BuildContext context) {
    if (matchedSkills.isEmpty) return const SizedBox.shrink();

    final names = matchedSkills.map((s) => s.name).join('、');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '已启动Skill：$names',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
