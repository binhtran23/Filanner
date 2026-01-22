import 'package:equatable/equatable.dart';

import '../../../core/constants/enums.dart';
import '../../../domain/entities/financial_goal.dart';
import '../../../domain/entities/incidental_expense.dart';
import '../../../domain/entities/mandatory_expense.dart';
import '../../../domain/entities/personal_finance.dart';
import '../../../domain/entities/user_profile.dart';

/// States cho FinanceFormBloc
abstract class FinanceFormState extends Equatable {
  const FinanceFormState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo
class FinanceFormInitial extends FinanceFormState {
  const FinanceFormInitial();
}

/// Trạng thái đang load
class FinanceFormLoading extends FinanceFormState {
  const FinanceFormLoading();
}

/// Trạng thái form đang được điền
class FinanceFormInProgress extends FinanceFormState {
  /// Step hiện tại (0-4)
  final int currentStep;

  /// Tổng số steps
  final int totalSteps;

  // ===== USER PROFILE DATA =====
  final int? age;
  final String? occupation;
  final MaritalStatus? maritalStatus;
  final double? monthlyIncome;
  final bool hasDebt;
  final double? totalDebt;

  // ===== MANDATORY EXPENSES =====
  final List<MandatoryExpense> mandatoryExpenses;

  // ===== INCIDENTAL EXPENSE =====
  final double incidentalPercentage;

  // ===== FINANCIAL GOALS =====
  final List<FinancialGoal> financialGoals;

  // ===== VALIDATION =====
  final Map<int, bool> stepValidation;
  final List<String> validationErrors;

  // ===== STATUS FLAGS =====
  final bool isSaving;
  final bool isSubmitting;

  const FinanceFormInProgress({
    this.currentStep = 0,
    this.totalSteps = 5,
    this.age,
    this.occupation,
    this.maritalStatus,
    this.monthlyIncome,
    this.hasDebt = false,
    this.totalDebt,
    this.mandatoryExpenses = const [],
    this.incidentalPercentage = 10.0,
    this.financialGoals = const [],
    this.stepValidation = const {},
    this.validationErrors = const [],
    this.isSaving = false,
    this.isSubmitting = false,
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
  double get incidentalAmount {
    if (monthlyIncome == null) return 0;
    return monthlyIncome! * (incidentalPercentage / 100);
  }

  /// Tổng chi tiêu
  double get totalExpenses => totalMandatoryExpenses + incidentalAmount;

  /// Số tiền còn lại
  double get remainingAmount {
    if (monthlyIncome == null) return 0;
    return monthlyIncome! - totalExpenses;
  }

  /// Tỷ lệ chi tiêu so với thu nhập (%)
  double get expenseRatio {
    if (monthlyIncome == null || monthlyIncome! <= 0) return 0;
    return (totalExpenses / monthlyIncome!) * 100;
  }

  /// Kiểm tra tổng chi tiêu có vượt quá thu nhập không
  bool get isExpenseWithinBudget {
    if (monthlyIncome == null) return true;
    return totalExpenses <= monthlyIncome!;
  }

  /// Kiểm tra step 1 (User Profile) hợp lệ
  bool get isStep1Valid {
    if (age == null || age! < 18 || age! > 120) return false;
    if (occupation == null || occupation!.isEmpty) return false;
    if (maritalStatus == null) return false;
    if (monthlyIncome == null || monthlyIncome! <= 0) return false;
    if (hasDebt && (totalDebt == null || totalDebt! <= 0)) return false;
    return true;
  }

  /// Kiểm tra step 2 (Mandatory Expenses) hợp lệ
  bool get isStep2Valid {
    return mandatoryExpenses.isNotEmpty &&
        mandatoryExpenses.every((e) => e.isValid);
  }

  /// Kiểm tra step 3 (Incidental Expense) hợp lệ
  bool get isStep3Valid {
    return incidentalPercentage > 0 && incidentalPercentage <= 100;
  }

  /// Kiểm tra step 4 (Financial Goals) hợp lệ
  bool get isStep4Valid {
    return financialGoals.every((g) => g.isValid);
  }

  /// Kiểm tra toàn bộ form hợp lệ
  bool get isFormValid {
    return isStep1Valid &&
        isStep2Valid &&
        isStep3Valid &&
        isStep4Valid &&
        isExpenseWithinBudget;
  }

  /// Kiểm tra step hiện tại có hợp lệ không
  bool isStepValid(int step) {
    switch (step) {
      case 0:
        return isStep1Valid;
      case 1:
        return isStep2Valid;
      case 2:
        return isStep3Valid;
      case 3:
        return isStep4Valid;
      case 4:
        return isFormValid;
      default:
        return false;
    }
  }

  /// Tạo UserProfile từ dữ liệu hiện tại
  UserProfile? toUserProfile() {
    if (!isStep1Valid) return null;

    return UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      age: age!,
      occupation: occupation!,
      maritalStatus: maritalStatus!,
      monthlyIncome: monthlyIncome!,
      hasDebt: hasDebt,
      totalDebt: hasDebt ? totalDebt : null,
      createdAt: DateTime.now(),
    );
  }

  /// Tạo IncidentalExpense từ dữ liệu hiện tại
  IncidentalExpense? toIncidentalExpense() {
    if (monthlyIncome == null) return null;

    return IncidentalExpense(
      percentage: incidentalPercentage,
      monthlyIncome: monthlyIncome!,
    );
  }

  /// Tạo PersonalFinance từ dữ liệu hiện tại
  PersonalFinance? toPersonalFinance() {
    final userProfile = toUserProfile();
    final incidentalExpense = toIncidentalExpense();

    if (userProfile == null || incidentalExpense == null) return null;

    return PersonalFinance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userProfile: userProfile,
      mandatoryExpenses: mandatoryExpenses,
      incidentalExpense: incidentalExpense,
      financialGoals: financialGoals,
      createdAt: DateTime.now(),
    );
  }

  /// Tạo bản sao với các giá trị mới
  FinanceFormInProgress copyWith({
    int? currentStep,
    int? totalSteps,
    int? age,
    String? occupation,
    MaritalStatus? maritalStatus,
    double? monthlyIncome,
    bool? hasDebt,
    double? totalDebt,
    List<MandatoryExpense>? mandatoryExpenses,
    double? incidentalPercentage,
    List<FinancialGoal>? financialGoals,
    Map<int, bool>? stepValidation,
    List<String>? validationErrors,
    bool? isSaving,
    bool? isSubmitting,
  }) {
    return FinanceFormInProgress(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      age: age ?? this.age,
      occupation: occupation ?? this.occupation,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      hasDebt: hasDebt ?? this.hasDebt,
      totalDebt: totalDebt ?? this.totalDebt,
      mandatoryExpenses: mandatoryExpenses ?? this.mandatoryExpenses,
      incidentalPercentage: incidentalPercentage ?? this.incidentalPercentage,
      financialGoals: financialGoals ?? this.financialGoals,
      stepValidation: stepValidation ?? this.stepValidation,
      validationErrors: validationErrors ?? this.validationErrors,
      isSaving: isSaving ?? this.isSaving,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    totalSteps,
    age,
    occupation,
    maritalStatus,
    monthlyIncome,
    hasDebt,
    totalDebt,
    mandatoryExpenses,
    incidentalPercentage,
    financialGoals,
    stepValidation,
    validationErrors,
    isSaving,
    isSubmitting,
  ];
}

/// Trạng thái đã submit thành công
class FinanceFormSubmitSuccess extends FinanceFormState {
  final PersonalFinance personalFinance;

  const FinanceFormSubmitSuccess(this.personalFinance);

  @override
  List<Object?> get props => [personalFinance];
}

/// Trạng thái lỗi
class FinanceFormError extends FinanceFormState {
  final String message;
  final FinanceFormInProgress? previousState;

  const FinanceFormError({required this.message, this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// Trạng thái đã lưu tạm thành công
class FinanceFormSaveSuccess extends FinanceFormState {
  final FinanceFormInProgress state;

  const FinanceFormSaveSuccess(this.state);

  @override
  List<Object?> get props => [state];
}
