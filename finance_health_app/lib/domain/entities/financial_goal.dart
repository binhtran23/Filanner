import 'package:equatable/equatable.dart';

import '../../core/constants/enums.dart';

/// Entity đại diện cho mục tiêu tài chính
/// Có thể mở rộng trong tương lai với thời gian đạt mục tiêu và số tiền mục tiêu
class FinancialGoal extends Equatable {
  /// ID duy nhất
  final String id;

  /// Loại mục tiêu
  final FinancialGoalType type;

  /// Tên mục tiêu tùy chỉnh (nếu type = other)
  final String? customName;

  /// Số tiền mục tiêu (?) - tùy chọn, có thể mở rộng trong tương lai
  final double? targetAmount;

  /// Thời gian đạt mục tiêu (?) - tùy chọn, có thể mở rộng trong tương lai
  final DateTime? targetDate;

  /// Độ ưu tiên (1-5, 1 là cao nhất)
  final int priority;

  /// Ngày tạo
  final DateTime createdAt;

  const FinancialGoal({
    required this.id,
    required this.type,
    this.customName,
    this.targetAmount,
    this.targetDate,
    this.priority = 3,
    required this.createdAt,
  });

  /// Lấy tên hiển thị của mục tiêu
  String get displayName {
    if (type == FinancialGoalType.other && customName != null) {
      return customName!;
    }
    return type.label;
  }

  /// Tạo bản sao với các giá trị mới
  FinancialGoal copyWith({
    String? id,
    FinancialGoalType? type,
    String? customName,
    double? targetAmount,
    DateTime? targetDate,
    int? priority,
    DateTime? createdAt,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      type: type ?? this.type,
      customName: customName ?? this.customName,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Kiểm tra tính hợp lệ
  bool get isValid {
    // Nếu type là other thì phải có customName
    if (type == FinancialGoalType.other) {
      return customName != null && customName!.isNotEmpty;
    }
    return true;
  }

  @override
  List<Object?> get props => [
    id,
    type,
    customName,
    targetAmount,
    targetDate,
    priority,
    createdAt,
  ];
}
