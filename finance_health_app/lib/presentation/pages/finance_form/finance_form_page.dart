import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../data/datasources/local/personal_finance_local_datasource.dart';
import '../../../injection_container.dart';
import '../../blocs/finance_form/finance_form_bloc.dart';
import '../../blocs/finance_form/finance_form_event.dart';
import '../../blocs/finance_form/finance_form_state.dart';
import 'widgets/financial_goals_step.dart';
import 'widgets/incidental_expense_step.dart';
import 'widgets/mandatory_expenses_step.dart';
import 'widgets/summary_step.dart';
import 'widgets/user_profile_step.dart';

/// Trang form thu thập thông tin tài chính cá nhân
/// Multi-step form với 5 bước:
/// 1. Thông tin cá nhân
/// 2. Chi tiêu bắt buộc
/// 3. Chi tiêu phát sinh
/// 4. Mục tiêu tài chính
/// 5. Tổng kết
class FinancialFormPage extends StatelessWidget {
  const FinancialFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FinanceFormBloc(localDataSource: sl<PersonalFinanceLocalDataSource>())
            ..add(const FinanceFormLoaded()),
      child: const _FinanceFormView(),
    );
  }
}

class _FinanceFormView extends StatefulWidget {
  const _FinanceFormView();

  @override
  State<_FinanceFormView> createState() => _FinanceFormViewState();
}

class _FinanceFormViewState extends State<_FinanceFormView> {
  final PageController _pageController = PageController();

  final List<String> _stepTitles = [
    'Thông tin cá nhân',
    'Chi tiêu bắt buộc',
    'Chi tiêu phát sinh',
    'Mục tiêu tài chính',
    'Tổng kết',
  ];

  final List<IconData> _stepIcons = [
    Icons.person,
    Icons.receipt_long,
    Icons.pie_chart,
    Icons.flag,
    Icons.check_circle,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    context.read<FinanceFormBloc>().add(FinanceFormStepChanged(step));
  }

  void _nextStep(FinanceFormInProgress state) {
    if (state.currentStep < state.totalSteps - 1) {
      _goToStep(state.currentStep + 1);
    }
  }

  void _previousStep(FinanceFormInProgress state) {
    if (state.currentStep > 0) {
      _goToStep(state.currentStep - 1);
    }
  }

  void _submit() {
    context.read<FinanceFormBloc>().add(const FinanceFormSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FinanceFormBloc, FinanceFormState>(
      listener: (context, state) {
        if (state is FinanceFormSubmitSuccess) {
          _showSuccessDialog(context);
        } else if (state is FinanceFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is FinanceFormSaveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã lưu tạm thành công'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is FinanceFormLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is! FinanceFormInProgress) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_stepTitles[state.currentStep]),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitConfirmation(context),
            ),
            actions: [
              // Save draft button
              IconButton(
                icon: const Icon(Icons.save_outlined),
                onPressed: () {
                  context.read<FinanceFormBloc>().add(const FinanceFormSaved());
                },
                tooltip: 'Lưu tạm',
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(state),

              // Step Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    context.read<FinanceFormBloc>().add(
                      FinanceFormStepChanged(index),
                    );
                  },
                  children: const [
                    UserProfileStep(),
                    MandatoryExpensesStep(),
                    IncidentalExpenseStep(),
                    FinancialGoalsStep(),
                    SummaryStep(),
                  ],
                ),
              ),

              // Navigation Buttons
              _buildNavigationButtons(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(FinanceFormInProgress state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(state.totalSteps, (index) {
              final isActive = index == state.currentStep;
              final isCompleted = index < state.currentStep;
              final isValid = state.isStepValid(index);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Allow navigation to completed or current step
                    if (index <= state.currentStep) {
                      _goToStep(index);
                    }
                  },
                  child: Column(
                    children: [
                      // Step circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : isCompleted
                              ? (isValid
                                    ? AppColors.success
                                    : AppColors.warning)
                              : AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : isCompleted
                                ? (isValid
                                      ? AppColors.success
                                      : AppColors.warning)
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isCompleted
                              ? (isValid ? Icons.check : Icons.warning)
                              : _stepIcons[index],
                          color: isActive || isCompleted
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Step number
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (state.currentStep + 1) / state.totalSteps,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(FinanceFormInProgress state) {
    final isFirstStep = state.currentStep == 0;
    final isLastStep = state.currentStep == state.totalSteps - 1;
    final canProceed = state.isStepValid(state.currentStep);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            if (!isFirstStep)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _previousStep(state),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),

            if (!isFirstStep) const SizedBox(width: 16),

            // Next/Submit button
            Expanded(
              flex: isFirstStep ? 1 : 1,
              child: ElevatedButton.icon(
                onPressed: isLastStep
                    ? (state.isFormValid ? _submit : null)
                    : (canProceed ? () => _nextStep(state) : null),
                icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
                label: Text(isLastStep ? 'Hoàn tất' : 'Tiếp theo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: isLastStep
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thoát form?'),
        content: const Text(
          'Bạn có muốn lưu tạm thông tin trước khi thoát không?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop();
            },
            child: const Text('Không lưu'),
          ),
          TextButton(
            onPressed: () {
              context.read<FinanceFormBloc>().add(const FinanceFormSaved());
              Navigator.pop(dialogContext);
              context.pop();
            },
            child: const Text('Lưu & Thoát'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 64,
        ),
        title: const Text('Thành công!'),
        content: const Text(
          'Thông tin tài chính của bạn đã được lưu.\n'
          'Bây giờ bạn có thể xem phân tích và gợi ý tiết kiệm.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }
}
