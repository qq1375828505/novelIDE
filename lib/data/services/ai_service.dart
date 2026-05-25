import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_ide/data/models/ai_config_model.dart';
import 'package:novel_ide/data/services/cost_tracker.dart';

/// Unified AI service with cost tracking.
class AiService {
  final Dio _dio = Dio();
  final CostTracker _costTracker = CostTracker();

  /// Send a chat completion request. Tracks cost automatically.
  Future<String> chat(AiConfig config, List<Map<String, String>> messages, {String taskType = 'chat'}) async {
    final response = await _dio.post(
      config.apiUrl,
      options: Options(headers: {
        'Authorization': 'Bearer ${config.apiKey ?? ''}',
        'Content-Type': 'application/json',
      }),
      data: {
        'model': config.modelName,
        'messages': messages,
        'temperature': config.temperature,
        'max_tokens': config.maxTokens,
      },
    );

    final content = response.data['choices']?[0]?['message']?['content'] ?? '生成失败，请检查API配置';

    // Track usage
    final usage = response.data['usage'];
    final tokenCount = (usage?['total_tokens'] as int?) ?? content.length ~/ 2;
    _costTracker.recordUsage(
      configId: config.id,
      model: config.modelName,
      taskType: taskType,
      tokenCount: tokenCount,
    );

    return content;
  }

  /// Convenience: send with system prompt + user message.
  Future<String> send({
    required AiConfig config,
    required String systemPrompt,
    required String userMessage,
    String taskType = 'chat',
  }) async {
    return chat(config, [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userMessage},
    ], taskType: taskType);
  }
}

final aiServiceProvider = Provider((ref) => AiService());
