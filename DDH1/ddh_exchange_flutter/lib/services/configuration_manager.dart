import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 应用配置管理器 - 基于iOS ConfigurationManager完全重构
class ConfigurationManager {
  static final ConfigurationManager _instance = ConfigurationManager._internal();
  factory ConfigurationManager() => _instance;
  ConfigurationManager._internal();

  // 缓存包信息
  PackageInfo? _packageInfo;

  // 初始化配置管理器
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      print('🔧 [ConfigurationManager] 初始化失败: $e');
    }
  }

  // MARK: - 新服务器配置 (47.93.36.73)
  String get apiBaseURL => 'https://a.ddg.org.cn/api';
  
  String get websiteBaseURL => 'https://a.ddg.org.cn';
  
  String get wechatRedirectURL => 'https://a.ddg.org.cn/wechat/';

  // MARK: - 服务器信息
  String get serverIP => '47.93.36.73';
  
  String get serverDescription => '新服务器 (47.93.36.73)';

  // MARK: - 数据库配置
  String get databaseHost => '47.93.36.73';
  
  int get databasePort => 3306;

  // MARK: - 审核模式配置
  String get reviewModeToken => 'review_mode_token_2024';
  
  static const List<String> _reviewAccounts = [
    'review@apple.com',
    'test@apple.com',
    'appstore@apple.com',
    'reviewer@apple.com',
  ];
  
  static const String _reviewPassword = 'Review123!';
  static const String _reviewVerificationCode = '888888';

  // MARK: - 审核账号检查
  bool isReviewAccount(String email) {
    return _reviewAccounts.contains(email.toLowerCase());
  }
  
  String getReviewAccountPassword() => _reviewPassword;
  
  String getReviewVerificationCode() => _reviewVerificationCode;

  // MARK: - 测试URL配置
  String get externalTestURL => 'https://a.ddg.org.cn/api/health';
  
  String get httpsTestURL => 'https://a.ddg.org.cn/api/health';
  
  String get networkDiagnosticURL => 'https://a.ddg.org.cn/api/health';

  // MARK: - 环境配置
  bool get isDebugMode => kDebugMode;
  
  bool get isProductionMode => !isDebugMode;
  
  bool get isReleaseMode => kReleaseMode;
  
  bool get isProfileMode => kProfileMode;

  // MARK: - 应用配置
  String get appVersion => _packageInfo?.version ?? '1.0.0';
  
  String get buildNumber => _packageInfo?.buildNumber ?? '1';
  
  String get bundleIdentifier => _packageInfo?.packageName ?? 'com.wuruolei.ddhexchange';
  
  String get appName => _packageInfo?.appName ?? 'DDH Exchange';

  // MARK: - 网络配置
  Duration get requestTimeout => const Duration(seconds: 30);
  
  Duration get connectTimeout => const Duration(seconds: 20);
  
  Duration get receiveTimeout => const Duration(seconds: 45);

  // MARK: - 缓存配置
  Duration get defaultCacheExpiry => const Duration(hours: 24);
  
  Duration get imageCacheExpiry => const Duration(days: 7);
  
  Duration get qrcodeCacheExpiry => const Duration(hours: 1);
  
  int get maxCacheSize => 100 * 1024 * 1024; // 100MB

  // MARK: - UI配置
  Duration get animationDuration => const Duration(milliseconds: 300);
  
  Duration get splashScreenDuration => const Duration(seconds: 2);
  
  int get maxRetryAttempts => 3;

  // MARK: - 微信配置
  String get wechatAppId => 'wx_app_id_placeholder'; // 实际使用时需要替换
  
  String get wechatAppSecret => 'wx_app_secret_placeholder'; // 实际使用时需要替换
  
  String get wechatUniversalLink => 'https://a.ddg.org.cn/wechat/';

  // MARK: - Apple登录配置
  String get appleSignInServiceId => 'com.wuruolei.ddhexchange.signin';
  
  String get appleSignInRedirectUri => 'https://a.ddg.org.cn/auth/apple/callback';

  // MARK: - 推送通知配置
  bool get pushNotificationsEnabled => true;
  
  String get fcmSenderId => 'fcm_sender_id_placeholder'; // 实际使用时需要替换

  // MARK: - 安全配置
  bool get sslPinningEnabled => isProductionMode;
  
  bool get certificateValidationEnabled => isProductionMode;
  
  Duration get tokenRefreshThreshold => const Duration(minutes: 5);

  // MARK: - 调试配置
  bool get networkLoggingEnabled => isDebugMode;
  
  bool get crashlyticsEnabled => isProductionMode;
  
  bool get analyticsEnabled => isProductionMode;

  // MARK: - 特性开关
  bool get wechatLoginEnabled => true;
  
  bool get appleLoginEnabled => true;
  
  bool get biometricAuthEnabled => true;
  
  bool get darkModeEnabled => true;
  
  bool get multiLanguageEnabled => false; // 暂时禁用多语言

  // MARK: - API版本配置
  String get apiVersion => 'v1';
  
  String get minSupportedApiVersion => 'v1';
  
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'DDH-Exchange-Flutter/$appVersion ($bundleIdentifier; build $buildNumber)',
    'X-API-Version': apiVersion,
    'X-Platform': _getPlatformName(),
  };

  // MARK: - 平台检测
  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }

  // MARK: - 环境检测方法
  bool get isSimulator {
    // 在Flutter中，可以通过kDebugMode和其他方式检测
    return kDebugMode && !kIsWeb;
  }
  
  bool get isPhysicalDevice => !isSimulator && !kIsWeb;
  
  bool get isWebPlatform => kIsWeb;

  // MARK: - 配置验证
  bool validateConfiguration() {
    try {
      // 验证必要的配置项
      if (apiBaseURL.isEmpty) return false;
      if (websiteBaseURL.isEmpty) return false;
      if (bundleIdentifier.isEmpty) return false;
      
      // 验证URL格式
      final apiUri = Uri.tryParse(apiBaseURL);
      final websiteUri = Uri.tryParse(websiteBaseURL);
      if (apiUri == null || !apiUri.hasAbsolutePath) return false;
      if (websiteUri == null || !websiteUri.hasAbsolutePath) return false;
      
      return true;
    } catch (e) {
      print('🔧 [ConfigurationManager] 配置验证失败: $e');
      return false;
    }
  }

  // MARK: - 配置信息输出
  Map<String, dynamic> getConfigurationInfo() {
    return {
      'app': {
        'name': appName,
        'version': appVersion,
        'buildNumber': buildNumber,
        'bundleIdentifier': bundleIdentifier,
      },
      'environment': {
        'isDebugMode': isDebugMode,
        'isProductionMode': isProductionMode,
        'isReleaseMode': isReleaseMode,
        'platform': _getPlatformName(),
        'isSimulator': isSimulator,
        'isWebPlatform': isWebPlatform,
      },
      'server': {
        'apiBaseURL': apiBaseURL,
        'websiteBaseURL': websiteBaseURL,
        'serverIP': serverIP,
        'serverDescription': serverDescription,
      },
      'features': {
        'wechatLoginEnabled': wechatLoginEnabled,
        'appleLoginEnabled': appleLoginEnabled,
        'biometricAuthEnabled': biometricAuthEnabled,
        'darkModeEnabled': darkModeEnabled,
        'multiLanguageEnabled': multiLanguageEnabled,
      },
      'network': {
        'requestTimeout': requestTimeout.inSeconds,
        'connectTimeout': connectTimeout.inSeconds,
        'receiveTimeout': receiveTimeout.inSeconds,
        'networkLoggingEnabled': networkLoggingEnabled,
      },
    };
  }

  // MARK: - 调试输出
  void printConfiguration() {
    if (!isDebugMode) return;
    
    print('🔧 [ConfigurationManager] 应用配置信息:');
    final config = getConfigurationInfo();
    config.forEach((key, value) {
      print('  $key: $value');
    });
  }

  // MARK: - 动态配置更新（预留接口）
  Future<void> updateConfigurationFromServer() async {
    try {
      // 预留接口：从服务器获取动态配置
      print('🔧 [ConfigurationManager] 动态配置更新功能待实现');
    } catch (e) {
      print('🔧 [ConfigurationManager] 动态配置更新失败: $e');
    }
  }
}
