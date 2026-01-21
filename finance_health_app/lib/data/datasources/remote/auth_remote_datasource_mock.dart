import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Mock implementation for testing without backend
class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  @override
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful login for testing
    if (username == 'tayroi' && password == '120anglyen') {
      return LoginResponseModel(
        accessToken:
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        user: UserModel(
          id: 'mock_user_id',
          username: username,
          email: 'tayroi@example.com',
          createdAt: DateTime.now(),
        ),
      );
    }

    throw ServerException(message: 'Tên đăng nhập hoặc mật khẩu không đúng');
  }

  @override
  Future<LoginResponseModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return LoginResponseModel(
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      user: UserModel(
        id: 'mock_user_id',
        username: username,
        email: email,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'mock_new_access_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
