/// Các validators cho form fields
class Validators {
  Validators._();

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    if (value.length > 32) {
      return 'Mật khẩu không được quá 32 ký tự';
    }

    // Kiểm tra có ít nhất 1 chữ hoa, 1 chữ thường, 1 số
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ thường';
    }

    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }

    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 số';
    }

    return null;
  }

  /// Validate confirm password
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng xác nhận mật khẩu';
      }

      if (value != password) {
        return 'Mật khẩu xác nhận không khớp';
      }

      return null;
    };
  }

  /// Validate username
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }

    if (value.length < 3) {
      return 'Tên đăng nhập phải có ít nhất 3 ký tự';
    }

    if (value.length > 50) {
      return 'Tên đăng nhập không được quá 50 ký tự';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới';
    }

    return null;
  }

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập ${fieldName ?? 'thông tin này'}';
    }
    return null;
  }

  /// Validate số tiền (phải là số dương)
  static String? money(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập ${fieldName ?? 'số tiền'}';
    }

    // Loại bỏ dấu phẩy và khoảng trắng
    final cleanValue = value.replaceAll(RegExp(r'[,\s]'), '');

    final number = double.tryParse(cleanValue);
    if (number == null) {
      return 'Vui lòng nhập số hợp lệ';
    }

    if (number < 0) {
      return 'Số tiền không được âm';
    }

    return null;
  }

  /// Validate số dương
  static String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập ${fieldName ?? 'số'}';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Vui lòng nhập số hợp lệ';
    }

    if (number <= 0) {
      return 'Số phải lớn hơn 0';
    }

    return null;
  }

  /// Validate tuổi (18-120)
  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tuổi';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Vui lòng nhập số hợp lệ';
    }

    if (age < 18) {
      return 'Bạn phải đủ 18 tuổi';
    }

    if (age > 120) {
      return 'Tuổi không hợp lệ';
    }

    return null;
  }

  /// Validate số điện thoại Việt Nam
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    // Loại bỏ khoảng trắng và dấu gạch
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');

    // Số điện thoại VN: bắt đầu bằng 0 hoặc +84, theo sau là 9-10 số
    final phoneRegex = RegExp(r'^(\+84|0)\d{9,10}$');

    if (!phoneRegex.hasMatch(cleanValue)) {
      return 'Số điện thoại không hợp lệ';
    }

    return null;
  }

  /// Validate percentage (0-100)
  static String? percentage(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập ${fieldName ?? 'phần trăm'}';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Vui lòng nhập số hợp lệ';
    }

    if (number < 0 || number > 100) {
      return 'Phần trăm phải từ 0 đến 100';
    }

    return null;
  }
}
