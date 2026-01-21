import 'package:equatable/equatable.dart';

/// Events cho AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event kiểm tra trạng thái auth khi app khởi động
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event đăng nhập
class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

/// Event đăng ký
class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [username, email, password];
}

/// Event đăng xuất
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
