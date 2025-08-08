import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/user.dart';
import '../services/storage_service.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final StorageService storageService;
  
  AppBloc({required this.storageService}) : super(AppInitialState()) {
    on<AppStarted>(_onAppStarted);
    on<AppThemeChanged>(_onAppThemeChanged);
    on<AppLanguageChanged>(_onAppLanguageChanged);
    on<LoginRequested>(_onLoginRequested);
    on<LoginSuccess>(_onLoginSuccess);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AppState> emit,
  ) async {
    try {
      emit(AppLoadingState());
      
      // 初始化应用
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 检查是否已登录
      // TODO: 从存储中检查登录状态
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AppErrorState(e.toString()));
    }
  }

  void _onAppThemeChanged(
    AppThemeChanged event,
    Emitter<AppState> emit,
  ) {
    if (state is AuthenticatedState) {
      final currentState = state as AuthenticatedState;
      emit(currentState.copyWith(isDarkMode: event.isDarkMode));
    }
  }

  void _onAppLanguageChanged(
    AppLanguageChanged event,
    Emitter<AppState> emit,
  ) {
    if (state is AuthenticatedState) {
      final currentState = state as AuthenticatedState;
      emit(currentState.copyWith(locale: event.locale));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AppState> emit,
  ) async {
    try {
      emit(AppLoadingState());
      
      // TODO: 实际的登录逻辑
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟登录成功
      final user = User(
        id: '1',
        username: '测试用户',
        email: event.email,
        points: 1000,
        userType: 'regular',
        joinDate: DateTime.now(),
      );
      
      emit(AuthenticatedState(user: user));
    } catch (e) {
      emit(AppErrorState(e.toString()));
    }
  }

  void _onLoginSuccess(
    LoginSuccess event,
    Emitter<AppState> emit,
  ) {
    emit(AuthenticatedState(user: event.user));
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AppState> emit,
  ) {
    // TODO: 清理存储的用户数据
    emit(UnauthenticatedState());
  }
}
