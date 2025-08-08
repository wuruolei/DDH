import 'dart:convert';

// Compatibility mode: Comment out dio import
// import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/api_response.dart';
import 'storage_service.dart';
import '../utils/logger.dart';

class NetworkService {
  // Web compatibility: Remove HttpClient usage
  final StorageService _storageService;

  NetworkService({StorageService? storageService}) 
      : _storageService = storageService ?? StorageService();

  Future<void> init() async {
    // Web compatibility: No HttpClient initialization needed
    print('NetworkService initialized in Web compatibility mode');
  }

  void _setupInterceptors() {
    // Compatibility mode: Simplified interceptor setup
    print('Network interceptors initialized in compatibility mode');
  }

  // Compatibility mode: Helper method to get headers
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add auth token if available
    final token = await _storageService.getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    // Add device ID
    headers['X-Device-ID'] = await _storageService.getDeviceId();
    
    return headers;
  }

  // Compatibility mode: Simplified error handler
  void _handleError(int? statusCode) {
    if (statusCode == 401) {
      // Token过期，清除本地token
      _storageService.clearAuthToken();
    }
  }

  // GET请求 - Compatibility mode
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    // Options? options, // Removed dio dependency
  }) async {
    try {
      // Compatibility mode: Return mock response
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      print('GET request to: $path with params: $queryParameters');
      
      return ApiResponse<T>(
        code: 200,
        success: true,
        message: 'Mock response for compatibility mode',
        data: null, // Mock data
      );
    } catch (e) {
      throw Exception('Network error in compatibility mode: $e');
    }
  }

  // POST请求 - Compatibility mode
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    // Options? options, // Removed dio dependency
  }) async {
    try {
      // Compatibility mode: Return mock response
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      print('POST request to: $path with data: $data, params: $queryParameters');
      
      return ApiResponse<T>(
        code: 200,
        success: true,
        message: '成功',
        data: null, // Mock data
      );
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  // PUT请求 - Compatibility mode
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // Compatibility mode: Return mock response
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      print('PUT request to: $path with data: $data, params: $queryParameters');
      
      return ApiResponse<T>(
        code: 200,
        success: true,
        message: '成功',
        data: null, // Mock data
      );
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  // DELETE请求 - Compatibility mode
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // Compatibility mode: Return mock response
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      print('DELETE request to: $path with data: $data, params: $queryParameters');
      
      return ApiResponse<T>(
        code: 200,
        success: true,
        message: '成功',
        data: null, // Mock data
      );
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  // 上传文件 - Web compatibility mode
  Future<ApiResponse<T>> upload<T>(
    String path, {
    required dynamic file, // Web compatibility: use dynamic instead of File
    String? fileKey = 'file',
    Map<String, dynamic>? data,
  }) async {
    try {
      // Web compatibility: Return mock response without file operations
      await Future.delayed(Duration(milliseconds: 1000)); // Simulate upload delay
      
      print('Upload request to: $path (Web compatibility mode)');
      
      return ApiResponse<T>(
        code: 200,
        success: true,
        message: '上传成功 (Web兼容模式)',
        data: null, // Mock data
      );
    } catch (e) {
      throw NetworkException('Upload error: $e');
    }
  }

  // 创建网络异常的辅助方法
  NetworkException createNetworkException(String message) {
    return NetworkException('Network error: $message');
  }
  
  // 设置认证token
  void setAuthToken(String? token) {
    // Compatibility mode: 在兼容模式中，我们只是存储token但不实际使用
    print('NetworkService: setAuthToken called with token: ${token != null ? '[TOKEN_SET]' : 'null'}');
  }
  
  // 密码登录
  Future<dynamic> loginWithPassword(String username, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('NetworkService: loginWithPassword called');
    
    return {
      'success': true,
      'message': '登录成功',
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': '1',
        'email': username,
        'username': 'Test User',
        'userType': 'normal',
        'avatar': null,
      }
    };
  }
  
  // 验证码登录
  Future<dynamic> login(String email, String verificationCode) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('NetworkService: login with verification code called');
    
    return {
      'success': true,
      'message': '登录成功',
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': '1',
        'email': email,
        'username': 'Test User',
        'userType': 'normal',
        'avatar': null,
      }
    };
  }
  
  // 注册用户
  Future<dynamic> registerWithPassword(String email, String password, String verificationCode) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('NetworkService: registerWithPassword called');
    
    return {
      'success': true,
      'message': '注册成功',
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': '2',
        'email': email,
        'username': 'New User',
        'userType': 'normal',
        'avatar': null,
      }
    };
  }
  
  // 微信登录
  Future<dynamic> wechatLogin(String code, String state) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('NetworkService: wechatLogin called');
    
    return {
      'success': true,
      'message': '微信登录成功',
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': '3',
        'email': 'wechat@example.com',
        'username': 'WeChat User',
        'userType': 'normal',
        'avatar': null,
      }
    };
  }
  
  // 获取用户资料
  Future<dynamic> getUserProfile() async {
    await Future.delayed(Duration(milliseconds: 300));
    print('NetworkService: getUserProfile called');
    
    return {
      'success': true,
      'message': '获取用户信息成功',
      'data': {
        'id': '1',
        'email': 'test@example.com',
        'username': 'Test User',
        'userType': 'normal',
        'avatar': null,
      }
    };
  }
  
  // 发送验证码
  Future<dynamic> sendVerificationCode(String email) async {
    await Future.delayed(Duration(milliseconds: 300));
    print('NetworkService: sendVerificationCode called');
    
    return {
      'success': true,
      'message': '验证码发送成功',
    };
  }
  
  // 发送重置密码验证码
  Future<dynamic> sendResetPasswordCode(String email) async {
    await Future.delayed(Duration(milliseconds: 300));
    print('NetworkService: sendResetPasswordCode called');
    
    return {
      'success': true,
      'message': '重置密码验证码发送成功',
    };
  }
  
  // 重置密码
  Future<dynamic> resetPassword(String email, String verificationCode, String newPassword) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('NetworkService: resetPassword called');
    
    return {
      'success': true,
      'message': '密码重置成功',
    };
  }
  
  // 修改密码
  Future<dynamic> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('NetworkService: changePassword called');
    
    return {
      'success': true,
      'message': '密码修改成功',
    };
  }

  // 网络诊断 - Compatibility mode
  Future<bool> checkConnectivity() async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      print('Network connectivity check (mock): OK');
      return true; // Always return true in compatibility mode
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    // Web compatibility: No HttpClient to close
    print('NetworkService disposed');
  }
}

// 自定义异常类
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  
  @override
  String toString() => '[$statusCode] $message';
}

// Compatibility mode: Removed RetryInterceptor (dio dependency)
