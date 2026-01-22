import 'package:equatable/equatable.dart';

import '../../../../core/constants/enums.dart';
import '../../../../domain/entities/financial_goal.dart';
import '../../../../domain/entities/mandatory_expense.dart';

/// Events cho FinanceFormBloc
abstract class FinanceFormEvent extends Equatable {
  const FinanceFormEvent();

  @override
  List<Object?> get props => [];
}

/// Khởi tạo form
class FinanceFormInitialized extends FinanceFormEvent {
  const FinanceFormInitialized();
}

/// Load dữ liệu đã lưu (nếu có)
class FinanceFormLoaded extends FinanceFormEvent {
  const FinanceFormLoaded();
}

/// Cập nhật step hiện tại
class FinanceFormStepChanged extends FinanceFormEvent {
  final int step;

  const FinanceFormStepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

// ===== USER PROFILE EVENTS =====

/// Cập nhật tuổi
class UserProfileAgeChanged extends FinanceFormEvent {
  final int age;

  const UserProfileAgeChanged(this.age);

  @override
  List<Object?> get props => [age];
}

/// Cập nhật nghề nghiệp
class UserProfileOccupationChanged extends FinanceFormEvent {
  final String occupation;

  const UserProfileOccupationChanged(this.occupation);

  @override
  List<Object?> get props => [occupation];
}

/// Cập nhật tình trạng hôn nhân
class UserProfileMaritalStatusChanged extends FinanceFormEvent {
  final MaritalStatus maritalStatus;

  const UserProfileMaritalStatusChanged(this.maritalStatus);

  @override
  List<Object?> get props => [maritalStatus];
}

/// Cập nhật thu nhập hàng tháng
class UserProfileIncomeChanged extends FinanceFormEvent {
  final double monthlyIncome;

  const UserProfileIncomeChanged(this.monthlyIncome);

  @override
  List<Object?> get props => [monthlyIncome];
}

/// Cập nhật trạng thái có nợ
class UserProfileHasDebtChanged extends FinanceFormEvent {
  final bool hasDebt;

  const UserProfileHasDebtChanged(this.hasDebt);

  @override
  List<Object?> get props => [hasDebt];
}

/// Cập nhật tổng nợ
class UserProfileTotalDebtChanged extends FinanceFormEvent {
  final double? totalDebt;

  const UserProfileTotalDebtChanged(this.totalDebt);

  @override
  List<Object?> get props => [totalDebt];
}

// ===== MANDATORY EXPENSE EVENTS =====

/// Thêm chi tiêu bắt buộc
class MandatoryExpenseAdded extends FinanceFormEvent {
  final MandatoryExpense expense;

  const MandatoryExpenseAdded(this.expense);

  @override
  List<Object?> get props => [expense];
}

/// Cập nhật chi tiêu bắt buộc
class MandatoryExpenseUpdated extends FinanceFormEvent {
  final MandatoryExpense expense;

  const MandatoryExpenseUpdated(this.expense);

  @override
  List<Object?> get props => [expense];
}

/// Xóa chi tiêu bắt buộc
class MandatoryExpenseRemoved extends FinanceFormEvent {
  final String expenseId;

  const MandatoryExpenseRemoved(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

// ===== INCIDENTAL EXPENSE EVENTS =====

/// Cập nhật phần trăm chi tiêu phát sinh
class IncidentalPercentageChanged extends FinanceFormEvent {
  final double percentage;

  const IncidentalPercentageChanged(this.percentage);

  @override
  List<Object?> get props => [percentage];
}

// ===== FINANCIAL GOAL EVENTS =====

/// Thêm mục tiêu tài chính
class FinancialGoalAdded extends FinanceFormEvent {
  final FinancialGoal goal;

  const FinancialGoalAdded(this.goal);

  @override
  List<Object?> get props => [goal];
}

/// Cập nhật mục tiêu tài chính
class FinancialGoalUpdated extends FinanceFormEvent {
  final FinancialGoal goal;

  const FinancialGoalUpdated(this.goal);

  @override
  List<Object?> get props => [goal];
}

/// Xóa mục tiêu tài chính
class FinancialGoalRemoved extends FinanceFormEvent {
  final String goalId;

  const FinancialGoalRemoved(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

// ===== FORM SUBMISSION EVENTS =====

/// Validate step hiện tại
class FinanceFormStepValidated extends FinanceFormEvent {
  final int step;

  const FinanceFormStepValidated(this.step);

  @override
  List<Object?> get props => [step];
}

/// Submit form
class FinanceFormSubmitted extends FinanceFormEvent {
  const FinanceFormSubmitted();
}

/// Reset form
class FinanceFormReset extends FinanceFormEvent {
  const FinanceFormReset();
}

/// Lưu tạm form
class FinanceFormSaved extends FinanceFormEvent {
  const FinanceFormSaved();
}
