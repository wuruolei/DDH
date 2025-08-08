import 'dart:convert';
import 'dart:math';

// Compatibility mode: Comment out native plugin imports
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:device_info_plus/device_info_plus.dart';

import '../models/user.dart';

class StorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userInfoKey = 'user_info';
  static const String _deviceIdKey = 'device_id';
  static const String _firstLaunchKey = 'first_launch';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _lastExchangeRateKey = 'last_exchange_rate';

  // Compatibility mode: Use in-memory storage instead of native plugins
  final Map<String, String> _memoryStorage = {};
  final Map<String, String> _secureMemoryStorage = {};

  Future<void> init() async {
    // Compatibility mode: Initialize in-memory storage
    print('StorageService initialized in compatibility mode');
  }

  // 认证相关 - Compatibility mode
  Future<void> saveAuthToken(String token) async {
    _secureMemoryStorage[_authTokenKey] = token;
  }

  Future<String?> getAuthToken() async {
    return _secureMemoryStorage[_authTokenKey];
  }

  Future<void> clearAuthToken() async {
    _secureMemoryStorage.remove(_authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    _secureMemoryStorage[_refreshTokenKey] = token;
  }

  Future<String?> getRefreshToken() async {
    return _secureMemoryStorage[_refreshTokenKey];
  }

  Future<void> clearRefreshToken() async {
    _secureMemoryStorage.remove(_refreshTokenKey);
  }

  // 用户信息 - Compatibility mode
  Future<void> saveUserInfo(User user) async {
    final userJson = jsonEncode(user.toJson());
    _secureMemoryStorage[_userInfoKey] = userJson;
  }

  Future<User?> getUserInfo() async {
    final userJson = _secureMemoryStorage[_userInfoKey];
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (e) {
        print('解析用户信息失败: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> clearUserInfo() async {
    _secureMemoryStorage.remove(_userInfoKey);
  }

  // 别名方法，用于兼容AuthService的调用
  Future<void> saveUser(User user) async {
    await saveUserInfo(user);
  }

  Future<void> clearUser() async {
    await clearUserInfo();
  }

  // 设备信息 - Compatibility mode
  Future<String> getDeviceId() async {
    String? deviceId = _memoryStorage[_deviceIdKey];
    
    if (deviceId == null) {
      // final deviceInfo = DeviceInfoPlugin(); // 简化版本暂不支持
      
      try {
        // 简化版本 - 直接生成设备ID，不依赖原生插件
        deviceId = _generateDeviceId();
        
        // Compatibility mode: Use simple device ID generation
        _memoryStorage[_deviceIdKey] = deviceId;
      } catch (e) {
        print('获取设备ID失败: $e');
        deviceId = _generateDeviceId();
        _memoryStorage[_deviceIdKey] = deviceId;
      }
    }
    
    return deviceId!;
  }

  String _generateDeviceId() {
    return 'device_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
  }

  // 应用设置 - Compatibility mode
  Future<void> setFirstLaunch(bool isFirst) async {
    _memoryStorage[_firstLaunchKey] = isFirst.toString();
  }

  bool get isFirstLaunch => _memoryStorage[_firstLaunchKey] == 'true' ? false : true;

  Future<void> setBiometricEnabled(bool enabled) async {
    _memoryStorage[_biometricEnabledKey] = enabled.toString();
  }

  bool get isBiometricEnabled => _memoryStorage[_biometricEnabledKey] == 'true';

  Future<void> setThemeMode(String mode) async {
    _memoryStorage[_themeModeKey] = mode;
  }

  String get themeMode => _memoryStorage[_themeModeKey] ?? 'system';

  Future<void> setLanguageCode(String code) async {
    _memoryStorage[_languageCodeKey] = code;
  }

  String get languageCode => _memoryStorage[_languageCodeKey] ?? 'zh';

  Future<void> setNotificationsEnabled(bool enabled) async {
    _memoryStorage[_notificationsEnabledKey] = enabled.toString();
  }

  bool get isNotificationsEnabled => _memoryStorage[_notificationsEnabledKey] != 'false';

  // 缓存数据 - Compatibility mode
  Future<void> saveLastExchangeRate(Map<String, dynamic> rates) async {
    _memoryStorage[_lastExchangeRateKey] = jsonEncode(rates);
  }

  Map<String, dynamic>? getLastExchangeRate() {
    final ratesJson = _memoryStorage[_lastExchangeRateKey];
    if (ratesJson != null) {
      try {
        return jsonDecode(ratesJson);
      } catch (e) {
        print('解析汇率数据失败: $e');
        return null;
      }
    }
    return null;
  }

  // 清除所有数据 - Compatibility mode
  Future<void> clearAll() async {
    _secureMemoryStorage.clear();
    _memoryStorage.clear();
  }

  // 清除用户相关数据（保留设置）
  Future<void> clearUserData() async {
    await clearAuthToken();
    await clearRefreshToken();
    await clearUserInfo();
  }

  // 通用字符串存储方法 - 用于测试和通用用途
  Future<void> saveString(String key, String value) async {
    _memoryStorage[key] = value;
  }

  Future<String?> getString(String key) async {
    return _memoryStorage[key];
  }

  Future<void> removeString(String key) async {
    _memoryStorage.remove(key);
  }

  // 通用remove方法，兼容其他服务调用
  Future<void> remove(String key) async {
    _memoryStorage.remove(key);
    _secureMemoryStorage.remove(key);
  }

  // 列表数据存储方法
  Future<void> saveList(String key, List<Map<String, dynamic>> list) async {
    final listJson = jsonEncode(list);
    _memoryStorage[key] = listJson;
  }

  Future<List<Map<String, dynamic>>> getList(String key) async {
    final listJson = _memoryStorage[key];
    if (listJson != null) {
      try {
        final decoded = jsonDecode(listJson);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(
            decoded.map((item) => Map<String, dynamic>.from(item))
          );
        }
      } catch (e) {
        print('解析列表数据失败: $e');
      }
    }
    return [];
  }

  // Map数据存储方法
  Future<void> saveMap(String key, Map<String, dynamic> map) async {
    final mapJson = jsonEncode(map);
    _memoryStorage[key] = mapJson;
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    final mapJson = _memoryStorage[key];
    if (mapJson != null) {
      try {
        final decoded = jsonDecode(mapJson);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (e) {
        print('解析Map数据失败: $e');
      }
    }
    return null;
  }

  // 调试信息
  Future<Map<String, dynamic>> getDebugInfo() async {
    return {
      'device_id': await getDeviceId(),
      'auth_token_exists': await getAuthToken() != null,
      'user_info_exists': await getUserInfo() != null,
      'is_first_launch': isFirstLaunch,
      'theme_mode': themeMode,
      'language_code': languageCode,
      'biometric_enabled': isBiometricEnabled,
      'notifications_enabled': isNotificationsEnabled,
    };
  }
}
