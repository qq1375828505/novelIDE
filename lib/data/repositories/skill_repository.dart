import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:novel_ide/data/models/writing_skill_model.dart';

class SkillRepository {
  static final _uuid = Uuid();

  Future<String> _getSkillDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'NovelProjects', 'Skill'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  Future<String> _getEnabledStatePath() async {
    final dirPath = await _getSkillDir();
    return p.join(dirPath, 'builtin_enabled.json');
  }

  /// 获取内置Skill的启用状态（持久化）
  Future<Map<String, bool>> _loadBuiltinEnabledState() async {
    final file = File(await _getEnabledStatePath());
    if (!await file.exists()) {
      // 默认全部启用
      return {for (final s in WritingSkill.builtInSkills) s.id: true};
    }
    final content = await file.readAsString();
    return Map<String, bool>.from(jsonDecode(content) as Map);
  }

  /// 保存内置Skill的启用状态
  Future<void> _saveBuiltinEnabledState(Map<String, bool> state) async {
    final file = File(await _getEnabledStatePath());
    await file.writeAsString(jsonEncode(state));
  }

  /// 获取所有技能（内置+自定义）
  Future<List<WritingSkill>> getAllSkills() async {
    final dirPath = await _getSkillDir();
    final file = File(p.join(dirPath, 'skills.json'));
    if (!await file.exists()) {
      // 没有自定义skill文件时，返回内置skill（应用持久化的启用状态）
      final enabledState = await _loadBuiltinEnabledState();
      return WritingSkill.builtInSkills.map((s) {
        return WritingSkill(
          id: s.id,
          name: s.name,
          category: s.category,
          description: s.description,
          content: s.content,
          keywords: s.keywords,
          isEnabled: enabledState[s.id] ?? true,
          isBuiltIn: true,
          createdAt: s.createdAt,
          updatedAt: s.updatedAt,
        );
      }).toList();
    }

    final content = await file.readAsString();
    final list = jsonDecode(content) as List<dynamic>;
    final customSkills = list.map((e) => WritingSkill.fromJson(e as Map<String, dynamic>)).toList();

    // 应用持久化的内置skill启用状态
    final enabledState = await _loadBuiltinEnabledState();
    final builtinSkills = WritingSkill.builtInSkills.map((s) {
      return WritingSkill(
        id: s.id,
        name: s.name,
        category: s.category,
        description: s.description,
        content: s.content,
        keywords: s.keywords,
        isEnabled: enabledState[s.id] ?? true,
        isBuiltIn: true,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
      );
    }).toList();

    return [...builtinSkills, ...customSkills];
  }

  /// 获取自定义技能
  Future<List<WritingSkill>> getCustomSkills() async {
    final dirPath = await _getSkillDir();
    final file = File(p.join(dirPath, 'skills.json'));
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final list = jsonDecode(content) as List<dynamic>;
    return list.map((e) => WritingSkill.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 保存自定义技能
  Future<void> saveCustomSkills(List<WritingSkill> skills) async {
    final dirPath = await _getSkillDir();
    final file = File(p.join(dirPath, 'skills.json'));
    await file.writeAsString(jsonEncode(skills.map((s) => s.toJson()).toList()));
  }

  /// 添加自定义技能
  Future<void> addSkill(WritingSkill skill) async {
    final skills = await getCustomSkills();
    skills.add(skill);
    await saveCustomSkills(skills);
  }

  /// 更新技能（支持内置Skill的启用状态切换）
  Future<void> updateSkill(WritingSkill skill) async {
    if (skill.isBuiltIn) {
      // 内置Skill：只持久化启用状态
      final state = await _loadBuiltinEnabledState();
      state[skill.id] = skill.isEnabled;
      await _saveBuiltinEnabledState(state);
    } else {
      // 自定义Skill：完整更新
      final skills = await getCustomSkills();
      final idx = skills.indexWhere((s) => s.id == skill.id);
      if (idx >= 0) {
        skills[idx] = skill;
        await saveCustomSkills(skills);
      }
    }
  }

  /// 删除自定义技能
  Future<void> deleteSkill(String skillId) async {
    final skills = await getCustomSkills();
    skills.removeWhere((s) => s.id == skillId);
    await saveCustomSkills(skills);
  }

  /// 获取启用的技能内容（用于AI上下文）
  Future<String> getEnabledSkillsContext() async {
    final allSkills = await getAllSkills();
    final enabled = allSkills.where((s) => s.isEnabled).toList();

    if (enabled.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('【Skill参考】');
    for (final skill in enabled) {
      buffer.writeln('\n## ${skill.name}（${skill.category}）');
      buffer.writeln(skill.content);
    }
    return buffer.toString();
  }

  /// 创建新技能
  WritingSkill createSkill({
    required String name,
    required String category,
    required String description,
    required String content,
    List<String> keywords = const [],
  }) {
    return WritingSkill(
      id: 'skill_${_uuid.v4().substring(0, 8)}',
      name: name,
      category: category,
      description: description,
      content: content,
      keywords: keywords,
    );
  }
}
