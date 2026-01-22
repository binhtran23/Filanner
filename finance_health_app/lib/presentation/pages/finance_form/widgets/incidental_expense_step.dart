import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/colors.dart';
import '../../../blocs/finance_form/finance_form_bloc.dart';
import '../../../blocs/finance_form/finance_form_event.dart';
import '../../../blocs/finance_form/finance_form_state.dart';

/// Step 3: Chi tiêu phát sinh
class IncidentalExpenseStep extends StatelessWidget {
  const IncidentalExpenseStep({super.key});

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
                'Chi tiêu phát sinh',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Xác định phần trăm thu nhập dành cho chi tiêu phát sinh',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Income Display
              _buildIncomeCard(context, state),
              const SizedBox(height: 24),

              // Percentage Slider
              _buildPercentageSlider(context, state),
              const SizedBox(height: 24),

              // Calculated Amount
              _buildCalculatedAmount(context, state),
              const SizedBox(height: 24),

              // Budget Overview
              _buildBudgetOverview(context, state),

              // Warning if over budget
              if (!state.isExpenseWithinBudget) ...[
                const SizedBox(height: 16),
                _buildWarningCard(context, state),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncomeCard(BuildContext context, FinanceFormInProgress state) {
    return Card(
      elevation: 0,
      color: AppColors.income.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.income.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.income,
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thu nhập hàng tháng',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(state.monthlyIncome ?? 0),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.income,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageSlider(
    BuildContext context,
    FinanceFormInProgress state,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phần trăm chi tiêu phát sinh',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.incidentalPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withOpacity(0.2),
                valueIndicatorColor: AppColors.primary,
                valueIndicatorTextStyle: const TextStyle(color: Colors.white),
              ),
              child: Slider(
                value: state.incidentalPercentage,
                min: 1,
                max: 50,
                divisions: 49,
                label: '${state.incidentalPercentage.toStringAsFixed(0)}%',
                onChanged: (value) {
                  context.read<FinanceFormBloc>().add(
                    IncidentalPercentageChanged(value),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1%', style: TextStyle(color: AppColors.textHint)),
                Text('50%', style: TextStyle(color: AppColors.textHint)),
              ],
            ),
            const SizedBox(height: 16),
            // Quick select buttons
            Wrap(
              spacing: 8,
              children: [5, 10, 15, 20, 30].map((percent) {
                final isSelected =
                    state.incidentalPercentage == percent.toDouble();
                return ChoiceChip(
                  label: Text('$percent%'),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      context.read<FinanceFormBloc>().add(
                        IncidentalPercentageChanged(percent.toDouble()),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatedAmount(
    BuildContext context,
    FinanceFormInProgress state,
  ) {
    return Card(
      elevation: 0,
      color: AppColors.accent.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Số tiền chi tiêu phát sinh',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _formatCurrency(state.incidentalAmount),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatCurrency(state.monthlyIncome ?? 0)} × ${state.incidentalPercentage.toStringAsFixed(0)}% = ${_formatCurrency(state.incidentalAmount)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetOverview(
    BuildContext context,
    FinanceFormInProgress state,
  ) {
    final mandatory = state.totalMandatoryExpenses;
    final incidental = state.incidentalAmount;
    final total = state.totalExpenses;
    final remaining = state.remainingAmount;
    final income = state.monthlyIncome ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Tổng quan ngân sách',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: income > 0 ? (total / income).clamp(0, 1) : 0,
                minHeight: 20,
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
              'Đã sử dụng ${state.expenseRatio.toStringAsFixed(1)}% thu nhập',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Details
            _buildBudgetRow(
              context,
              'Chi tiêu bắt buộc',
              mandatory,
              AppColors.expense,
            ),
            const SizedBox(height: 8),
            _buildBudgetRow(
              context,
              'Chi tiêu phát sinh',
              incidental,
              AppColors.accent,
            ),
            const Divider(height: 24),
            _buildBudgetRow(
              context,
              'Tổng chi tiêu',
              total,
              AppColors.textPrimary,
              isBold: true,
            ),
            const SizedBox(height: 8),
            _buildBudgetRow(
              context,
              'Còn lại',
              remaining,
              remaining >= 0 ? AppColors.success : AppColors.error,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetRow(
    BuildContext context,
    String label,
    double amount,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningCard(BuildContext context, FinanceFormInProgress state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: AppColors.error, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vượt ngân sách!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổng chi tiêu vượt quá thu nhập ${_formatCurrency((state.totalExpenses - (state.monthlyIncome ?? 0)).abs())}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
