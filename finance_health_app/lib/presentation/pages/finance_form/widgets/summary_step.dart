import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/utils/personal_finance_csv_service.dart';
import '../../../blocs/finance_form/finance_form_bloc.dart';
import '../../../blocs/finance_form/finance_form_event.dart';
import '../../../blocs/finance_form/finance_form_state.dart';

/// Step 5: Tổng kết và xác nhận
class SummaryStep extends StatelessWidget {
  const SummaryStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceFormBloc, FinanceFormState>(
      builder: (context, state) {
        if (state is! FinanceFormInProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Tổng kết thông tin',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kiểm tra lại thông tin trước khi hoàn tất',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Import/Export buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _importFromCsv(context),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Import CSV'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _exportToCsv(context, state),
                      icon: const Icon(Icons.download),
                      label: const Text('Export CSV'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Validation Status
              _buildValidationStatus(context, state),
              const SizedBox(height: 16),

              // User Profile Summary
              _buildSection(
                context,
                icon: Icons.person,
                title: 'Thông tin cá nhân',
                isValid: state.isStep1Valid,
                children: [
                  _buildInfoRow('Tuổi', '${state.age ?? '-'} tuổi'),
                  _buildInfoRow('Nghề nghiệp', state.occupation ?? '-'),
                  _buildInfoRow(
                    'Tình trạng hôn nhân',
                    state.maritalStatus?.label ?? '-',
                  ),
                  _buildInfoRow(
                    'Thu nhập hàng tháng',
                    _formatCurrency(state.monthlyIncome ?? 0),
                    valueColor: AppColors.income,
                  ),
                  if (state.hasDebt) ...[
                    _buildInfoRow('Có nợ', 'Có'),
                    _buildInfoRow(
                      'Tổng nợ',
                      _formatCurrency(state.totalDebt ?? 0),
                      valueColor: AppColors.error,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Mandatory Expenses Summary
              _buildSection(
                context,
                icon: Icons.receipt_long,
                title: 'Chi tiêu bắt buộc',
                isValid: state.isStep2Valid,
                children: [
                  ...state.mandatoryExpenses.map(
                    (expense) => _buildInfoRow(
                      expense.name,
                      '${_formatCurrency(expense.estimatedAmount)} (${expense.frequency.label})',
                    ),
                  ),
                  if (state.mandatoryExpenses.isNotEmpty) ...[
                    const Divider(),
                    _buildInfoRow(
                      'Tổng (quy đổi/tháng)',
                      _formatCurrency(state.totalMandatoryExpenses),
                      valueColor: AppColors.expense,
                      isBold: true,
                    ),
                  ],
                  if (state.mandatoryExpenses.isEmpty)
                    Text(
                      'Chưa có chi tiêu nào',
                      style: TextStyle(
                        color: AppColors.error,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Incidental Expense Summary
              _buildSection(
                context,
                icon: Icons.pie_chart,
                title: 'Chi tiêu phát sinh',
                isValid: state.isStep3Valid,
                children: [
                  _buildInfoRow(
                    'Phần trăm',
                    '${state.incidentalPercentage.toStringAsFixed(0)}%',
                  ),
                  _buildInfoRow(
                    'Số tiền',
                    _formatCurrency(state.incidentalAmount),
                    valueColor: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Financial Goals Summary
              _buildSection(
                context,
                icon: Icons.flag,
                title: 'Mục tiêu tài chính',
                isValid: state.isStep4Valid,
                children: [
                  if (state.financialGoals.isEmpty)
                    Text(
                      'Chưa có mục tiêu nào',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ...state.financialGoals.map(
                    (goal) => _buildInfoRow(
                      goal.displayName,
                      goal.targetAmount != null
                          ? _formatCurrency(goal.targetAmount!)
                          : 'Chưa đặt số tiền',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Budget Overview
              _buildBudgetOverview(context, state),
              const SizedBox(height: 24),

              // Validation Errors
              if (state.validationErrors.isNotEmpty) ...[
                _buildErrorsList(context, state.validationErrors),
                const SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildValidationStatus(
    BuildContext context,
    FinanceFormInProgress state,
  ) {
    final isValid = state.isFormValid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isValid ? AppColors.success : AppColors.warning).withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid ? AppColors.success : AppColors.warning,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.warning,
            color: isValid ? AppColors.success : AppColors.warning,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isValid ? 'Sẵn sàng hoàn tất!' : 'Cần kiểm tra lại',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isValid ? AppColors.success : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isValid
                      ? 'Tất cả thông tin đã hợp lệ'
                      : 'Một số thông tin chưa đầy đủ hoặc không hợp lệ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isValid ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isValid,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? AppColors.success : AppColors.error,
                  size: 20,
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview(
    BuildContext context,
    FinanceFormInProgress state,
  ) {
    final income = state.monthlyIncome ?? 0;
    final totalExpenses = state.totalExpenses;
    final remaining = state.remainingAmount;
    final ratio = state.expenseRatio;

    return Card(
      color: AppColors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Tổng quan ngân sách hàng tháng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: income > 0 ? (totalExpenses / income).clamp(0, 1) : 0,
                minHeight: 24,
                backgroundColor: AppColors.success.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  state.isExpenseWithinBudget
                      ? AppColors.primary
                      : AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sử dụng ${ratio.toStringAsFixed(1)}% thu nhập',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Details
            _buildBudgetRow(
              context,
              'Thu nhập',
              income,
              AppColors.income,
              Icons.arrow_upward,
            ),
            const SizedBox(height: 8),
            _buildBudgetRow(
              context,
              'Chi tiêu bắt buộc',
              state.totalMandatoryExpenses,
              AppColors.expense,
              Icons.arrow_downward,
            ),
            const SizedBox(height: 8),
            _buildBudgetRow(
              context,
              'Chi tiêu phát sinh',
              state.incidentalAmount,
              AppColors.accent,
              Icons.arrow_downward,
            ),
            const Divider(height: 24),
            _buildBudgetRow(
              context,
              'Còn lại',
              remaining,
              remaining >= 0 ? AppColors.success : AppColors.error,
              remaining >= 0 ? Icons.savings : Icons.warning,
              isBold: true,
            ),

            if (!state.isExpenseWithinBudget) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chi tiêu vượt quá thu nhập!',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetRow(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorsList(BuildContext context, List<String> errors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Lỗi cần khắc phục',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: AppColors.error)),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Import from CSV
  Future<void> _importFromCsv(BuildContext context) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final fileBytes = result.files.first.bytes;
      if (fileBytes == null) {
        throw Exception('Không thể đọc file');
      }

      final csvContent = utf8.decode(fileBytes);

      // Parse CSV
      final csvService = PersonalFinanceCsvService();
      final personalFinance = await csvService.importFromCsv(csvContent);

      if (!context.mounted) return;

      // Reset form first to clear existing data
      final bloc = context.read<FinanceFormBloc>();
      bloc.add(const FinanceFormReset());

      // Wait a bit for reset to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Populate form with imported data
      // User Profile
      bloc.add(UserProfileAgeChanged(personalFinance.userProfile.age));
      bloc.add(
        UserProfileOccupationChanged(personalFinance.userProfile.occupation),
      );
      bloc.add(
        UserProfileMaritalStatusChanged(
          personalFinance.userProfile.maritalStatus,
        ),
      );
      bloc.add(
        UserProfileIncomeChanged(personalFinance.userProfile.monthlyIncome),
      );
      bloc.add(UserProfileHasDebtChanged(personalFinance.userProfile.hasDebt));
      if (personalFinance.userProfile.totalDebt != null) {
        bloc.add(
          UserProfileTotalDebtChanged(personalFinance.userProfile.totalDebt),
        );
      }

      // Mandatory Expenses
      for (var expense in personalFinance.mandatoryExpenses) {
        bloc.add(MandatoryExpenseAdded(expense));
      }

      // Incidental Expense
      bloc.add(
        IncidentalPercentageChanged(
          personalFinance.incidentalExpense.percentage,
        ),
      );

      // Financial Goals
      for (var goal in personalFinance.financialGoals) {
        bloc.add(FinancialGoalAdded(goal));
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Import thành công! Vui lòng kiểm tra lại thông tin.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi import CSV: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Export to CSV
  Future<void> _exportToCsv(
    BuildContext context,
    FinanceFormInProgress state,
  ) async {
    try {
      // Convert state to PersonalFinance
      final personalFinance = state.toPersonalFinance();
      if (personalFinance == null) {
        throw Exception('Điền đầy đủ thông tin trước khi export');
      }

      // Generate CSV using service
      final csvService = PersonalFinanceCsvService();
      final csv = csvService.exportToCsv(personalFinance);

      final fileName =
          'personal_finance_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (kIsWeb) {
        // Web: Download using share_plus
        await Share.share(csv, subject: 'Personal Finance Data');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File CSV đã sẵn sàng. Vui lòng lưu lại.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Mobile/Desktop: Save to file and share
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsString(csv, encoding: utf8);

        await Share.shareXFiles([
          XFile(filePath),
        ], subject: 'Personal Finance Data');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export thành công: $fileName'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xuất CSV: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = absAmount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '${isNegative ? '-' : ''}${formatted}₫';
  }
}
