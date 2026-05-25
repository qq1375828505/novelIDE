import 'package:novel_ide/data/models/ai_config_model.dart';

/// Model routing rules - determines which model to use for which task.
enum AiTaskType {
  chat,        // AI聊天
  continueWriting, // 续写
  polish,      // 润色
  titleGen,    // 标题生成
  analysis,    // 爽点/水文分析
  outline,     // 大纲生成
  character,   // 角色生成
  search,      // 联网搜索增强
}

class ModelRouter {
  final List<AiConfig> _configs;
  final Map<AiTaskType, String> _taskModelMap = {};

  ModelRouter(this._configs);

  /// Set preferred model for a task type.
  void setModelForTask(AiTaskType task, String configId) {
    _taskModelMap[task] = configId;
  }

  /// Get the best model for a task. Falls back to first available config.
  AiConfig getModelForTask(AiTaskType task) {
    // Check if user set a specific model for this task
    final preferredId = _taskModelMap[task];
    if (preferredId != null) {
      final match = _configs.where((c) => c.id == preferredId);
      if (match.isNotEmpty) return match.first;
    }

    // Auto-select based on task type
    switch (task) {
      case AiTaskType.chat:
      case AiTaskType.continueWriting:
      case AiTaskType.polish:
        // Creative tasks prefer non-local models with higher max_tokens
        return _configs.firstWhere(
          (c) => !c.isLocal && c.maxTokens >= 4096,
          orElse: () => _configs.first,
        );
      case AiTaskType.analysis:
      case AiTaskType.outline:
      case AiTaskType.character:
        // Analysis tasks can use any model
        return _configs.first;
      case AiTaskType.titleGen:
        // Title generation is simple, any model works
        return _configs.first;
      case AiTaskType.search:
        // Search augmentation prefers cloud models
        return _configs.firstWhere(
          (c) => !c.isLocal,
          orElse: () => _configs.first,
        );
    }
  }

  /// Get all task type labels in Chinese.
  static const taskLabels = {
    AiTaskType.chat: 'AI聊天',
    AiTaskType.continueWriting: '续写',
    AiTaskType.polish: '润色',
    AiTaskType.titleGen: '标题生成',
    AiTaskType.analysis: '分析检测',
    AiTaskType.outline: '大纲生成',
    AiTaskType.character: '角色生成',
    AiTaskType.search: '搜索增强',
  };
}
