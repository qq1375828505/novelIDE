import 'package:shared_preferences/shared_preferences.dart';

/// 公告服务
/// 管理应用内公告的显示逻辑
class AnnouncementService {
  static const String _prefKey = 'announcement_shown_version';
  
  /// 当前公告版本号（每次更新公告内容时递增）
  static const int _currentVersion = 1;
  
  /// 公告标题
  static const String _title = '免费AI模型使用说明';
  
  /// 公告内容
  static const String _content = 
      '本软件内置了智谱AI免费大模型，开箱即用！\n\n'
      '如果遇到以下情况：\n'
      '• 提示"额度用完"\n'
      '• 提示"请求过于频繁"\n'
      '• AI无法正常回复\n\n'
      '请前往智谱AI官网免费申请自己的API Key：\n'
      'https://bigmodel.cn/login?redirect=/apikey/platform\n\n'
      '申请步骤：\n'
      '1. 打开上方链接\n'
      '2. 填写手机号注册\n'
      '3. 进入"API Keys"页面\n'
      '4. 创建并复制 API Key\n'
      '5. 在软件设置 → AI模型配置中添加\n'
      '（接口地址和模型名称会自动填好）';
  
  /// 注册链接
  static const String _registerUrl = 
      'https://bigmodel.cn/login?redirect=%2Fapikey%2Fplatform';
  
  /// 检查是否需要显示公告（首次安装或公告版本更新时显示）
  static Future<bool> shouldShowAnnouncement() async {
    final prefs = await SharedPreferences.getInstance();
    final shownVersion = prefs.getInt(_prefKey) ?? 0;
    return shownVersion < _currentVersion;
  }
  
  /// 标记公告已显示
  static Future<void> markAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, _currentVersion);
  }
  
  /// 获取公告内容
  static Map<String, String> getAnnouncement() {
    return {
      'title': _title,
      'content': _content,
      'url': _registerUrl,
    };
  }
  
  /// 获取注册链接
  static String get registerUrl => _registerUrl;
  
  /// 获取公告标题
  static String get title => _title;
  
  /// 获取公告正文
  static String get content => _content;
}
