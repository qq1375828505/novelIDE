import 'dart:convert';

/// AI 对话会话数据模型（支持 JSON 序列化）
class AiChatSessionModel {
  final String id;
  String title;
  List<Map<String, String>> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  AiChatSessionModel({
    required this.id,
    required this.title,
    List<Map<String, String>>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : messages = messages != null ? List.from(messages) : [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从 JSON 构造
  factory AiChatSessionModel.fromJson(Map<String, dynamic> json) {
    return AiChatSessionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((m) => Map<String, String>.from(m as Map))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 转为 JSON 字符串
  String toJsonString() => jsonEncode(toJson());

  /// 从 JSON 字符串构造
  static AiChatSessionModel fromJsonString(String jsonString) {
    return AiChatSessionModel.fromJson(jsonDecode(jsonString));
  }

  /// 更新消息并刷新更新时间
  void updateMessages(List<Map<String, String>> newMessages) {
    messages = List.from(newMessages);
    updatedAt = DateTime.now();
  }

  /// 添加消息
  void addMessage(Map<String, String> message) {
    messages.add(message);
    updatedAt = DateTime.now();
  }

  /// 获取消息数量
  int get messageCount => messages.length;

  /// 获取最后一条消息预览
  String get lastMessagePreview {
    if (messages.isEmpty) return '';
    final last = messages.last;
    final content = last['content'] ?? '';
    return content.length > 30 ? '${content.substring(0, 30)}...' : content;
  }
}

/// 会话列表包装类
class AiChatSessionList {
  final List<AiChatSessionModel> sessions;

  AiChatSessionList({required this.sessions});

  factory AiChatSessionList.fromJson(Map<String, dynamic> json) {
    return AiChatSessionList(
      sessions: (json['sessions'] as List<dynamic>)
          .map((s) => AiChatSessionModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessions': sessions.map((s) => s.toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static AiChatSessionList fromJsonString(String jsonString) {
    return AiChatSessionList.fromJson(jsonDecode(jsonString));
  }
}
