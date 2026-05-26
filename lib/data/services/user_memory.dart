import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// UserMemory: 用户级全局记忆，跨所有小说共享。
/// 类似 Claude Code 的 MEMORY.md —— 记录用户偏好、习惯、指令。
/// 与 NovelMemory（每部小说独立）互补。
class UserMemory {
  static String? _cachedContent;

  /// 记忆文件路径
  static Future<String> get _memoryPath async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'NovelProjects', 'memories'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return p.join(dir.path, 'user_memory.txt');
  }

  /// 检查记忆文件是否存在
  static Future<bool> exists() async {
    final path = await _memoryPath;
    return await File(path).exists();
  }

  /// 加载记忆内容
  static Future<String> load() async {
    if (_cachedContent != null) return _cachedContent!;
    final path = await _memoryPath;
    final file = File(path);
    if (!await file.exists()) {
      _cachedContent = defaultContent();
      await save(_cachedContent!);
      return _cachedContent!;
    }
    _cachedContent = await file.readAsString();
    return _cachedContent!;
  }

  /// 保存记忆内容
  static Future<void> save(String content) async {
    final path = await _memoryPath;
    await File(path).writeAsString(content);
    _cachedContent = content;
  }

  /// 清除缓存
  static void invalidateCache() {
    _cachedContent = null;
  }

  /// 追加一条用户偏好（去重）
  static Future<void> addPreference(String category, String content) async {
    final current = await load();
    final marker = '[$category] ';
    // 检查是否已存在相同内容
    if (current.contains('$marker$content')) return;
    final lines = current.split('\n');
    // 找到同类别的最后一行，在其后插入
    int insertIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith(marker) || lines[i].startsWith('## $category')) {
        insertIndex = i + 1;
      }
    }
    if (insertIndex == -1 || insertIndex >= lines.length) {
      // 找不到类别，追加到末尾
      final updated = '$current\n$marker$content';
      await save(updated);
    } else {
      lines.insert(insertIndex, '$marker$content');
      await save(lines.join('\n'));
    }
  }

  /// 记录用户写作风格偏好
  static Future<void> recordWritingStyle(String style) async {
    await addPreference('写作风格', style);
  }

  /// 记录用户常用指令
  static Future<void> recordInstruction(String instruction) async {
    await addPreference('常用指令', instruction);
  }

  /// 记录用户喜欢的AI回复风格
  static Future<void> recordAiPreference(String preference) async {
    await addPreference('AI偏好', preference);
  }

  /// 获取注入AI的用户记忆
  static Future<String> getForAiContext() async {
    final content = await load();
    if (content.trim().isEmpty) return '';
    return '\n\n用户偏好（全局记忆）：\n$content';
  }

  /// 默认记忆内容模板（公开，供重置使用）
  static String defaultContent() {
    final now = DateTime.now().toString().substring(0, 19);
    return '''╔══════════════════════════════════════════╗
║     用户记忆文件 (User Memory)            ║
║  记录您的偏好、习惯和常用指令            ║
║  AI对话时会自动读取此文件                ║
╚══════════════════════════════════════════╝

## 写作风格
（在此记录您偏好的写作风格，如：都市赘婿、玄幻修仙、节奏快等）

## 常用指令
（在此记录您对AI的常用要求，如：每章3000字、不要用文言文、多写打脸情节等）

## AI偏好
（在此记录您对AI回复的偏好，如：用中文回复、简洁一点、给出具体示例等）

## 其他
（其他需要AI记住的信息）

---
创建时间: $now
''';
  }
}
