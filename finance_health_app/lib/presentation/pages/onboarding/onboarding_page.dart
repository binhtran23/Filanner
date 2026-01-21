import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:file_picker/file_picker.dart';

import '../../../app/routes/app_router.dart';
import '../../../app/theme/colors.dart';
import '../../../domain/entities/financial_profile.dart';
import '../../../domain/entities/transaction.dart';
import '../../../injection_container.dart' as di;
import '../../../core/utils/csv_parser_service.dart';
import '../../blocs/profile/profile_bloc.dart';

/// Onboarding page - 2 steps
/// Step 1: Thông tin cơ bản (Bắt buộc)
/// Step 2: Chi tiêu (Tùy chọn) - Gồm cả chi tiêu cố định và lịch sử giao dịch
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late PageController _pageController;
  late FormGroup _form;
  late TabController _expenseTabController;

  // Unified expense list
  final List<ExpenseEntry> _allExpenses = [];
  String? _uploadedFileName;

  // Tab index: 0 = Chi tiêu cố định, 1 = Lịch sử giao dịch
  int _selectedExpenseTab = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _expenseTabController = TabController(length: 2, vsync: this);
    _expenseTabController.addListener(() {
      setState(() {
        _selectedExpenseTab = _expenseTabController.index;
      });
    });
    _initForm();
  }

  void _initForm() {
    _form = FormGroup({
      // Step 1: Basic Info
      'age': FormControl<int>(
        validators: [
          Validators.required,
          Validators.min(18),
          Validators.max(100),
        ],
      ),
      'gender': FormControl<String>(validators: [Validators.required]),
      'monthlyIncome': FormControl<double>(
        validators: [Validators.required, Validators.min(0)],
      ),
      'occupation': FormControl<String>(validators: [Validators.required]),
      'educationLevel': FormControl<String>(validators: [Validators.required]),
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _expenseTabController.dispose();
    _form.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 1) {
      if (!_validateCurrentStep()) return;

      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (!_form.valid) {
        _form.markAllAsTouched();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      return true;
    }
    // Step 2 (Chi tiêu) is OPTIONAL - always valid
    return true;
  }

  void _submitProfile() {
    if (!_form.valid) {
      _form.markAllAsTouched();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng hoàn thành thông tin bắt buộc'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _currentStep = 0);
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Get fixed expenses from unified list
    final fixedExpenses = _allExpenses
        .where((e) => e.isFixedExpense)
        .map(
          (e) => FixedExpense(
            id: '',
            name: e.name,
            category: e.category,
            amount: e.amount,
          ),
        )
        .toList();

    final profileBloc = context.read<ProfileBloc>();
    profileBloc.add(
      ProfileCreateRequested(
        age: _form.control('age').value,
        gender: _form.control('gender').value,
        occupation: _form.control('occupation').value,
        educationLevel: _form.control('educationLevel').value,
        monthlyIncome: _form.control('monthlyIncome').value,
        fixedExpenses: fixedExpenses,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded || state is ProfileCreated) {
          context.go(AppRoutes.home);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thiết lập tài khoản'),
          leading: _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousStep,
                )
              : null,
        ),
        body: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: ReactiveForm(
                formGroup: _form,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildStep1BasicInfo(), _buildStep2Expenses()],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(2, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppColors.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==================== STEP 1: BASIC INFO ====================

  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin cơ bản',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Cung cấp thông tin để chúng tôi tạo kế hoạch tài chính phù hợp',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          ReactiveTextField(
            formControlName: 'age',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tuổi',
              hintText: 'Nhập tuổi của bạn',
              prefixIcon: Icon(Icons.cake),
            ),
          ),
          const SizedBox(height: 16),
          ReactiveDropdownField<String>(
            formControlName: 'gender',
            decoration: const InputDecoration(
              labelText: 'Giới tính',
              prefixIcon: Icon(Icons.person),
            ),
            items: const [
              DropdownMenuItem(value: 'Nam', child: Text('Nam')),
              DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
              DropdownMenuItem(value: 'Khác', child: Text('Khác')),
            ],
          ),
          const SizedBox(height: 16),
          ReactiveTextField(
            formControlName: 'monthlyIncome',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Thu nhập hàng tháng (VND)',
              hintText: 'Nhập thu nhập của bạn',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 16),
          ReactiveTextField(
            formControlName: 'occupation',
            decoration: const InputDecoration(
              labelText: 'Ngành nghề',
              hintText: 'Ví dụ: Kỹ sư, Giáo viên...',
              prefixIcon: Icon(Icons.work),
            ),
          ),
          const SizedBox(height: 16),
          ReactiveDropdownField<String>(
            formControlName: 'educationLevel',
            decoration: const InputDecoration(
              labelText: 'Học vấn',
              prefixIcon: Icon(Icons.school),
            ),
            items: const [
              DropdownMenuItem(value: 'THPT', child: Text('THPT')),
              DropdownMenuItem(value: 'Cao đẳng', child: Text('Cao đẳng')),
              DropdownMenuItem(value: 'Đại học', child: Text('Đại học')),
              DropdownMenuItem(value: 'Thạc sĩ', child: Text('Thạc sĩ')),
              DropdownMenuItem(value: 'Tiến sĩ', child: Text('Tiến sĩ')),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== STEP 2: EXPENSES (UNIFIED) ====================

  Widget _buildStep2Expenses() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Chi tiêu',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Tùy chọn',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thêm chi tiêu cố định hoặc import từ file CSV',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _expenseTabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade700,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.repeat, size: 16),
                    const SizedBox(width: 6),
                    Text('Cố định (${_fixedExpenseCount})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, size: 16),
                    const SizedBox(width: 6),
                    Text('Lịch sử (${_transactionCount})'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Import/Export buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _importFromCsv,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Import CSV'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _allExpenses.isNotEmpty ? _exportToCsv : null,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export CSV'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // View template link
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _showCsvTemplateInfo,
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text(
                'Xem định dạng CSV mẫu',
                style: TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
              ),
            ),
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _expenseTabController,
            children: [_buildFixedExpensesList(), _buildTransactionsList()],
          ),
        ),
      ],
    );
  }

  int get _fixedExpenseCount =>
      _allExpenses.where((e) => e.isFixedExpense).length;

  int get _transactionCount =>
      _allExpenses.where((e) => e.isTransaction).length;

  double get _totalFixedExpenses => _allExpenses
      .where((e) => e.isFixedExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  Widget _buildFixedExpensesList() {
    final fixedExpenses = _allExpenses.where((e) => e.isFixedExpense).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          if (fixedExpenses.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng chi tiêu cố định:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${_formatCurrency(_totalFixedExpenses)} đ/tháng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Expense list
          ...fixedExpenses.asMap().entries.map((entry) {
            final expense = entry.value;
            return _buildExpenseCard(expense);
          }),

          // Add button
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAddExpenseDialog(isRecurring: true),
            icon: const Icon(Icons.add),
            label: const Text('Thêm chi tiêu cố định'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),

          // Empty state hint
          if (fixedExpenses.isEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chi tiêu cố định là các khoản phải trả hàng tháng như tiền nhà, điện, nước, internet...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactions = _allExpenses.where((e) => e.isTransaction).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          if (transactions.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${transactions.length} giao dịch',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (_uploadedFileName != null)
                    Text(
                      _uploadedFileName!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Transaction list
          ...transactions.asMap().entries.map((entry) {
            final transaction = entry.value;
            return _buildExpenseCard(transaction);
          }),

          // Add button
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAddExpenseDialog(isRecurring: false),
            icon: const Icon(Icons.add),
            label: const Text('Thêm giao dịch'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),

          // Empty state hint
          if (transactions.isEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bạn có thể import file CSV lịch sử chi tiêu hoặc thêm từng giao dịch thủ công',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseEntry expense) {
    final isIncome = expense.type == TransactionType.income;
    final dateStr = expense.transactionDate != null
        ? '${expense.transactionDate!.day}/${expense.transactionDate!.month}/${expense.transactionDate!.year}'
        : 'Hàng tháng';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isIncome
                ? Colors.green.shade100
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isIncome
                ? Icons.arrow_downward
                : _getCategoryIcon(expense.category),
            color: isIncome ? Colors.green : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          expense.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${expense.category} • $dateStr',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${_formatCurrency(expense.amount)}đ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isIncome ? Colors.green : Colors.black87,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: Colors.grey,
              onPressed: () {
                setState(() {
                  _allExpenses.remove(expense);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BOTTOM BUTTONS ====================

  Widget _buildBottomButtons() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isLoading = state is ProfileLoading;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary for step 2
              if (_currentStep == 1 && _allExpenses.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_fixedExpenseCount cố định • $_transactionCount giao dịch',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
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
                        _currentStep == 1
                            ? 'Hoàn tất${_allExpenses.isEmpty ? ' (Bỏ qua)' : ''}'
                            : 'Tiếp tục',
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== DIALOGS & ACTIONS ====================

  void _showAddExpenseDialog({required bool isRecurring}) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Ăn uống';
    TransactionType selectedType = TransactionType.expense;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isRecurring ? 'Thêm chi tiêu cố định' : 'Thêm giao dịch'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên',
                    hintText: isRecurring
                        ? 'Ví dụ: Tiền nhà'
                        : 'Ví dụ: Cơm trưa',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: const [
                    DropdownMenuItem(value: 'Ăn uống', child: Text('Ăn uống')),
                    DropdownMenuItem(
                      value: 'Di chuyển',
                      child: Text('Di chuyển'),
                    ),
                    DropdownMenuItem(value: 'Nhà cửa', child: Text('Nhà cửa')),
                    DropdownMenuItem(
                      value: 'Tiện ích',
                      child: Text('Tiện ích'),
                    ),
                    DropdownMenuItem(
                      value: 'Giải trí',
                      child: Text('Giải trí'),
                    ),
                    DropdownMenuItem(value: 'Mua sắm', child: Text('Mua sắm')),
                    DropdownMenuItem(value: 'Y tế', child: Text('Y tế')),
                    DropdownMenuItem(
                      value: 'Thu nhập',
                      child: Text('Thu nhập'),
                    ),
                    DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                  ],
                  onChanged: (value) {
                    selectedCategory = value!;
                    if (value == 'Thu nhập') {
                      setDialogState(() {
                        selectedType = TransactionType.income;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền (VND)',
                    hintText: '0',
                  ),
                ),
                if (!isRecurring) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<TransactionType>(
                          value: selectedType,
                          decoration: const InputDecoration(labelText: 'Loại'),
                          items: const [
                            DropdownMenuItem(
                              value: TransactionType.expense,
                              child: Text('Chi tiêu'),
                            ),
                            DropdownMenuItem(
                              value: TransactionType.income,
                              child: Text('Thu nhập'),
                            ),
                          ],
                          onChanged: (value) =>
                              setDialogState(() => selectedType = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() => selectedDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                    ),
                  ),
                ],
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
                    _allExpenses.add(
                      ExpenseEntry(
                        name: nameController.text,
                        category: selectedCategory,
                        amount: double.parse(amountController.text),
                        isRecurring: isRecurring,
                        type: isRecurring
                            ? TransactionType.expense
                            : selectedType,
                        transactionDate: isRecurring ? null : selectedDate,
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
      ),
    );
  }

  Future<void> _importFromCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        final file = result.files.first;
        // Sử dụng utf8.decode để đọc đúng tiếng Việt
        final csvContent = utf8.decode(file.bytes!, allowMalformed: true);

        final csvParser = di.sl<CsvParserService>();
        final entries = csvParser.parseUnifiedCsv(csvContent);

        if (entries.isNotEmpty) {
          setState(() {
            _allExpenses.addAll(entries);
            _uploadedFileName = file.name;
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã import ${entries.length} mục từ ${file.name}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy dữ liệu hợp lệ trong file'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi đọc file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportToCsv() {
    final csvParser = di.sl<CsvParserService>();
    final csvContent = csvParser.exportToCsv(_allExpenses);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export CSV'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sao chép nội dung bên dưới và lưu thành file .csv:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  csvContent,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showCsvTemplateInfo() {
    final csvParser = di.sl<CsvParserService>();
    final template = csvParser.generateUnifiedCsvTemplate();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Định dạng CSV'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'File CSV cần có 6 cột:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildFormatRow(
                '1. Date',
                'Ngày (DD/MM/YYYY), để trống nếu là chi tiêu cố định',
              ),
              _buildFormatRow('2. Name', 'Tên khoản chi/thu'),
              _buildFormatRow('3. Category', 'Danh mục'),
              _buildFormatRow('4. Amount', 'Số tiền'),
              _buildFormatRow('5. Type', 'Income hoặc Expense'),
              _buildFormatRow(
                '6. IsRecurring',
                'true = cố định, false = 1 lần',
              ),
              const SizedBox(height: 16),
              const Text(
                'Ví dụ:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  template,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatRow(String label, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== UTILITIES ====================

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Di chuyển':
        return Icons.directions_car;
      case 'Nhà cửa':
        return Icons.home;
      case 'Tiện ích':
        return Icons.bolt;
      case 'Giải trí':
        return Icons.movie;
      case 'Mua sắm':
        return Icons.shopping_bag;
      case 'Y tế':
        return Icons.local_hospital;
      case 'Thu nhập':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }
}
