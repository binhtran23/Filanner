import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../../domain/entities/financial_goal.dart';
import '../../../blocs/finance_form/finance_form_bloc.dart';
import '../../../blocs/finance_form/finance_form_event.dart';
import '../../../blocs/finance_form/finance_form_state.dart';

/// Step 4: Mục tiêu tài chính
class FinancialGoalsStep extends StatelessWidget {
  const FinancialGoalsStep({super.key});

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
                    'Mục tiêu tài chính',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chọn các mục tiêu tài chính bạn muốn đạt được',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Goals Grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preset Goals
                    Text(
                      'Mục tiêu phổ biến',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGoalsGrid(context, state),
                    const SizedBox(height: 24),

                    // Selected Goals
                    if (state.financialGoals.isNotEmpty) ...[
                      Text(
                        'Mục tiêu đã chọn (${state.financialGoals.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      _buildSelectedGoals(context, state),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalsGrid(BuildContext context, FinanceFormInProgress state) {
    final selectedTypes = state.financialGoals.map((g) => g.type).toSet();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FinancialGoalType.values.map((type) {
        final isSelected = selectedTypes.contains(type);

        return _GoalChip(
          type: type,
          isSelected: isSelected,
          onTap: () {
            if (isSelected) {
              // Remove goal
              final goal = state.financialGoals.firstWhere(
                (g) => g.type == type,
              );
              context.read<FinanceFormBloc>().add(
                FinancialGoalRemoved(goal.id),
              );
            } else {
              // Add goal
              if (type == FinancialGoalType.other) {
                _showCustomGoalDialog(context);
              } else {
                final goal = FinancialGoal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: type,
                  createdAt: DateTime.now(),
                );
                context.read<FinanceFormBloc>().add(FinancialGoalAdded(goal));
              }
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildSelectedGoals(
    BuildContext context,
    FinanceFormInProgress state,
  ) {
    return Column(
      children: state.financialGoals.map((goal) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(_getGoalIcon(goal.type), color: AppColors.primary),
            ),
            title: Text(goal.displayName),
            subtitle: goal.targetAmount != null
                ? Text(_formatCurrency(goal.targetAmount!))
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Priority indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(goal.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityLabel(goal.priority),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getPriorityColor(goal.priority),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.textSecondary),
                  onPressed: () => _showEditGoalDialog(context, goal),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.error),
                  onPressed: () {
                    context.read<FinanceFormBloc>().add(
                      FinancialGoalRemoved(goal.id),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showCustomGoalDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mục tiêu khác'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Tên mục tiêu',
            hintText: 'VD: Mua laptop mới',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final goal = FinancialGoal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: FinancialGoalType.other,
                  customName: controller.text.trim(),
                  createdAt: DateTime.now(),
                );
                context.read<FinanceFormBloc>().add(FinancialGoalAdded(goal));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, FinancialGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FinanceFormBloc>(),
        child: _GoalEditSheet(goal: goal),
      ),
    );
  }

  IconData _getGoalIcon(FinancialGoalType type) {
    switch (type) {
      case FinancialGoalType.emergencySavings:
        return Icons.savings;
      case FinancialGoalType.buyHouse:
        return Icons.home;
      case FinancialGoalType.buyCar:
        return Icons.directions_car;
      case FinancialGoalType.travel:
        return Icons.flight;
      case FinancialGoalType.retirement:
        return Icons.elderly;
      case FinancialGoalType.investment:
        return Icons.trending_up;
      case FinancialGoalType.payDebt:
        return Icons.money_off;
      case FinancialGoalType.childEducation:
        return Icons.school;
      case FinancialGoalType.wedding:
        return Icons.favorite;
      case FinancialGoalType.business:
        return Icons.business;
      case FinancialGoalType.other:
        return Icons.flag;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.accent;
      case 3:
        return AppColors.warning;
      case 4:
        return AppColors.info;
      case 5:
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Rất cao';
      case 2:
        return 'Cao';
      case 3:
        return 'Trung bình';
      case 4:
        return 'Thấp';
      case 5:
        return 'Rất thấp';
      default:
        return 'Trung bình';
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}₫';
  }
}

/// Chip để chọn mục tiêu
class _GoalChip extends StatelessWidget {
  final FinancialGoalType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              type.label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case FinancialGoalType.emergencySavings:
        return Icons.savings;
      case FinancialGoalType.buyHouse:
        return Icons.home;
      case FinancialGoalType.buyCar:
        return Icons.directions_car;
      case FinancialGoalType.travel:
        return Icons.flight;
      case FinancialGoalType.retirement:
        return Icons.elderly;
      case FinancialGoalType.investment:
        return Icons.trending_up;
      case FinancialGoalType.payDebt:
        return Icons.money_off;
      case FinancialGoalType.childEducation:
        return Icons.school;
      case FinancialGoalType.wedding:
        return Icons.favorite;
      case FinancialGoalType.business:
        return Icons.business;
      case FinancialGoalType.other:
        return Icons.flag;
    }
  }
}

/// Bottom sheet để chỉnh sửa mục tiêu
class _GoalEditSheet extends StatefulWidget {
  final FinancialGoal goal;

  const _GoalEditSheet({required this.goal});

  @override
  State<_GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends State<_GoalEditSheet> {
  late TextEditingController _amountController;
  late TextEditingController _nameController;
  late int _priority;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.goal.targetAmount?.toStringAsFixed(0),
    );
    _nameController = TextEditingController(text: widget.goal.customName);
    _priority = widget.goal.priority;
    _targetDate = widget.goal.targetDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedGoal = widget.goal.copyWith(
      customName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      targetAmount: double.tryParse(_amountController.text),
      targetDate: _targetDate,
      priority: _priority,
    );

    context.read<FinanceFormBloc>().add(FinancialGoalUpdated(updatedGoal));
    Navigator.pop(context);
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
              'Chỉnh sửa mục tiêu',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.goal.displayName,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Custom name (for 'other' type)
            if (widget.goal.type == FinancialGoalType.other) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên mục tiêu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Target Amount
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Số tiền mục tiêu (tùy chọn)',
                hintText: 'VD: 100000000',
                suffixText: '₫',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Priority
            Text(
              'Độ ưu tiên',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 4, 5].map((p) {
                return ChoiceChip(
                  label: Text(_getPriorityLabel(p)),
                  selected: _priority == p,
                  selectedColor: _getPriorityColor(p),
                  labelStyle: TextStyle(
                    color: _priority == p
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _priority = p);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Target Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Thời hạn (tùy chọn)'),
              subtitle: Text(
                _targetDate != null
                    ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                    : 'Chưa đặt',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_targetDate != null)
                    IconButton(
                      icon: Icon(Icons.clear, color: AppColors.error),
                      onPressed: () => setState(() => _targetDate = null),
                    ),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: AppColors.primary),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _targetDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 30),
                        ),
                      );
                      if (date != null) {
                        setState(() => _targetDate = date);
                      }
                    },
                  ),
                ],
              ),
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
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.accent;
      case 3:
        return AppColors.warning;
      case 4:
        return AppColors.info;
      case 5:
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Rất cao';
      case 2:
        return 'Cao';
      case 3:
        return 'Trung bình';
      case 4:
        return 'Thấp';
      case 5:
        return 'Rất thấp';
      default:
        return 'Trung bình';
    }
  }
}
