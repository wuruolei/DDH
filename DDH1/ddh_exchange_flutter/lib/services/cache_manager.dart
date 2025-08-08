import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

/// 缓存管理器 - Web兼容版本（仅内存缓存）
/// 基于iOS AvatarCacheManager重构，针对Web环境优化
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // MARK: - 属性
  final Map<String, Uint8List> _memoryCache = <String, Uint8List>{};
  final Map<String, DateTime> _memoryCacheTimestamps = <String, DateTime>{};
  final Map<String, String> _jsonCache = <String, String>{};
  
  static const Duration _maxCacheAge = Duration(days: 7); // 7天
  static const int _maxMemoryCacheCount = 50; // 内存最多缓存50个项目
  static const int _maxMemoryCacheSize = 50 * 1024 * 1024; // 50MB内存缓存限制
  
  bool _isInitialized = false;

  // MARK: - 初始化
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _cleanExpiredCache();
      _isInitialized = true;
      print('💾 [CacheManager] Web兼容缓存管理器初始化完成');
    } catch (e) {
      print('💾 [CacheManager] 初始化失败: $e');
    }
  }

  // MARK: - 头像缓存管理
  
  /// 获取缓存的头像
  /// - Parameter userID: 用户ID
  /// - Returns: 缓存的头像数据，未找到返回null
  Future<Uint8List?> getCachedAvatar(String userID) async {
    final key = _generateAvatarKey(userID);
    return _getFromMemoryCache(key);
  }

  /// 缓存头像数据
  /// - Parameters:
  ///   - userID: 用户ID
  ///   - avatarData: 头像数据
  Future<void> cacheAvatar(String userID, Uint8List avatarData) async {
    final key = _generateAvatarKey(userID);
    await _saveToMemoryCache(key, avatarData);
    print('💾 [CacheManager] 头像已缓存: $userID');
  }

  /// 删除指定用户的头像缓存
  /// - Parameter userID: 用户ID
  Future<void> removeAvatarCache(String userID) async {
    final key = _generateAvatarKey(userID);
    _removeFromMemoryCache(key);
    print('💾 [CacheManager] 头像缓存已删除: $userID');
  }

  // MARK: - 二维码缓存管理
  
  /// 获取缓存的二维码
  /// - Parameter qrID: 二维码ID
  /// - Returns: 缓存的二维码数据，未找到返回null
  Future<Uint8List?> getCachedQRCode(String qrID) async {
    final key = _generateQRKey(qrID);
    return _getFromMemoryCache(key);
  }

  /// 缓存二维码数据
  /// - Parameters:
  ///   - qrID: 二维码ID
  ///   - qrData: 二维码数据
  Future<void> cacheQRCode(String qrID, Uint8List qrData) async {
    final key = _generateQRKey(qrID);
    await _saveToMemoryCache(key, qrData);
    print('💾 [CacheManager] 二维码已缓存: $qrID');
  }

  /// 删除指定二维码缓存
  /// - Parameter qrID: 二维码ID
  Future<void> removeQRCodeCache(String qrID) async {
    final key = _generateQRKey(qrID);
    _removeFromMemoryCache(key);
    print('💾 [CacheManager] 二维码缓存已删除: $qrID');
  }

  // MARK: - JSON数据缓存管理
  
  /// 缓存JSON数据
  /// - Parameters:
  ///   - key: 缓存键
  ///   - data: 要缓存的数据
  Future<void> cacheJSON(String key, Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      _jsonCache[key] = jsonString;
      _memoryCacheTimestamps[key] = DateTime.now();
      print('💾 [CacheManager] JSON数据已缓存: $key');
    } catch (e) {
      print('💾 [CacheManager] JSON缓存失败: $e');
    }
  }

  /// 获取缓存的JSON数据
  /// - Parameter key: 缓存键
  /// - Returns: 缓存的数据，未找到或过期返回null
  Future<Map<String, dynamic>?> getCachedJSON(String key) async {
    try {
      final jsonString = _jsonCache[key];
      if (jsonString == null) return null;
      
      // 检查是否过期
      final timestamp = _memoryCacheTimestamps[key];
      if (timestamp != null && _isCacheExpired(timestamp)) {
        _jsonCache.remove(key);
        _memoryCacheTimestamps.remove(key);
        return null;
      }
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('💾 [CacheManager] JSON读取失败: $e');
      return null;
    }
  }

  /// 删除JSON缓存
  /// - Parameter key: 缓存键
  Future<void> removeJSONCache(String key) async {
    _jsonCache.remove(key);
    _memoryCacheTimestamps.remove(key);
    print('💾 [CacheManager] JSON缓存已删除: $key');
  }

  // MARK: - 缓存管理
  
  /// 清理所有缓存
  Future<void> clearAllCache() async {
    _memoryCache.clear();
    _memoryCacheTimestamps.clear();
    _jsonCache.clear();
    print('💾 [CacheManager] 所有缓存已清理');
  }

  /// 清理过期缓存
  Future<void> _cleanExpiredCache() async {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    // 检查内存缓存
    for (final entry in _memoryCacheTimestamps.entries) {
      if (now.difference(entry.value) > _maxCacheAge) {
        expiredKeys.add(entry.key);
      }
    }
    
    // 删除过期缓存
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _memoryCacheTimestamps.remove(key);
      _jsonCache.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      print('💾 [CacheManager] 已清理${expiredKeys.length}个过期缓存项');
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    final totalMemorySize = _memoryCache.values
        .fold<int>(0, (sum, data) => sum + data.length);
    
    return {
      'memoryItemCount': _memoryCache.length,
      'jsonItemCount': _jsonCache.length,
      'totalMemorySize': totalMemorySize,
      'maxMemorySize': _maxMemoryCacheSize,
      'memoryUsagePercent': (totalMemorySize / _maxMemoryCacheSize * 100).toStringAsFixed(1),
    };
  }

  // MARK: - 私有方法
  
  /// 生成头像缓存键
  String _generateAvatarKey(String userID) {
    return 'avatar_$userID';
  }

  /// 生成二维码缓存键
  String _generateQRKey(String qrID) {
    return 'qr_$qrID';
  }

  /// 生成缓存键的哈希值
  String _generateCacheKey(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 从内存缓存获取数据
  Uint8List? _getFromMemoryCache(String key) {
    final timestamp = _memoryCacheTimestamps[key];
    if (timestamp != null && _isCacheExpired(timestamp)) {
      _removeFromMemoryCache(key);
      return null;
    }
    return _memoryCache[key];
  }

  /// 保存到内存缓存
  Future<void> _saveToMemoryCache(String key, Uint8List data) async {
    // 检查缓存大小限制
    if (_memoryCache.length >= _maxMemoryCacheCount) {
      _evictOldestMemoryCache();
    }
    
    _memoryCache[key] = data;
    _memoryCacheTimestamps[key] = DateTime.now();
  }

  /// 从内存缓存删除数据
  void _removeFromMemoryCache(String key) {
    _memoryCache.remove(key);
    _memoryCacheTimestamps.remove(key);
  }

  /// 检查缓存是否过期
  bool _isCacheExpired(DateTime timestamp) {
    return DateTime.now().difference(timestamp) > _maxCacheAge;
  }

  /// 淘汰最旧的内存缓存项
  void _evictOldestMemoryCache() {
    if (_memoryCacheTimestamps.isEmpty) return;
    
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _memoryCacheTimestamps.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }
    
    if (oldestKey != null) {
      _removeFromMemoryCache(oldestKey);
      print('💾 [CacheManager] 淘汰最旧缓存项: $oldestKey');
    }
  }
}
