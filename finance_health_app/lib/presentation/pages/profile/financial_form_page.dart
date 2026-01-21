import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../app/theme/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/financial_profile.dart';
import '../../blocs/profile/profile_bloc.dart';

class FinancialFormPage extends StatefulWidget {
  const FinancialFormPage({super.key});

  @override
  State<FinancialFormPage> createState() => _FinancialFormPageState();
}

class _FinancialFormPageState extends State<FinancialFormPage> {
  late PageController _pageController;
  int _currentStep = 0;
  final int _totalSteps = 4;

  late FormGroup form;

  final List<FixedExpense> _fixedExpenses = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initForm();
  }

  void _initForm() {
    form = FormGroup({
      // Step 1: Personal Info
      'age': FormControl<int>(
        validators: [
          Validators.required,
          Validators.min(18),
          Validators.max(100),
        ],
      ),
      'gender': FormControl<String>(validators: [Validators.required]),
      'occupation': FormControl<String>(
        validators: [Validators.required, Validators.minLength(2)],
      ),
      'dependents': FormControl<int>(
        value: 0,
        validators: [Validators.required, Validators.min(0)],
      ),

      // Step 2: Income & Savings
      'monthlyIncome': FormControl<double>(
        validators: [Validators.required, Validators.min(0)],
      ),
      'currentSavings': FormControl<double>(
        validators: [Validators.required, Validators.min(0)],
      ),
      'currentDebt': FormControl<double>(
        value: 0,
        validators: [Validators.min(0)],
      ),

      // Step 3: Fixed Expenses (handled separately)

      // Step 4: Goals & Risk
      'goals': FormControl<List<String>>(
        value: [],
        validators: [Validators.required],
      ),
      'riskTolerance': FormControl<String>(validators: [Validators.required]),
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    form.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      // Validate current step
      if (!_validateCurrentStep()) return;

      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        form.control('age').markAsTouched();
        form.control('gender').markAsTouched();
        form.control('occupation').markAsTouched();
        form.control('dependents').markAsTouched();
        return form.control('age').valid &&
            form.control('gender').valid &&
            form.control('occupation').valid &&
            form.control('dependents').valid;
      case 1:
        form.control('monthlyIncome').markAsTouched();
        form.control('currentSavings').markAsTouched();
        form.control('currentDebt').markAsTouched();
        return form.control('monthlyIncome').valid &&
            form.control('currentSavings').valid &&
            form.control('currentDebt').valid;
      case 2:
        return true; // Fixed expenses are optional
      case 3:
        form.control('goals').markAsTouched();
        form.control('riskTolerance').markAsTouched();
        final goals = form.control('goals').value as List<String>?;
        return (goals?.isNotEmpty ?? false) &&
            form.control('riskTolerance').valid;
      default:
        return true;
    }
  }

  void _submitForm() {
    if (form.valid) {
      final profile = FinancialProfile(
        id: '',
        userId: '',
        age: form.control('age').value as int,
        gender: form.control('gender').value as String,
        occupation: form.control('occupation').value as String,
        dependents: form.control('dependents').value as int,
        monthlyIncome: form.control('monthlyIncome').value as double,
        currentSavings: form.control('currentSavings').value as double,
        currentDebt: (form.control('currentDebt').value as double?) ?? 0,
        fixedExpenses: _fixedExpenses,
        goals: form.control('goals').value as List<String>,
        riskTolerance: form.control('riskTolerance').value as String,
        createdAt: DateTime.now(),
      );

      context.read<ProfileBloc>().add(ProfileSubmitRequested(profile: profile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hồ sơ tài chính đã được lưu!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/home');
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tạo Hồ Sơ Tài Chính'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),
            const SizedBox(height: 16),

            // Step Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _getStepTitle(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _getStepDescription(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Form Pages
            Expanded(
              child: ReactiveForm(
                formGroup: form,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPersonalInfoStep(),
                    _buildIncomeStep(),
                    _buildFixedExpensesStep(),
                    _buildGoalsStep(),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Thông Tin Cá Nhân';
      case 1:
        return 'Thu Nhập & Tiết Kiệm';
      case 2:
        return 'Chi Phí Cố Định';
      case 3:
        return 'Mục Tiêu & Rủi Ro';
      default:
        return '';
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Giúp chúng tôi hiểu rõ hơn về bạn';
      case 1:
        return 'Thông tin về thu nhập và tiết kiệm hiện tại';
      case 2:
        return 'Các khoản chi phí hàng tháng cố định';
      case 3:
        return 'Mục tiêu tài chính và mức độ chấp nhận rủi ro';
      default:
        return '';
    }
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Age
          _buildLabel('Tuổi'),
          ReactiveTextField<int>(
            formControlName: 'age',
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Nhập tuổi của bạn'),
            validationMessages: {
              'required': (_) => 'Vui lòng nhập tuổi',
              'min': (_) => 'Tuổi phải từ 18 trở lên',
              'max': (_) => 'Tuổi không hợp lệ',
            },
          ),
          const SizedBox(height: 20),

          // Gender
          _buildLabel('Giới tính'),
          ReactiveDropdownField<String>(
            formControlName: 'gender',
            decoration: _inputDecoration('Chọn giới tính'),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Nam')),
              DropdownMenuItem(value: 'female', child: Text('Nữ')),
              DropdownMenuItem(value: 'other', child: Text('Khác')),
            ],
            validationMessages: {'required': (_) => 'Vui lòng chọn giới tính'},
          ),
          const SizedBox(height: 20),

          // Occupation
          _buildLabel('Nghề nghiệp'),
          ReactiveTextField<String>(
            formControlName: 'occupation',
            decoration: _inputDecoration('Nhập nghề nghiệp'),
            validationMessages: {
              'required': (_) => 'Vui lòng nhập nghề nghiệp',
              'minLength': (_) => 'Nghề nghiệp phải có ít nhất 2 ký tự',
            },
          ),
          const SizedBox(height: 20),

          // Dependents
          _buildLabel('Số người phụ thuộc'),
          ReactiveTextField<int>(
            formControlName: 'dependents',
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Nhập số người phụ thuộc'),
            validationMessages: {
              'required': (_) => 'Vui lòng nhập số người phụ thuộc',
              'min': (_) => 'Số không hợp lệ',
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Income
          _buildLabel('Thu nhập hàng tháng (VND)'),
          ReactiveTextField<double>(
            formControlName: 'monthlyIncome',
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Ví dụ: 15000000'),
            validationMessages: {
              'required': (_) => 'Vui lòng nhập thu nhập',
              'min': (_) => 'Thu nhập không hợp lệ',
            },
          ),
          const SizedBox(height: 20),

          // Current Savings
          _buildLabel('Tiết kiệm hiện tại (VND)'),
          ReactiveTextField<double>(
            formControlName: 'currentSavings',
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Ví dụ: 50000000'),
            validationMessages: {
              'required': (_) => 'Vui lòng nhập số tiền tiết kiệm',
              'min': (_) => 'Số tiền không hợp lệ',
            },
          ),
          const SizedBox(height: 20),

          // Current Debt
          _buildLabel('Nợ hiện tại (VND) - Không bắt buộc'),
          ReactiveTextField<double>(
            formControlName: 'currentDebt',
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Ví dụ: 0'),
            validationMessages: {'min': (_) => 'Số tiền không hợp lệ'},
          ),
        ],
      ),
    );
  }

  Widget _buildFixedExpensesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Expenses List
          if (_fixedExpenses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có chi phí cố định',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thêm các khoản chi phí hàng tháng như tiền nhà, điện, nước...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _fixedExpenses.length,
              itemBuilder: (context, index) {
                final expense = _fixedExpenses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.expense.withValues(alpha: 0.1),
                      child: Icon(Icons.receipt, color: AppColors.expense),
                    ),
                    title: Text(expense.name),
                    subtitle: Text(expense.category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${expense.amount.toStringAsFixed(0)}đ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.expense,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () {
                            setState(() {
                              _fixedExpenses.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 16),

          // Add Expense Button
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _showAddExpenseDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Thêm chi phí cố định'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goals Selection
          _buildLabel('Mục tiêu tài chính'),
          const SizedBox(height: 8),
          ReactiveFormConsumer(
            builder: (context, form, child) {
              final selectedGoals =
                  (form.control('goals').value as List<String>?) ?? [];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.financialGoals.map((goal) {
                  final isSelected = selectedGoals.contains(goal);
                  return FilterChip(
                    label: Text(goal),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newGoals = List<String>.from(selectedGoals);
                      if (selected) {
                        newGoals.add(goal);
                      } else {
                        newGoals.remove(goal);
                      }
                      form.control('goals').value = newGoals;
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),

          // Risk Tolerance
          _buildLabel('Mức độ chấp nhận rủi ro'),
          const SizedBox(height: 16),
          ReactiveFormConsumer(
            builder: (context, form, child) {
              final selectedRisk =
                  form.control('riskTolerance').value as String?;
              return Column(
                children: [
                  _buildRiskOption(
                    form,
                    'low',
                    'Thấp',
                    'Ưu tiên bảo toàn vốn, chấp nhận lợi nhuận thấp',
                    Icons.shield_outlined,
                    selectedRisk == 'low',
                  ),
                  const SizedBox(height: 12),
                  _buildRiskOption(
                    form,
                    'medium',
                    'Trung bình',
                    'Cân bằng giữa rủi ro và lợi nhuận',
                    Icons.balance_outlined,
                    selectedRisk == 'medium',
                  ),
                  const SizedBox(height: 12),
                  _buildRiskOption(
                    form,
                    'high',
                    'Cao',
                    'Sẵn sàng chấp nhận rủi ro để có lợi nhuận cao',
                    Icons.trending_up,
                    selectedRisk == 'high',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiskOption(
    FormGroup form,
    String value,
    String title,
    String description,
    IconData icon,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => form.control('riskTolerance').value = value,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isLoading = state is ProfileLoading;
        return Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _previousStep,
                    child: const Text('Quay lại'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 16),
              Expanded(
                flex: _currentStep > 0 ? 1 : 2,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _nextStep,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentStep < _totalSteps - 1
                              ? 'Tiếp tục'
                              : 'Hoàn thành',
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
    );
  }

  void _showAddExpenseDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = AppConstants.expenseCategories.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm chi phí cố định'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: _inputDecoration('Tên chi phí'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Số tiền (VND)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: _inputDecoration('Danh mục'),
                items: AppConstants.expenseCategories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                setState(() {
                  _fixedExpenses.add(
                    FixedExpense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      amount: double.tryParse(amountController.text) ?? 0,
                      category: selectedCategory,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
