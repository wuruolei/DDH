import '../models/user.dart';
import 'network_service.dart';
import 'storage_service.dart';

class AuthResult {
  final String token;
  final String refreshToken;
  final User user;

  AuthResult({
    required this.token,
    required this.refreshToken,
    required this.user,
  });
}

class AuthService {
  final NetworkService _networkService;
  final StorageService _storageService;

  AuthService({
    NetworkService? networkService,
    StorageService? storageService,
  })  : _networkService = networkService ?? NetworkService(),
        _storageService = storageService ?? StorageService();

  // 密码登录
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _networkService.loginWithPassword(username, password);
      
      if (!response.success) {
        throw Exception(response.message);
      }
      
      if (response.token == null || response.user == null) {
        throw Exception('登录响应数据不完整');
      }
      
      // 保存认证信息
      await _storageService.saveAuthToken(response.token!);
      await _storageService.saveUser(response.user!);
      _networkService.setAuthToken(response.token!);
      
      return AuthResult(
        token: response.token!,
        refreshToken: response.token!, // 简化实现，使用同一token
        user: response.user!,
      );
    } catch (e) {
      throw Exception('登录失败: ${e.toString()}');
    }
  }
  
  // 验证码登录
  Future<AuthResult> loginWithVerificationCode({
    required String email,
    required String verificationCode,
  }) async {
    try {
      final response = await _networkService.login(email, verificationCode);
      
      if (!response.success) {
        throw Exception(response.message);
      }
      
      if (response.token == null || response.user == null) {
        throw Exception('登录响应数据不完整');
      }
      
      // 保存认证信息
      await _storageService.saveAuthToken(response.token!);
      await _storageService.saveUser(response.user!);
      _networkService.setAuthToken(response.token!);
      
      return AuthResult(
        token: response.token!,
        refreshToken: response.token!, // 简化实现，使用同一token
        user: response.user!,
      );
    } catch (e) {
      throw Exception('验证码登录失败: ${e.toString()}');
    }
  }

  // 注册用户
  Future<AuthResult> register({
    required String email,
    required String password,
    required String verificationCode,
  }) async {
    try {
      final response = await _networkService.registerWithPassword(
        email,
        password,
        verificationCode,
      );
      
      if (!response.success) {
        throw Exception(response.message);
      }
      
      if (response.token == null || response.user == null) {
        throw Exception('注册响应数据不完整');
      }
      
      // 保存认证信息
      await _storageService.saveAuthToken(response.token!);
      await _storageService.saveUser(response.user!);
      _networkService.setAuthToken(response.token!);
      
      return AuthResult(
        token: response.token!,
        refreshToken: response.token!, // 简化实现，使用同一token
        user: response.user!,
      );
    } catch (e) {
      throw Exception('注册失败: ${e.toString()}');
    }
  }

  // 微信登录
  Future<AuthResult> loginWithWeChat({
    required String code,
    required String state,
  }) async {
    try {
      final response = await _networkService.wechatLogin(code, state);
      
      if (!response.success) {
        throw Exception(response.message);
      }
      
      if (response.token == null || response.user == null) {
        throw Exception('微信登录响应数据不完整');
      }
      
      // 保存认证信息
      await _storageService.saveAuthToken(response.token!);
      await _storageService.saveUser(response.user!);
      _networkService.setAuthToken(response.token!);
      
      return AuthResult(
        token: response.token!,
        refreshToken: response.token!, // 简化实现，使用同一token
        user: response.user!,
      );
    } catch (e) {
      throw Exception('微信登录失败: ${e.toString()}');
    }
  }

  // 获取当前用户信息
  Future<User?> getCurrentUser() async {
    try {
      final response = await _networkService.getUserProfile();
      
      if (!response.success || response.data == null) {
        return null;
      }
      
      return response.data;
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }

  // 登出
  Future<void> logout() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token != null) {
        // 尝试调用服务器登出API
        await _networkService.post('/auth/logout');
      }
    } catch (e) {
      // 即使登出失败也继续清理本地数据
      print('服务器登出失败: $e');
    } finally {
      // 清理本地认证数据
      await _storageService.clearAuthToken();
      await _storageService.clearUser();
      _networkService.setAuthToken(null);
    }
  }

  // 刷新token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;
      
      // 简化实现：使用当前token作为refresh token
      final currentToken = await _storageService.getAuthToken();
      if (currentToken != null) {
        _networkService.setAuthToken(currentToken);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // 发送验证码
  Future<bool> sendVerificationCode(String email) async {
    try {
      final response = await _networkService.sendVerificationCode(email);
      return response.success;
    } catch (e) {
      print('发送验证码失败: $e');
      return false;
    }
  }
  
  // 发送重置密码验证码
  Future<bool> sendResetPasswordCode(String email) async {
    try {
      final response = await _networkService.sendResetPasswordCode(email);
      return response.success;
    } catch (e) {
      print('发送重置密码验证码失败: $e');
      return false;
    }
  }
  
  // 重置密码
  Future<bool> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      final response = await _networkService.resetPassword(
        email,
        verificationCode,
        newPassword,
      );
      return response.success;
    } catch (e) {
      print('重置密码失败: $e');
      return false;
    }
  }
  
  // 修改密码
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _networkService.changePassword(
        currentPassword,
        newPassword,
      );
      return response.success;
    } catch (e) {
      print('修改密码失败: $e');
      return false;
    }
  }
  
  // 检查认证状态
  Future<bool> isAuthenticated() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) return false;
      
      _networkService.setAuthToken(token);
      
      // 尝试获取用户信息来验证token有效性
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateUserProfile(User user) async {
    await _storageService.saveUserInfo(user);
  }
}
