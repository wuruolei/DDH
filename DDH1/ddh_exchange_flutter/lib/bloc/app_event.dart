part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {
  const AppStarted();
}

class AppThemeChanged extends AppEvent {
  final bool isDarkMode;

  const AppThemeChanged(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class AppLanguageChanged extends AppEvent {
  final String locale;

  const AppLanguageChanged(this.locale);

  @override
  List<Object?> get props => [locale];
}

class LoginRequested extends AppEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LoginSuccess extends AppEvent {
  final User user;

  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LogoutRequested extends AppEvent {
  const LogoutRequested();
}
