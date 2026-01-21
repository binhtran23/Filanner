import 'package:equatable/equatable.dart';

/// Base class cho tất cả Failures trong ứng dụng
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server failure - lỗi từ phía server
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Cache failure - lỗi khi đọc/ghi cache local
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Network failure - lỗi kết nối mạng
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Không có kết nối mạng'});
}

/// Authentication failure - lỗi xác thực
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// Validation failure - lỗi validation dữ liệu
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({required super.message, this.errors});

  @override
  List<Object?> get props => [message, errors];
}

/// Token expired failure
class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure({super.message = 'Phiên đăng nhập đã hết hạn'});
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Bạn không có quyền thực hiện thao tác này',
  });
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Đã xảy ra lỗi không xác định'});
}
