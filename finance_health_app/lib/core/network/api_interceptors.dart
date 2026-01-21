import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Interceptor để tự động thêm JWT token vào mọi request
class AuthInterceptor extends Interceptor {
  final SharedPreferences? _prefs;

  AuthInterceptor({SharedPreferences? sharedPreferences})
    : _prefs = sharedPreferences;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Lấy SharedPreferences instance nếu chưa có
      final prefs =
          _prefs ??
          await SharedPreferences.getInstance().timeout(
            const Duration(seconds: 2),
          );

      // Lấy token từ shared preferences
      final token = prefs.getString(AppConstants.accessTokenKey);

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Nếu không lấy được token, tiếp tục mà không có auth header
      print('Warning: Could not read auth token: $e');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Xử lý 401 Unauthorized - token hết hạn
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic here
      // Có thể emit event để logout user hoặc refresh token
    }

    handler.next(err);
  }
}

/// Interceptor để log request/response (chỉ dùng trong development)
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌───────────────────────────────────────────────────────────────');
    print('│ 🚀 REQUEST: ${options.method} ${options.uri}');
    print('│ Headers: ${options.headers}');
    if (options.data != null) {
      print('│ Body: ${options.data}');
    }
    print('└───────────────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌───────────────────────────────────────────────────────────────');
    print(
      '│ ✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
    );
    print('│ Data: ${response.data}');
    print('└───────────────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌───────────────────────────────────────────────────────────────');
    print('│ ❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('│ Message: ${err.message}');
    print('│ Response: ${err.response?.data}');
    print('└───────────────────────────────────────────────────────────────');
    handler.next(err);
  }
}

/// Interceptor để xử lý lỗi chung
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Chuyển đổi DioException thành message thân thiện với user
    String errorMessage;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Kết nối quá chậm. Vui lòng thử lại.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Không thể gửi dữ liệu. Vui lòng thử lại.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Server phản hồi quá chậm. Vui lòng thử lại.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Không thể kết nối. Kiểm tra kết nối mạng.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleBadResponse(err.response);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Yêu cầu đã bị hủy.';
        break;
      default:
        errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }

    // Thêm message vào error để sử dụng sau
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
      message: errorMessage,
    );

    handler.next(newError);
  }

  String _handleBadResponse(Response? response) {
    if (response == null) return 'Lỗi không xác định từ server';

    switch (response.statusCode) {
      case 400:
        return response.data?['message'] ?? 'Yêu cầu không hợp lệ';
      case 401:
        return 'Phiên đăng nhập đã hết hạn';
      case 403:
        return 'Bạn không có quyền thực hiện thao tác này';
      case 404:
        return 'Không tìm thấy dữ liệu';
      case 422:
        return response.data?['message'] ?? 'Dữ liệu không hợp lệ';
      case 500:
        return 'Lỗi server. Vui lòng thử lại sau';
      case 502:
      case 503:
        return 'Server đang bảo trì. Vui lòng thử lại sau';
      default:
        return response.data?['message'] ?? 'Lỗi không xác định';
    }
  }
}
