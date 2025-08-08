/// 应用常量定义
class AppConstants {
  // 应用信息
  static const String appName = '点点换';
  static const String appVersion = '1.0.0';
  static const String appDescription = '积分兑换易货平台';

  // API配置
  static const String baseUrl = 'https://api.diandianhuan.com';
  static const String apiVersion = 'v1';
  static const Duration requestTimeout = Duration(seconds: 30);

  // 本地存储键
  static const String userTokenKey = 'user_token';
  static const String userInfoKey = 'user_info';
  static const String settingsKey = 'app_settings';

  // 广告轮播配置
  static const Duration adCarouselInterval = Duration(seconds: 4);
  static const Duration adCarouselAnimationDuration = Duration(milliseconds: 300);

  // 页面配置
  static const int itemsPerPage = 20;
  static const int maxRetryCount = 3;

  // 默认用户信息
  static const String defaultUsername = '点点用户';
  static const String defaultUserId = '1001';
  static const int defaultUserPoints = 1250;
  static const String defaultUserType = 'VIP';
  static const String defaultJoinDate = '2024年1月';

  // 统计数据
  static const int defaultPublishedItems = 5;
  static const int defaultOngoingTransactions = 2;
  static const int defaultCompletedTransactions = 18;

  // 积分配置
  static const int dailyCheckInPoints = 10;
  static const int inviteFriendPoints = 100;
  static const int completeTransactionPoints = 50;

  // UI配置
  static const double defaultBorderRadius = 16.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;

  // 错误消息
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';
  static const String serverErrorMessage = '服务器错误，请稍后重试';
  static const String unknownErrorMessage = '未知错误，请联系客服';

  // 成功消息
  static const String loginSuccessMessage = '登录成功';
  static const String exchangeSuccessMessage = '兑换成功';
  static const String publishSuccessMessage = '发布成功';
}
