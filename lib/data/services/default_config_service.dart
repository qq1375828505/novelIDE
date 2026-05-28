import 'package:novel_ide/data/models/ai_config_model.dart';
import 'package:novel_ide/data/datasources/secure_storage_datasource.dart';
import 'package:novel_ide/data/datasources/database_helper.dart';

/// 默认配置服务
/// 内置开箱即用的AI模型配置
class DefaultConfigService {
  static const String _defaultZhipuId = 'default_zhipu_glm4_flash';
  
  /// 内置的智谱AI GLM-4-Flash 配置
  /// 注意：此API Key为共享密钥，有额度限制
  static const String _builtinZhipuKey = 'aee835b112ca4afe8ba81acede4b05df.GV9QQ4RFWhyjY1CA';
  
  /// 检查并初始化默认配置
  /// 如果用户没有配置任何AI模型，自动添加智谱AI
  static Future<void> initDefaultConfig() async {
    try {
      final db = DatabaseHelper();
      final configs = await db.getAiConfigs();
      
      // 如果已有配置，不覆盖
      if (configs.isNotEmpty) return;
      
      // 添加默认智谱AI配置
      final defaultConfig = AiConfig(
        id: _defaultZhipuId,
        name: '智谱AI GLM-4.7-Flash (内置免费)',
        apiUrl: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
        modelName: 'glm-4.7-flash',
        protocol: ApiProtocol.openaiCompatible,
      );
      
      // 保存配置到数据库
      await db.insertAiConfig(db.toDbMap(defaultConfig));
      
      // 保存API Key到SecureStorage
      await SecureStorageDataSource().writeApiKey(_defaultZhipuId, _builtinZhipuKey);
      
      print('DefaultConfigService: 已添加默认智谱AI配置');
    } catch (e) {
      print('DefaultConfigService init error: $e');
    }
  }
  
  /// 获取内置API Key（用于测试或恢复）
  static String? getBuiltinKey() => _builtinZhipuKey;
  
  /// 检查是否是内置配置
  static bool isBuiltinConfig(String configId) => configId == _defaultZhipuId;
}
