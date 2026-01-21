import 'package:intl/intl.dart';

/// Extensions cho String
extension StringExtension on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize all words
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Check if string is numeric
  bool get isNumeric => double.tryParse(this) != null;

  /// Check if string is valid email
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Convert to double safely
  double? toDoubleOrNull() => double.tryParse(replaceAll(',', ''));
}

/// Extensions cho double (số tiền)
extension DoubleExtension on double {
  /// Format số tiền theo định dạng VNĐ
  String toVnd() {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }

  /// Format số tiền không có symbol
  String toFormattedNumber() {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(this);
  }

  /// Format phần trăm
  String toPercentage({int decimalDigits = 1}) {
    return '${toStringAsFixed(decimalDigits)}%';
  }

  /// Format số tiền ngắn gọn (K, M, B)
  String toCompactVnd() {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B';
    } else if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(0)}K';
    }
    return toStringAsFixed(0);
  }
}

/// Extensions cho int
extension IntExtension on int {
  /// Format số tiền theo định dạng VNĐ
  String toVnd() => toDouble().toVnd();

  /// Format số tiền không có symbol
  String toFormattedNumber() => toDouble().toFormattedNumber();

  /// Format phần trăm
  String toPercentage() => '$this%';
}

/// Extensions cho DateTime
extension DateTimeExtension on DateTime {
  /// Format ngày theo định dạng dd/MM/yyyy
  String toDateString() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format thời gian theo định dạng HH:mm
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format đầy đủ dd/MM/yyyy HH:mm
  String toDateTimeString() {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }

  /// Format tháng năm MM/yyyy
  String toMonthYearString() {
    return DateFormat('MM/yyyy').format(this);
  }

  /// Format tên tháng tiếng Việt
  String toVietnameseMonth() {
    return DateFormat('MMMM yyyy', 'vi').format(this);
  }

  /// Check if same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  /// Get relative time string (vừa xong, 5 phút trước, ...)
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else {
      return '${(difference.inDays / 365).floor()} năm trước';
    }
  }
}

/// Extensions cho List
extension ListExtension<T> on List<T> {
  /// Get element at index safely
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get first element safely
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element safely
  T? get lastOrNull => isEmpty ? null : last;
}

/// Extensions cho Map
extension MapExtension<K, V> on Map<K, V> {
  /// Get value safely with default
  V getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }
}
