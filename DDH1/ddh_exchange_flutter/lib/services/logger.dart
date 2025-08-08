import 'dart:developer' as developer;

/// 简化的日志服务
class Logger {
  static const String _tag = 'DDH_Exchange';

  /// 信息日志
  static void info(String message) {
    developer.log('[INFO] $message', name: _tag);
  }

  /// 警告日志
  static void warning(String message) {
    developer.log('[WARNING] $message', name: _tag);
  }

  /// 错误日志
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      '[ERROR] $message',
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 调试日志
  static void debug(String message) {
    developer.log('[DEBUG] $message', name: _tag);
  }

  /// 网络请求日志
  static void network(String method, String url, {Map<String, dynamic>? params}) {
    final paramsStr = params != null ? ' with params: $params' : '';
    info('$method request to: $url$paramsStr');
  }

  /// 用户操作日志
  static void userAction(String action, {Map<String, dynamic>? data}) {
    final dataStr = data != null ? ' - Data: $data' : '';
    info('User Action: $action$dataStr');
  }
}
