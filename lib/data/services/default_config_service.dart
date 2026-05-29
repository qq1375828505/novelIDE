import 'package:novel_ide/data/models/ai_config_model.dart';
import 'package:novel_ide/data/datasources/secure_storage_datasource.dart';
import 'package:novel_ide/data/datasources/database_helper.dart';

/// 默认配置服务
/// 内置开箱即用的AI模型配置，每个模型独立API Key
/// 注意：这些是智谱AI免费公共Key，非个人密钥
class DefaultConfigService {
  /// 智谱AI免费模型配置（5个模型，每个独立API Key）
  /// 可通过 --dart-define 覆盖：--dart-define=ZHIPU_KEY_0=xxx
  static final List<Map<String, String>> _freeZhipuModels = [
    {
      'id': 'glm-4.7-flash',
      'name': 'GLM-4.7-Flash',
      'desc': '最新版，128K上下文',
      'envKey': 'ZHIPU_KEY_0',
      'fallback': '72c84c5eb0e24ff2b56a2b5470512c63.BZeyUHDmMWERIhoY',
    },
    {
      'id': 'glm-4.6v-flash',
      'name': 'GLM-4.6V-Flash',
      'desc': '多模态版，支持图片理解',
      'envKey': 'ZHIPU_KEY_1',
      'fallback': '3e57ea61894548b6b0b7947b2a011f93.ESTpLrBVnCOomHEn',
    },
    {
      'id': 'glm-4.1v-thinking-flash',
      'name': 'GLM-4.1V-Thinking-Flash',
      'desc': '思考版，推理能力强',
      'envKey': 'ZHIPU_KEY_2',
      'fallback': '292c246a9995414da2b9974d61c845b7.OulhfAni1WxDeMbt',
    },
    {
      'id': 'glm-4-flash-250414',
      'name': 'GLM-4-Flash-250414',
      'desc': '稳定版，128K上下文',
      'envKey': 'ZHIPU_KEY_3',
      'fallback': '82cd34522a364a868b4c2ba0a267b066.6L0NzIeknkJAPJAP',
    },
    {
      'id': 'glm-4v-flash',
      'name': 'GLM-4V-Flash',
      'desc': '视觉版，支持图文对话',
      'envKey': 'ZHIPU_KEY_4',
      'fallback': 'aee835b112ca4afe8ba81acede4b05df.GV9QQ4RFWhyjY1CA',
    },
  ];

  /// 获取模型的API Key：优先环境变量，fallback到内置
  static String _resolveKey(Map<String, String> model) {
    final envKey = model['envKey']!;
    final env = String.fromEnvironment(envKey);
    return env.isNotEmpty ? env : model['fallback']!;
  }

  /// 检查并初始化默认配置
  /// 如果用户没有配置任何AI模型，自动添加第一个智谱AI模型
  static Future<void> initDefaultConfig() async {
    try {
      final db = DatabaseHelper();
      final configs = await db.getAllAiConfigs();

      // 如果已有配置，不覆盖
      if (configs.isNotEmpty) return;

      // 添加默认第一个模型
      await _addModelByIndex(0);

      print('DefaultConfigService: 已添加默认智谱AI配置');
    } catch (e) {
      print('DefaultConfigService init error: $e');
    }
  }

  /// 根据索引添加指定模型
  static Future<void> _addModelByIndex(int index) async {
    if (index < 0 || index >= _freeZhipuModels.length) return;

    final model = _freeZhipuModels[index];
    final db = DatabaseHelper();

    final config = AiConfig(
      id: 'zhipu_${model['id']}',
      name: '智谱AI ${model['name']} (内置免费)',
      apiUrl: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
      modelName: model['id']!,
      protocol: ApiProtocol.openaiCompatible,
    );

    await db.insertAiConfig(db.toDbMap(config));
    await SecureStorageDataSource().writeApiKey(config.id, _resolveKey(model));
  }

  /// 添加额外的免费模型配置（供用户手动添加）
  static Future<void> addExtraFreeModel(String modelId) async {
    final index = _freeZhipuModels.indexWhere((m) => m['id'] == modelId);
    if (index < 0) return;
    await _addModelByIndex(index);
  }

  /// 添加所有免费模型
  static Future<int> addAllFreeModels() async {
    int addedCount = 0;
    for (int i = 0; i < _freeZhipuModels.length; i++) {
      try {
        await _addModelByIndex(i);
        addedCount++;
      } catch (e) {
        print('添加模型 ${_freeZhipuModels[i]['name']} 失败: $e');
      }
    }
    return addedCount;
  }

  /// 获取所有免费模型列表（用于用户切换）
  static List<Map<String, String>> getAllFreeModels() {
    return _freeZhipuModels.map((m) => {
      'id': m['id']!,
      'name': m['name']!,
      'desc': m['desc']!,
    }).toList();
  }

  /// 检查是否是内置配置
  static bool isBuiltinConfig(String configId) {
    return _freeZhipuModels.any((m) => 'zhipu_${m['id']}' == configId);
  }

  /// 获取指定模型的API Key（用于测试）
  static String? getModelKey(String modelId) {
    final model = _freeZhipuModels.firstWhere(
      (m) => m['id'] == modelId,
      orElse: () => {},
    );
    return model.isEmpty ? null : _resolveKey(model);
  }
}
