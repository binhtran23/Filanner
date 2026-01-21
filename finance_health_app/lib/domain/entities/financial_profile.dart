import 'package:equatable/equatable.dart';

/// Entity đại diện cho hồ sơ tài chính của người dùng
class FinancialProfile extends Equatable {
  final String id;
  final String userId;

  // Thông tin cơ bản
  final int age;
  final String gender;
  final String occupation;
  final String? educationLevel;
  final int dependents;

  // Thu nhập
  final double monthlyIncome;
  final double? otherIncome;

  // Tiết kiệm và nợ
  final double currentSavings;
  final double? currentDebt;

  // Chi tiêu cố định
  final List<FixedExpense>? fixedExpenses;

  // Mục tiêu và rủi ro
  final List<String>? goals;
  final String? riskTolerance;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const FinancialProfile({
    required this.id,
    required this.userId,
    required this.age,
    required this.gender,
    required this.occupation,
    this.educationLevel,
    this.dependents = 0,
    required this.monthlyIncome,
    this.otherIncome,
    this.currentSavings = 0,
    this.currentDebt,
    this.fixedExpenses,
    this.goals,
    this.riskTolerance,
    required this.createdAt,
    this.updatedAt,
  });

  /// Tổng thu nhập
  double get totalIncome => monthlyIncome + (otherIncome ?? 0);

  /// Tổng chi tiêu cố định
  double get totalFixedExpenses =>
      fixedExpenses?.fold(0.0, (sum, expense) => sum! + expense.amount) ?? 0;

  /// Số tiền còn lại sau chi tiêu cố định
  double get remainingAfterFixed => totalIncome - totalFixedExpenses;

  /// Tỷ lệ chi tiêu cố định so với thu nhập (%)
  double get fixedExpenseRatio =>
      totalIncome > 0 ? (totalFixedExpenses / totalIncome) * 100 : 0;

  @override
  List<Object?> get props => [
    id,
    userId,
    age,
    gender,
    occupation,
    educationLevel,
    dependents,
    monthlyIncome,
    otherIncome,
    currentSavings,
    currentDebt,
    fixedExpenses,
    goals,
    riskTolerance,
    createdAt,
    updatedAt,
  ];
}

/// Entity đại diện cho chi tiêu cố định
class FixedExpense extends Equatable {
  final String id;
  final String name;
  final String category;
  final double amount;
  final String? description;

  const FixedExpense({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, category, amount, description];
}

/// Các category cho chi tiêu cố định
enum FixedExpenseCategory {
  food('Ăn uống'),
  transportation('Xăng xe / Đi lại'),
  housing('Nhà cửa'),
  utilities('Điện nước'),
  internet('Internet / Điện thoại'),
  insurance('Bảo hiểm'),
  education('Giáo dục'),
  healthcare('Y tế'),
  other('Khác');

  final String label;
  const FixedExpenseCategory(this.label);
}
