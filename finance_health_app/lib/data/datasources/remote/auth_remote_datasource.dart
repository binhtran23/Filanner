import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/user_model.dart';

/// Remote data source cho Authentication
abstract class AuthRemoteDataSource {
  /// Đăng nhập
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  });

  /// Đăng ký
  Future<LoginResponseModel> register({
    required String username,
    required String email,
    required String password,
  });

  /// Refresh token
  Future<String> refreshToken(String refreshToken);

  /// Đăng xuất
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );

      return LoginResponseModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LoginResponseModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.register,
        data: {'username': username, 'email': email, 'password': password},
      );

      return LoginResponseModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      return response.data['access_token'] as String;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post(ApiEndpoints.logout);
    } catch (e) {
      // Ignore errors on logout
    }
  }
}
