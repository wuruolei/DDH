part of 'app_bloc.dart';

enum AppStatus { initial, loading, ready, error }

abstract class AppState extends Equatable {
  const AppState();
}

class AppInitialState extends AppState {
  @override
  List<Object> get props => [];
}

class AppLoadingState extends AppState {
  @override
  List<Object> get props => [];
}

class UnauthenticatedState extends AppState {
  @override
  List<Object> get props => [];
}

class AuthenticatedState extends AppState {
  final User user;
  final bool isDarkMode;
  final String locale;

  const AuthenticatedState({
    required this.user,
    this.isDarkMode = false,
    this.locale = 'zh',
  });

  @override
  List<Object> get props => [user, isDarkMode, locale];

  AuthenticatedState copyWith({
    User? user,
    bool? isDarkMode,
    String? locale,
  }) {
    return AuthenticatedState(
      user: user ?? this.user,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
    );
  }
}

class AppErrorState extends AppState {
  final String message;

  const AppErrorState(this.message);

  @override
  List<Object> get props => [message];
}
