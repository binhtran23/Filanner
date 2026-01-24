import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Repository interface cho Authentication
abstract class AuthRepository {
  /// Đăng nhập với username và password
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  });

  /// Đăng ký tài khoản mới
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
  });

  /// Đăng xuất
  Future<Either<Failure, void>> logout();

  /// Kiểm tra trạng thái đăng nhập
  Future<Either<Failure, bool>> isLoggedIn();

  /// Lấy thông tin user hiện tại từ cache
  Future<Either<Failure, User?>> getCurrentUser();

}
