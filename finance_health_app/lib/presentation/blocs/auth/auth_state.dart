import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

/// States cho AuthBloc
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu - chưa xác định
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Đang xử lý (loading)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Đã đăng nhập thành công
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Chưa đăng nhập
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Lỗi xác thực
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Đăng ký thành công
class AuthRegistered extends AuthState {
  final User user;

  const AuthRegistered({required this.user});

  @override
  List<Object?> get props => [user];
}
