import 'package:novel_ide/data/models/proactive_question_model.dart';
import 'package:novel_ide/data/models/writing_skill_model.dart';

/// 模糊需求识别服务
/// 分析用户输入，判断是否需要主动提问
class FuzzyNeedDetector {
  /// 模糊关键词模式
  static const Map<ProactiveQuestionType, List<String>> _fuzzyPatterns = {
    ProactiveQuestionType.novelGenre: [
      '写小说', '写一本', '创作小说', '新小说', '开始写',
      '想写', '要写', '帮我写', '小说',
    ],
    ProactiveQuestionType.agentSelection: [
      '生成大纲', '生成角色', '检查爽点', '检测水文',
      '生成标题', '帮我生成', '自动生成',
    ],
    ProactiveQuestionType.skillSelection: [
      '优化', '改进', '提升', '润色', '修改',
      '重写', '调整',
    ],
    ProactiveQuestionType.outputFormat: [
      '输出', '格式', '结果', '展示',
    ],
  };

  /// 检测用户输入是否为模糊需求
  /// 返回需要提问的类型，null表示不需要
  ProactiveQuestionType? detect(String userInput) {
    final input = userInput.toLowerCase();

    for (final entry in _fuzzyPatterns.entries) {
      for (final pattern in entry.value) {
        if (input.contains(pattern)) {
          // 检查是否已经有足够具体的信息
          if (!_isSpecificEnough(input, entry.key)) {
            return entry.key;
          }
        }
      }
    }
    return null;
  }

  /// 检查输入是否已经足够具体
  bool _isSpecificEnough(String input, ProactiveQuestionType type) {
    switch (type) {
      case ProactiveQuestionType.novelGenre:
        // 如果已经指定了类型，则不需要再问
        const genres = ['玄幻', '都市', '言情', '历史', '科幻', '武侠', '灵异', '军事', '仙侠', '奇幻'];
        return genres.any((g) => input.contains(g));
      case ProactiveQuestionType.agentSelection:
        // 如果已经指定了具体任务，则不需要再问
        return input.contains('大纲') || input.contains('角色') || input.contains('标题');
      case ProactiveQuestionType.skillSelection:
        // 如果已经指定了具体技能，则不需要再问
        return false; // 总是让用户选择
      case ProactiveQuestionType.outputFormat:
        return false;
      case ProactiveQuestionType.custom:
        return false;
    }
  }

  /// 根据用户输入和记忆生成个性化问题
  Future<ProactiveQuestion?> generateQuestion(
    String userInput,
    ProactiveQuestionType type, {
    String? userMemory,
    List<WritingSkill>? availableSkills,
  }) async {
    switch (type) {
      case ProactiveQuestionType.novelGenre:
        return _generateGenreQuestion(userInput, userMemory);
      case ProactiveQuestionType.agentSelection:
        return ProactiveQuestion.agentSelectionQuestion;
      case ProactiveQuestionType.skillSelection:
        if (availableSkills != null && availableSkills.isNotEmpty) {
          return ProactiveQuestion.forSkills(
            availableSkills.where((s) => s.isEnabled).toList(),
          );
        }
        return null;
      case ProactiveQuestionType.outputFormat:
        return null;
      case ProactiveQuestionType.custom:
        return null;
    }
  }

  /// 生成小说类型选择问题（结合用户记忆）
  ProactiveQuestion _generateGenreQuestion(String userInput, String? userMemory) {
    // 从用户记忆中提取偏好类型
    final preferredGenres = <String>[];
    if (userMemory != null) {
      const genreKeywords = {
        '玄幻': ['玄幻', '修仙', '仙侠'],
        '都市': ['都市', '现代'],
        '言情': ['言情', '恋爱', '爱情'],
        '历史': ['历史', '古代'],
        '科幻': ['科幻', '未来'],
      };
      for (final entry in genreKeywords.entries) {
        if (entry.value.any((k) => userMemory.contains(k))) {
          preferredGenres.add(entry.key);
        }
      }
    }

    // 重新排序选项，把偏好的类型放前面
    final options = List<ProactiveOption>.from(ProactiveQuestion.novelGenreQuestion.options);
    if (preferredGenres.isNotEmpty) {
      options.sort((a, b) {
        final aPreferred = preferredGenres.contains(a.label);
        final bPreferred = preferredGenres.contains(b.label);
        if (aPreferred && !bPreferred) return -1;
        if (!aPreferred && bPreferred) return 1;
        return 0;
      });
    }

    return ProactiveQuestion(
      id: 'novel_genre',
      title: '选择小说类型',
      subtitle: preferredGenres.isNotEmpty
          ? '根据您的偏好，推荐：${preferredGenres.join('、')}'
          : '请选择您想写的小说类型',
      type: ProactiveQuestionType.novelGenre,
      options: options,
      allowCustomInput: true,
      customInputPlaceholder: '其他类型...',
    );
  }

  /// 检测是否需要触发Workspace Agent
  bool shouldTriggerWorkspaceAgent(String userInput) {
    const triggerPatterns = [
      '生成', '创建', '分析', '检查', '优化',
      '帮我', '自动', '一键',
    ];
    return triggerPatterns.any((p) => userInput.contains(p));
  }

  /// 从用户输入提取任务意图
  Map<String, dynamic> extractIntent(String userInput) {
    final intent = <String, dynamic>{};

    // 检测任务类型
    if (userInput.contains('大纲')) {
      intent['task'] = 'generate_outline';
    } else if (userInput.contains('角色')) {
      intent['task'] = 'generate_character';
    } else if (userInput.contains('标题')) {
      intent['task'] = 'generate_title';
    } else if (userInput.contains('检查') || userInput.contains('分析')) {
      intent['task'] = 'analyze';
    } else if (userInput.contains('优化') || userInput.contains('改进')) {
      intent['task'] = 'optimize';
    }

    // 检测目标对象
    if (userInput.contains('章节')) {
      intent['target'] = 'chapter';
    } else if (userInput.contains('小说') || userInput.contains('作品')) {
      intent['target'] = 'novel';
    } else if (userInput.contains('角色') || userInput.contains('人物')) {
      intent['target'] = 'character';
    }

    return intent;
  }
}
