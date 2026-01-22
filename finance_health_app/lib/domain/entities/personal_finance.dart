import 'package:equatable/equatable.dart';

import 'financial_goal.dart';
import 'incidental_expense.dart';
import 'mandatory_expense.dart';
import 'user_profile.dart';

/// Entity tổng hợp toàn bộ thông tin tài chính cá nhân
/// Dùng để:
/// - Thu thập thông tin tài chính cá nhân
/// - Phân loại chi tiêu: bắt buộc – phát sinh
/// - Làm cơ sở cho phân tích tài chính, gợi ý tiết kiệm, lập kế hoạch tài chính
class PersonalFinance extends Equatable {
  /// ID duy nhất
  final String id;

  /// Thông tin người dùng
  final UserProfile userProfile;

  /// Danh sách chi tiêu bắt buộc (phải có ít nhất 1)
  final List<MandatoryExpense> mandatoryExpenses;

  /// Chi tiêu phát sinh (% thu nhập)
  final IncidentalExpense incidentalExpense;

  /// Danh sách mục tiêu tài chính
  final List<FinancialGoal> financialGoals;

  /// Ngày tạo
  final DateTime createdAt;

  /// Ngày cập nhật
  final DateTime? updatedAt;

  const PersonalFinance({
    required this.id,
    required this.userProfile,
    required this.mandatoryExpenses,
    required this.incidentalExpense,
    required this.financialGoals,
    required this.createdAt,
    this.updatedAt,
  });

  // ===== COMPUTED PROPERTIES =====

  /// Tổng chi tiêu bắt buộc (quy đổi về tháng)
  double get totalMandatoryExpenses {
    return mandatoryExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.monthlyAmount,
    );
  }

  /// Số tiền chi tiêu phát sinh
  double get incidentalAmount => incidentalExpense.calculatedAmount;

  /// Tổng chi tiêu = chi tiêu bắt buộc + chi tiêu phát sinh
  double get totalExpenses => totalMandatoryExpenses + incidentalAmount;

  /// Số tiền còn lại sau chi tiêu
  double get remainingAmount => userProfile.monthlyIncome - totalExpenses;

  /// Tỷ lệ chi tiêu so với thu nhập (%)
  double get expenseRatio {
    if (userProfile.monthlyIncome <= 0) return 0;
    return (totalExpenses / userProfile.monthlyIncome) * 100;
  }

  /// Tỷ lệ chi tiêu bắt buộc so với thu nhập (%)
  double get mandatoryExpenseRatio {
    if (userProfile.monthlyIncome <= 0) return 0;
    return (totalMandatoryExpenses / userProfile.monthlyIncome) * 100;
  }

  // ===== VALIDATION =====

  /// Kiểm tra tổng chi tiêu không vượt quá thu nhập
  bool get isExpenseWithinBudget => totalExpenses <= userProfile.monthlyIncome;

  /// Kiểm tra có ít nhất 1 chi tiêu bắt buộc
  bool get hasMandatoryExpense => mandatoryExpenses.isNotEmpty;

  /// Kiểm tra tính hợp lệ toàn bộ
  bool get isValid {
    return userProfile.isValid &&
        hasMandatoryExpense &&
        incidentalExpense.isValid &&
        isExpenseWithinBudget &&
        mandatoryExpenses.every((e) => e.isValid) &&
        financialGoals.every((g) => g.isValid);
  }

  /// Danh sách lỗi validation
  List<String> get validationErrors {
    final errors = <String>[];

    if (!userProfile.isValid) {
      errors.add('Thông tin người dùng không hợp lệ');
    }

    if (!hasMandatoryExpense) {
      errors.add('Phải có ít nhất 1 khoản chi tiêu bắt buộc');
    }

    if (!incidentalExpense.isValid) {
      errors.add('Phần trăm chi tiêu phát sinh phải từ 0 đến 100');
    }

    if (!isExpenseWithinBudget) {
      errors.add('Tổng chi tiêu vượt quá thu nhập');
    }

    for (final expense in mandatoryExpenses) {
      if (!expense.isValid) {
        errors.add('Chi tiêu "${expense.name}" không hợp lệ');
      }
    }

    for (final goal in financialGoals) {
      if (!goal.isValid) {
        errors.add('Mục tiêu "${goal.displayName}" không hợp lệ');
      }
    }

    return errors;
  }

  /// Tạo bản sao với các giá trị mới
  PersonalFinance copyWith({
    String? id,
    UserProfile? userProfile,
    List<MandatoryExpense>? mandatoryExpenses,
    IncidentalExpense? incidentalExpense,
    List<FinancialGoal>? financialGoals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalFinance(
      id: id ?? this.id,
      userProfile: userProfile ?? this.userProfile,
      mandatoryExpenses: mandatoryExpenses ?? this.mandatoryExpenses,
      incidentalExpense: incidentalExpense ?? this.incidentalExpense,
      financialGoals: financialGoals ?? this.financialGoals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userProfile,
    mandatoryExpenses,
    incidentalExpense,
    financialGoals,
    createdAt,
    updatedAt,
  ];
}
