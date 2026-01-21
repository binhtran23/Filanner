/// Base exception class
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'AppException: $message (statusCode: $statusCode)';
}

/// Server exception - lỗi từ phía server
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode, super.data});
}

/// Cache exception - lỗi khi đọc/ghi cache local
class CacheException extends AppException {
  const CacheException({required super.message});
}

/// Network exception - lỗi kết nối mạng
class NetworkException extends AppException {
  const NetworkException({super.message = 'Không có kết nối mạng'});
}

/// Authentication exception - lỗi xác thực
class AuthException extends AppException {
  const AuthException({required super.message, super.statusCode});
}

/// Token expired exception
class TokenExpiredException extends AppException {
  const TokenExpiredException({super.message = 'Phiên đăng nhập đã hết hạn'});
}

/// Validation exception
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException({required super.message, this.errors});
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException({required super.message});
}

/// Unauthorized exception
class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Không có quyền truy cập'});
}

/// Bad request exception
class BadRequestException extends AppException {
  const BadRequestException({required super.message, super.data});
}

/// Timeout exception
class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Yêu cầu đã hết thời gian chờ'});
}
