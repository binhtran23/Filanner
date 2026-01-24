import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final accessToken = response.data['access_token'] as String;
      final tokenType = response.data['token_type'] as String? ?? 'bearer';
      final userId = _decodeUserId(accessToken);
      final user = await _fetchUser(userId, accessToken);

      return LoginResponseModel(
        user: user,
        accessToken: accessToken,
        tokenType: tokenType,
      );
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

      final user = UserModel.fromJson(response.data as Map<String, dynamic>);

      final tokenResponse = await dioClient.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final accessToken = tokenResponse.data['access_token'] as String;
      final tokenType = tokenResponse.data['token_type'] as String? ?? 'bearer';

      return LoginResponseModel(
        user: user,
        accessToken: accessToken,
        tokenType: tokenType,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    return;
  }

  String _decodeUserId(String accessToken) {
    final decoded = JwtDecoder.decode(accessToken);
    final userId = decoded['sub'];
    if (userId == null) {
      throw const ServerException(message: 'Token thiếu thông tin user');
    }
    return userId.toString();
  }

  Future<UserModel> _fetchUser(String userId, String accessToken) async {
    final response = await dioClient.get(
      ApiEndpoints.userById(userId),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
