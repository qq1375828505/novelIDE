import 'dart:convert';
import 'package:http/http.dart' as http;

/// 智谱AI (ZhipuAI) 服务
/// 支持 GLM-4-Flash 等免费模型
/// API文档: https://open.bigmodel.cn/dev/api
class ZhipuAIService {
  static const String _baseUrl = 'https://open.bigmodel.cn/api/paas/v4';
  
  final String apiKey;
  
  ZhipuAIService({required this.apiKey});

  /// 发送聊天请求
  Future<String> chat({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 2048,
    bool stream = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
          'stream': stream,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'] ?? '';
        }
        return '';
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception('智谱AI错误: ${error['error']['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('智谱AI请求失败: $e');
    }
  }

  /// 流式聊天请求
  Stream<String> chatStream({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async* {
    try {
      final request = http.Request('POST', Uri.parse('$_baseUrl/chat/completions'));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'Accept': 'text/event-stream',
      });
      request.body = jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'stream': true,
      });

      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw Exception('智谱AI错误: $body');
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') return;
            try {
              final json = jsonDecode(data);
              final delta = json['choices']?[0]?['delta']?['content'];
              if (delta != null) {
                yield delta as String;
              }
            } catch (_) {
              // 忽略解析错误
            }
          }
        }
      }
    } catch (e) {
      throw Exception('智谱AI流式请求失败: $e');
    }
  }

  /// 获取可用模型列表
  static List<Map<String, String>> getAvailableModels() {
    return [
      {
        'id': 'glm-4-flash',
        'name': 'GLM-4-Flash',
        'description': '完全免费，128K上下文，适合日常对话',
      },
      {
        'id': 'glm-4-7b',
        'name': 'GLM-4-7B',
        'description': '轻量模型，200K上下文',
      },
      {
        'id': 'glm-4',
        'name': 'GLM-4',
        'description': '旗舰模型，128K上下文（按量计费）',
      },
      {
        'id': 'glm-4-plus',
        'name': 'GLM-4-Plus',
        'description': '增强版，128K上下文（按量计费）',
      },
    ];
  }

  /// 测试API Key是否有效
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
