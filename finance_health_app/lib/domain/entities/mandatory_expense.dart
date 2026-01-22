import 'package:equatable/equatable.dart';

import '../../core/constants/enums.dart';

/// Entity đại diện cho chi tiêu bắt buộc
/// Người dùng phải khai báo ít nhất một khoản chi tiêu bắt buộc
class MandatoryExpense extends Equatable {
  /// ID duy nhất
  final String id;

  /// Tên chi tiêu (*) - bắt buộc
  final String name;

  /// Ước tính số tiền (*) - bắt buộc, phải > 0
  final double estimatedAmount;

  /// Tần suất (*) - bắt buộc
  /// Ví dụ: hàng ngày / hàng tuần / hàng tháng
  final ExpenseFrequency frequency;

  /// Ghi chú (?) - tùy chọn
  final String? note;

  /// Ngày tạo
  final DateTime createdAt;

  const MandatoryExpense({
    required this.id,
    required this.name,
    required this.estimatedAmount,
    required this.frequency,
    this.note,
    required this.createdAt,
  });

  /// Tính số tiền quy đổi về tháng
  /// daily: × 30
  /// weekly: × 4
  /// monthly: × 1
  double get monthlyAmount => frequency.toMonthlyAmount(estimatedAmount);

  /// Tạo bản sao với các giá trị mới
  MandatoryExpense copyWith({
    String? id,
    String? name,
    double? estimatedAmount,
    ExpenseFrequency? frequency,
    String? note,
    DateTime? createdAt,
  }) {
    return MandatoryExpense(
      id: id ?? this.id,
      name: name ?? this.name,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      frequency: frequency ?? this.frequency,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Kiểm tra tính hợp lệ
  bool get isValid {
    return name.isNotEmpty && estimatedAmount > 0;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    estimatedAmount,
    frequency,
    note,
    createdAt,
  ];
}
