part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String? email;
  final String? phone;
  final String password;
  final String? verificationCode;

  const AuthRegisterRequested({
    required this.username,
    this.email,
    this.phone,
    required this.password,
    this.verificationCode,
  });

  @override
  List<Object?> get props => [username, email, phone, password, verificationCode];
}

class AuthWeChatLoginRequested extends AuthEvent {
  final String code;
  final String? state;

  const AuthWeChatLoginRequested({
    required this.code,
    this.state,
  });

  @override
  List<Object?> get props => [code, state];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthTokenRefreshed extends AuthEvent {
  final String token;
  final String refreshToken;

  const AuthTokenRefreshed({
    required this.token,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [token, refreshToken];
}

class AuthUserUpdated extends AuthEvent {
  final User user;

  const AuthUserUpdated({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}
