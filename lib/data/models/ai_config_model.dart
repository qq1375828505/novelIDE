import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_config_model.freezed.dart';
part 'ai_config_model.g.dart';

/// API protocol types.
enum ApiProtocol {
  openaiCompatible,  // OpenAI / DeepSeek / 通义千问 / Moonshot 等
  anthropic,         // Claude API
}

/// 模型类型
enum ModelType {
  text,       // 文本对话模型
  tts,        // 语音合成模型
  stt,        // 语音识别模型
  multimodal, // 多模态模型
}

@freezed
class AiConfig with _$AiConfig {
  factory AiConfig({
    required String id,
    required String name,
    required String apiUrl,
    required String modelName,
    String? apiKey,
    @Default(1.0) double temperature,
    @Default(4096) int maxTokens,
    @Default(false) bool isLocal,
    @Default(ApiProtocol.openaiCompatible) ApiProtocol protocol,
    @Default(ModelType.text) ModelType modelType,
  }) = _AiConfig;

  factory AiConfig.fromJson(Map<String, dynamic> json) => _$AiConfigFromJson(json);
}
