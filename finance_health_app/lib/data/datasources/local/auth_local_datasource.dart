import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

/// Local data source cho Authentication
abstract class AuthLocalDataSource {
  /// Lưu access token
  Future<void> saveAccessToken(String token);

  /// Lấy access token
  Future<String?> getAccessToken();

  /// Lưu refresh token
  Future<void> saveRefreshToken(String token);

  /// Lấy refresh token
  Future<String?> getRefreshToken();

  /// Lưu thông tin user
  Future<void> saveUser(UserModel user);

  /// Lấy thông tin user
  Future<UserModel?> getUser();

  /// Xóa tất cả dữ liệu auth
  Future<void> clearAuthData();

  /// Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      // Use SharedPreferences for web platform (FlutterSecureStorage hangs on web)
      await sharedPreferences.setString(AppConstants.accessTokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Không thể lưu access token');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return sharedPreferences.getString(AppConstants.accessTokenKey);
    } catch (e) {
      throw CacheException(message: 'Không thể đọc access token');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      // Use SharedPreferences for web platform (FlutterSecureStorage hangs on web)
      await sharedPreferences.setString(AppConstants.refreshTokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Không thể lưu refresh token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return sharedPreferences.getString(AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException(message: 'Không thể đọc refresh token');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await sharedPreferences.setString(AppConstants.userDataKey, userJson);
    } catch (e) {
      throw CacheException(message: 'Không thể lưu thông tin user');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = sharedPreferences.getString(AppConstants.userDataKey);
      if (userJson == null) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await sharedPreferences.remove(AppConstants.accessTokenKey);
      await sharedPreferences.remove(AppConstants.refreshTokenKey);
      await sharedPreferences.remove(AppConstants.userDataKey);
    } catch (e) {
      throw CacheException(message: 'Không thể xóa dữ liệu auth');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = sharedPreferences.getString(AppConstants.accessTokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
