import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// App configuration file - like Claude Code's settings.json.
/// Allows users to customize app behavior via a JSON config file.
class AppConfig {
  static AppConfig? _instance;
  late Map<String, dynamic> _config;

  AppConfig._();

  static Future<AppConfig> instance() async {
    if (_instance == null) {
      _instance = AppConfig._();
      await _instance!._load();
    }
    return _instance!;
  }

  Future<String> get configPath async {
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, 'app_config.json');
  }

  /// Default configuration.
  static Map<String, dynamic> get _defaults => {
    'editor': {
      'fontSize': 18.0,
      'fontFamily': 'NotoSerifSC',
      'lineHeight': 1.8,
      'autoSaveDelayMs': 1500,
      'snapshotIntervalMinutes': 3,
      'maxSnapshotsPerChapter': 20,
      'maxCharsForContext': 2000,
    },
    'ai': {
      'defaultTaskType': 'chat',
      'autoLoadMemory': true,
      'memoryMaxChars': 5000,
      'temperature': 1.0,
      'maxTokens': 4096,
    },
    'stats': {
      'dailyWordGoal': 3000,
      'reminderHour': 21,
      'reminderMinute': 0,
    },
    'export': {
      'format': 'txt',
      'includeMemory': true,
      'chapterOrder': 'by_index',
    },
    'ui': {
      'darkMode': false,
      'showWordCount': true,
      'showSaveStatus': true,
      'bottomNavIndex': 0,
    },
  };

  /// Load config from file, merge with defaults.
  Future<void> _load() async {
    _config = Map<String, dynamic>.from(_defaults);
    try {
      final path = await configPath;
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        final saved = jsonDecode(content) as Map<String, dynamic>;
        _deepMerge(_config, saved);
      }
    } catch (_) {}
  }

  /// Save current config to file.
  Future<void> save() async {
    final path = await configPath;
    await File(path).writeAsString(jsonEncode(_config));
  }

  /// Get a config value by dot-notation path.
  /// e.g. get('editor.fontSize') returns 18.0
  dynamic get(String path, {dynamic fallback}) {
    final parts = path.split('.');
    dynamic current = _config;
    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return fallback;
      }
    }
    return current;
  }

  /// Set a config value by dot-notation path.
  Future<void> set(String path, dynamic value) async {
    final parts = path.split('.');
    dynamic current = _config;
    for (int i = 0; i < parts.length - 1; i++) {
      if (current is! Map || !current.containsKey(parts[i])) {
        current[parts[i]] = {};
      }
      current = current[parts[i]];
    }
    current[parts.last] = value;
    await save();
  }

  /// Get the full config as a formatted string (for display).
  String toDisplayString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(_config);
  }

  /// Reset to defaults.
  Future<void> reset() async {
    _config = Map<String, dynamic>.from(_defaults);
    await save();
  }

  /// Deep merge source into target.
  void _deepMerge(Map<String, dynamic> target, Map<String, dynamic> source) {
    for (final key in source.keys) {
      if (source[key] is Map && target[key] is Map) {
        _deepMerge(target[key] as Map<String, dynamic>, source[key] as Map<String, dynamic>);
      } else {
        target[key] = source[key];
      }
    }
  }
}
