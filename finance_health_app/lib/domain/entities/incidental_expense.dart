import 'package:equatable/equatable.dart';

/// Entity đại diện cho chi tiêu phát sinh
/// Người dùng nhập phần trăm (%) thu nhập hàng tháng muốn trích ra
class IncidentalExpense extends Equatable {
  /// Phần trăm thu nhập dành cho chi tiêu phát sinh
  /// Giá trị hợp lệ: 0 < % ≤ 100
  final double percentage;

  /// Thu nhập hàng tháng để tính toán
  final double monthlyIncome;

  const IncidentalExpense({
    required this.percentage,
    required this.monthlyIncome,
  });

  /// Số tiền chi tiêu phát sinh = Thu nhập hàng tháng × (% / 100)
  double get calculatedAmount => monthlyIncome * (percentage / 100);

  /// Tạo bản sao với các giá trị mới
  IncidentalExpense copyWith({double? percentage, double? monthlyIncome}) {
    return IncidentalExpense(
      percentage: percentage ?? this.percentage,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    );
  }

  /// Kiểm tra tính hợp lệ
  /// Giá trị hợp lệ: 0 < % ≤ 100
  bool get isValid => percentage > 0 && percentage <= 100;

  @override
  List<Object?> get props => [percentage, monthlyIncome];
}
