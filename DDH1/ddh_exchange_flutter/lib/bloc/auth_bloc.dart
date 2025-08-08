import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/logger.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthBloc({
    required AuthService authService,
    StorageService? storageService,
  })  : _authService = authService,
        _storageService = storageService ?? StorageService(),
        super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthWeChatLoginRequested>(_onAuthWeChatLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthTokenRefreshed>(_onAuthTokenRefreshed);
    on<AuthUserUpdated>(_onAuthUserUpdated);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        await _storageService.clearUserData();
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final authResult = await _authService.login(
        username: event.username,
        password: event.password,
      );

      await _storageService.saveAuthToken(authResult.token);
      await _storageService.saveRefreshToken(authResult.refreshToken);
      await _storageService.saveUserInfo(authResult.user);

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: authResult.user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final authResult = await _authService.register(
        email: event.email ?? '', // 处理可空email
        password: event.password,
        verificationCode: event.verificationCode ?? '000000', // 使用默认验证码或从event获取
      );

      await _storageService.saveAuthToken(authResult.token);
      await _storageService.saveRefreshToken(authResult.refreshToken);
      await _storageService.saveUserInfo(authResult.user);

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: authResult.user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAuthWeChatLoginRequested(
    AuthWeChatLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final authResult = await _authService.loginWithWeChat(
        code: event.code,
        state: event.state ?? 'default_state', // 使用默认state或从event获取
      );

      await _storageService.saveAuthToken(authResult.token);
      await _storageService.saveRefreshToken(authResult.refreshToken);
      await _storageService.saveUserInfo(authResult.user);

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: authResult.user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      await _authService.logout();
      await _storageService.clearUserData();
      
      emit(const AuthState.initial());
    } catch (e) {
      // 即使登出失败也清除本地数据
      await _storageService.clearUserData();
      emit(const AuthState.initial());
    }
  }

  Future<void> _onAuthTokenRefreshed(
    AuthTokenRefreshed event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _storageService.saveAuthToken(event.token);
      await _storageService.saveRefreshToken(event.refreshToken);
    } catch (e) {
      Logger.error('Token刷新失败: $e');
    }
  }

  Future<void> _onAuthUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.authenticated) {
      await _storageService.saveUserInfo(event.user);
      emit(state.copyWith(user: event.user));
    }
  }
}
