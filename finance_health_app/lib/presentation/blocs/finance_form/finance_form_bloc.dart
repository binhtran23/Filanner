import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/local/personal_finance_local_datasource.dart';
import '../../../domain/entities/financial_goal.dart';
import '../../../domain/entities/mandatory_expense.dart';
import 'finance_form_event.dart';
import 'finance_form_state.dart';

/// BLoC quản lý form thu thập thông tin tài chính cá nhân
class FinanceFormBloc extends Bloc<FinanceFormEvent, FinanceFormState> {
  final PersonalFinanceLocalDataSource _localDataSource;

  FinanceFormBloc({required PersonalFinanceLocalDataSource localDataSource})
    : _localDataSource = localDataSource,
      super(const FinanceFormInitial()) {
    // Form events
    on<FinanceFormInitialized>(_onInitialized);
    on<FinanceFormLoaded>(_onLoaded);
    on<FinanceFormStepChanged>(_onStepChanged);
    on<FinanceFormReset>(_onReset);
    on<FinanceFormSaved>(_onSaved);
    on<FinanceFormSubmitted>(_onSubmitted);

    // User profile events
    on<UserProfileAgeChanged>(_onAgeChanged);
    on<UserProfileOccupationChanged>(_onOccupationChanged);
    on<UserProfileMaritalStatusChanged>(_onMaritalStatusChanged);
    on<UserProfileIncomeChanged>(_onIncomeChanged);
    on<UserProfileHasDebtChanged>(_onHasDebtChanged);
    on<UserProfileTotalDebtChanged>(_onTotalDebtChanged);

    // Mandatory expense events
    on<MandatoryExpenseAdded>(_onExpenseAdded);
    on<MandatoryExpenseUpdated>(_onExpenseUpdated);
    on<MandatoryExpenseRemoved>(_onExpenseRemoved);

    // Incidental expense events
    on<IncidentalPercentageChanged>(_onIncidentalPercentageChanged);

    // Financial goal events
    on<FinancialGoalAdded>(_onGoalAdded);
    on<FinancialGoalUpdated>(_onGoalUpdated);
    on<FinancialGoalRemoved>(_onGoalRemoved);
  }

  // ===== FORM EVENTS =====

  Future<void> _onInitialized(
    FinanceFormInitialized event,
    Emitter<FinanceFormState> emit,
  ) async {
    emit(const FinanceFormInProgress());
  }

  Future<void> _onLoaded(
    FinanceFormLoaded event,
    Emitter<FinanceFormState> emit,
  ) async {
    emit(const FinanceFormLoading());

    // Always start fresh - don't load old submitted data
    await Future.delayed(const Duration(milliseconds: 100));
    emit(const FinanceFormInProgress());
  }

  void _onStepChanged(
    FinanceFormStepChanged event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      emit(currentState.copyWith(currentStep: event.step));
    }
  }

  void _onReset(FinanceFormReset event, Emitter<FinanceFormState> emit) {
    _localDataSource.clearPersonalFinance();
    emit(const FinanceFormInProgress());
  }

  Future<void> _onSaved(
    FinanceFormSaved event,
    Emitter<FinanceFormState> emit,
  ) async {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      emit(currentState.copyWith(isSaving: true));

      try {
        final personalFinance = currentState.toPersonalFinance();
        if (personalFinance != null) {
          await _localDataSource.savePersonalFinance(personalFinance);
        }
        emit(FinanceFormSaveSuccess(currentState.copyWith(isSaving: false)));
        emit(currentState.copyWith(isSaving: false));
      } catch (e) {
        emit(
          FinanceFormError(
            message: 'Không thể lưu dữ liệu: $e',
            previousState: currentState,
          ),
        );
        emit(currentState.copyWith(isSaving: false));
      }
    }
  }

  Future<void> _onSubmitted(
    FinanceFormSubmitted event,
    Emitter<FinanceFormState> emit,
  ) async {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      // Validate toàn bộ form
      if (!currentState.isFormValid) {
        final errors = <String>[];
        if (!currentState.isStep1Valid) {
          errors.add('Thông tin cá nhân chưa đầy đủ');
        }
        if (!currentState.isStep2Valid) {
          errors.add('Cần ít nhất 1 khoản chi tiêu bắt buộc');
        }
        if (!currentState.isStep3Valid) {
          errors.add('Phần trăm chi tiêu phát sinh không hợp lệ');
        }
        if (!currentState.isExpenseWithinBudget) {
          errors.add('Tổng chi tiêu vượt quá thu nhập');
        }

        emit(currentState.copyWith(validationErrors: errors));
        return;
      }

      emit(currentState.copyWith(isSubmitting: true));

      try {
        final personalFinance = currentState.toPersonalFinance()!;
        await _localDataSource.savePersonalFinance(personalFinance);

        // Clear draft after successful submission
        await _localDataSource.clearFormDraft();

        emit(FinanceFormSubmitSuccess(personalFinance));
      } catch (e) {
        emit(
          FinanceFormError(
            message: 'Không thể lưu dữ liệu: $e',
            previousState: currentState,
          ),
        );
      }
    }
  }

  // ===== USER PROFILE EVENTS =====

  void _onAgeChanged(
    UserProfileAgeChanged event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      emit(currentState.copyWith(age: event.age));
    }
  }

  void _onOccupationChanged(
    UserProfileOccupationChanged event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      emit(currentState.copyWith(occupation: event.occupation));
    }
  }

  void _onMaritalStatusChanged(
    UserProfileMaritalStatusChanged event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      emit(currentState.copyWith(maritalStatus: event.maritalStatus));
    }
  }

  void _onIncomeChanged(
    UserProfileIncomeChanged event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      emit(currentState.copyWith(monthlyIncome: event.monthlyIncome));
    }
  }

  void _onHasDebtChanged(
    UserProfileHasDebtChanged event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      emit(
        currentState.copyWith(
          hasDebt: event.hasDebt,
          totalDebt: event.hasDebt ? currentState.totalDebt : null,
        ),
      );
    }
  }

  void _onTotalDebtChanged(
    UserProfileTotalDebtChanged event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      emit(currentState.copyWith(totalDebt: event.totalDebt));
    }
  }

  // ===== MANDATORY EXPENSE EVENTS =====

  void _onExpenseAdded(
    MandatoryExpenseAdded event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      final updatedExpenses = List<MandatoryExpense>.from(
        currentState.mandatoryExpenses,
      )..add(event.expense);

      emit(currentState.copyWith(mandatoryExpenses: updatedExpenses));
    }
  }

  void _onExpenseUpdated(
    MandatoryExpenseUpdated event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      final updatedExpenses = currentState.mandatoryExpenses.map((expense) {
        return expense.id == event.expense.id ? event.expense : expense;
      }).toList();

      emit(currentState.copyWith(mandatoryExpenses: updatedExpenses));
    }
  }

  void _onExpenseRemoved(
    MandatoryExpenseRemoved event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      final updatedExpenses = currentState.mandatoryExpenses
          .where((expense) => expense.id != event.expenseId)
          .toList();

      emit(currentState.copyWith(mandatoryExpenses: updatedExpenses));
    }
  }

  // ===== INCIDENTAL EXPENSE EVENTS =====

  void _onIncidentalPercentageChanged(
    IncidentalPercentageChanged event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      emit(currentState.copyWith(incidentalPercentage: event.percentage));
    }
  }

  // ===== FINANCIAL GOAL EVENTS =====

  void _onGoalAdded(FinancialGoalAdded event, Emitter<FinanceFormState> emit) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      final updatedGoals = List<FinancialGoal>.from(currentState.financialGoals)
        ..add(event.goal);

      emit(currentState.copyWith(financialGoals: updatedGoals));
    }
  }

  void _onGoalUpdated(
    FinancialGoalUpdated event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      final updatedGoals = currentState.financialGoals.map((goal) {
        return goal.id == event.goal.id ? event.goal : goal;
      }).toList();

      emit(currentState.copyWith(financialGoals: updatedGoals));
    }
  }

  void _onGoalRemoved(
    FinancialGoalRemoved event,
    Emitter<FinanceFormState> emit,
  ) {
    final currentState = state;
    if (currentState is FinanceFormInProgress) {
      final updatedGoals = currentState.financialGoals
          .where((goal) => goal.id != event.goalId)
          .toList();

      emit(currentState.copyWith(financialGoals: updatedGoals));
    }
  }
}
