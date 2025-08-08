import 'package:flutter/foundation.dart';

class AppConfig {
  static late final String baseUrl;
  static late final String wechatAppId;
  static late final String wechatUniversalLink;
  static late final bool isProduction;
  static late final String appVersion;
  static late final String buildNumber;

  static Future<void> init() async {
    // 从环境变量或配置文件加载
    baseUrl = const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://api.ddh.exchange',
    );

    wechatAppId = const String.fromEnvironment(
      'WECHAT_APP_ID',
      defaultValue: 'wx1234567890abcdef',
    );

    wechatUniversalLink = const String.fromEnvironment(
      'WECHAT_UNIVERSAL_LINK',
      defaultValue: 'https://ddh.exchange/app/',
    );

    isProduction = const bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);
    
    // 版本信息将在运行时获取
    appVersion = '1.0.0';
    buildNumber = '1';

    _validateConfig();
  }

  static void _validateConfig() {
    assert(baseUrl.isNotEmpty, 'BASE_URL不能为空');
    assert(wechatAppId.isNotEmpty, 'WECHAT_APP_ID不能为空');
    assert(wechatUniversalLink.isNotEmpty, 'WECHAT_UNIVERSAL_LINK不能为空');
  }

  static String get apiBaseUrl => baseUrl;
  
  static Map<String, String> get apiHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-App-Version': appVersion,
        'X-Platform': _getPlatformName(),
      };

  static String _getPlatformName() {
    if (kIsWeb) {
      return 'web';
    }
    // For non-web platforms, use a safe fallback
    try {
      return defaultTargetPlatform.toString();
    } catch (e) {
      return 'unknown';
    }
  }

  static bool get enableLogging => !isProduction;
  
  static Duration get apiTimeout => const Duration(seconds: 30);
}

class ApiEndpoints {
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  
  static const String user = '/user';
  static const String userProfile = '/user/profile';
  static const String userSettings = '/user/settings';
  
  static const String exchange = '/exchange';
  static const String exchangeRates = '/exchange/rates';
  static const String exchangeHistory = '/exchange/history';
  static const String exchangeCreate = '/exchange/create';
  
  static const String wechatLogin = '/auth/wechat/login';
  static const String wechatBind = '/auth/wechat/bind';
}
