import 'package:flutter/services.dart';

/// Formatter để format số tiền VND với dấu chấm phân cách hàng nghìn
/// VD: 5000000 -> 5.000.000
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Loại bỏ tất cả dấu chấm
    String newText = newValue.text.replaceAll('.', '');

    // Chỉ giữ lại số
    if (!RegExp(r'^\d+$').hasMatch(newText)) {
      return oldValue;
    }

    // Format với dấu chấm
    String formatted = _formatNumber(newText);

    // Giữ cursor ở cuối
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(String number) {
    if (number.isEmpty) return '';

    // Reverse để dễ thêm dấu chấm từ phải sang trái
    String reversed = number.split('').reversed.join();
    String formatted = '';

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }

    // Reverse lại
    return formatted.split('').reversed.join();
  }
}

/// Helper để parse số từ string có format VND
String parseVndToNumber(String formattedValue) {
  return formattedValue.replaceAll('.', '');
}

/// Helper để format số thành string VND
String formatNumberToVnd(double value) {
  String number = value.toStringAsFixed(0);
  return _formatWithDots(number);
}

String _formatWithDots(String number) {
  if (number.isEmpty) return '';

  String reversed = number.split('').reversed.join();
  String formatted = '';

  for (int i = 0; i < reversed.length; i++) {
    if (i > 0 && i % 3 == 0) {
      formatted += '.';
    }
    formatted += reversed[i];
  }

  return formatted.split('').reversed.join();
}
