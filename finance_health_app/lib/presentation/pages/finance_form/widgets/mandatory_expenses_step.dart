import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/mandatory_expense.dart';
import '../../../blocs/finance_form/finance_form_bloc.dart';
import '../../../blocs/finance_form/finance_form_event.dart';
import '../../../blocs/finance_form/finance_form_state.dart';

/// Step 2: Chi tiêu bắt buộc
class MandatoryExpensesStep extends StatelessWidget {
  const MandatoryExpensesStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceFormBloc, FinanceFormState>(
      builder: (context, state) {
        if (state is! FinanceFormInProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chi tiêu bắt buộc',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm các khoản chi tiêu cố định hàng tháng của bạn',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Validation warning
                  if (state.mandatoryExpenses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bạn cần thêm ít nhất 1 khoản chi tiêu bắt buộc',
                              style: TextStyle(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Expense List
            Expanded(
              child: state.mandatoryExpenses.isEmpty
                  ? _buildEmptyState(context)
                  : _buildExpenseList(context, state),
            ),

            // Summary
            if (state.mandatoryExpenses.isNotEmpty)
              _buildSummary(context, state),

            // Add Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddExpenseDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm chi tiêu'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có chi tiêu nào',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút bên dưới để thêm chi tiêu',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, FinanceFormInProgress state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.mandatoryExpenses.length,
      itemBuilder: (context, index) {
        final expense = state.mandatoryExpenses[index];
        return _ExpenseCard(
          expense: expense,
          onEdit: () => _showEditExpenseDialog(context, expense),
          onDelete: () => _showDeleteConfirmation(context, expense),
        );
      },
    );
  }

  Widget _buildSummary(BuildContext context, FinanceFormInProgress state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng chi tiêu bắt buộc',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${state.mandatoryExpenses.length} khoản',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
          Text(
            _formatCurrency(state.totalMandatoryExpenses),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FinanceFormBloc>(),
        child: const _ExpenseFormSheet(),
      ),
    );
  }

  void _showEditExpenseDialog(BuildContext context, MandatoryExpense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FinanceFormBloc>(),
        child: _ExpenseFormSheet(expense: expense),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MandatoryExpense expense) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa chi tiêu'),
        content: Text('Bạn có chắc muốn xóa "${expense.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<FinanceFormBloc>().add(
                MandatoryExpenseRemoved(expense.id),
              );
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}₫';
  }
}

/// Card hiển thị thông tin chi tiêu
class _ExpenseCard extends StatelessWidget {
  final MandatoryExpense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.expense.withOpacity(0.1),
          child: Icon(Icons.payment, color: AppColors.expense),
        ),
        title: Text(
          expense.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    expense.frequency.label,
                    style: TextStyle(fontSize: 12, color: AppColors.info),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '→ ${_formatCurrency(expense.monthlyAmount)}/tháng',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (expense.note != null && expense.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                expense.note!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatCurrency(expense.estimatedAmount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.expense,
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Sửa'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Xóa', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}₫';
  }
}

/// Bottom sheet để thêm/sửa chi tiêu
class _ExpenseFormSheet extends StatefulWidget {
  final MandatoryExpense? expense;

  const _ExpenseFormSheet({this.expense});

  @override
  State<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<_ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  ExpenseFrequency _selectedFrequency = ExpenseFrequency.monthly;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense?.name);
    _amountController = TextEditingController(
      text: widget.expense != null
          ? formatNumberToVnd(widget.expense!.estimatedAmount)
          : null,
    );
    _noteController = TextEditingController(text: widget.expense?.note);
    _selectedFrequency = widget.expense?.frequency ?? ExpenseFrequency.monthly;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final cleanAmount = parseVndToNumber(_amountController.text);
      final expense = MandatoryExpense(
        id:
            widget.expense?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        estimatedAmount: double.parse(cleanAmount),
        frequency: _selectedFrequency,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: widget.expense?.createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        context.read<FinanceFormBloc>().add(MandatoryExpenseUpdated(expense));
      } else {
        context.read<FinanceFormBloc>().add(MandatoryExpenseAdded(expense));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isEditing ? 'Sửa chi tiêu' : 'Thêm chi tiêu mới',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên chi tiêu *',
                  hintText: 'VD: Tiền thuê nhà',
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên chi tiêu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Số tiền *',
                  hintText: 'Nhập số tiền',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: '₫',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final cleanValue = parseVndToNumber(value);
                  final amount = double.tryParse(cleanValue);
                  if (amount == null || amount <= 0) {
                    return 'Số tiền phải lớn hơn 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Frequency Field
              DropdownButtonFormField<ExpenseFrequency>(
                value: _selectedFrequency,
                decoration: InputDecoration(
                  labelText: 'Tần suất *',
                  prefixIcon: const Icon(Icons.schedule),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ExpenseFrequency.values.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFrequency = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Note Field
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                  hintText: 'Thêm ghi chú...',
                  prefixIcon: const Icon(Icons.notes),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
