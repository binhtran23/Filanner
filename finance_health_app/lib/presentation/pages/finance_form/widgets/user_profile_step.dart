import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/validators.dart';
import '../../../blocs/finance_form/finance_form_bloc.dart';
import '../../../blocs/finance_form/finance_form_event.dart';
import '../../../blocs/finance_form/finance_form_state.dart';

/// Step 1: Thông tin người dùng
class UserProfileStep extends StatefulWidget {
  const UserProfileStep({super.key});

  @override
  State<UserProfileStep> createState() => _UserProfileStepState();
}

class _UserProfileStepState extends State<UserProfileStep> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();
  final _debtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final state = context.read<FinanceFormBloc>().state;
    if (state is FinanceFormInProgress) {
      if (state.age != null) {
        _ageController.text = state.age.toString();
      }
      if (state.monthlyIncome != null) {
        _incomeController.text = _formatNumber(state.monthlyIncome!);
      }
      if (state.totalDebt != null) {
        _debtController.text = _formatNumber(state.totalDebt!);
      }
    }
  }

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  double? _parseNumber(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[,\s.]'), '');
    return double.tryParse(cleanValue);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _incomeController.dispose();
    _debtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceFormBloc, FinanceFormState>(
      builder: (context, state) {
        if (state is! FinanceFormInProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Thông tin cá nhân',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng cung cấp thông tin cơ bản của bạn',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Age Field
                _buildAgeField(state),
                const SizedBox(height: 16),

                // Occupation Field
                _buildOccupationField(state),
                const SizedBox(height: 16),

                // Marital Status Field
                _buildMaritalStatusField(state),
                const SizedBox(height: 16),

                // Monthly Income Field
                _buildIncomeField(state),
                const SizedBox(height: 24),

                // Debt Section
                _buildDebtSection(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgeField(FinanceFormInProgress state) {
    return TextFormField(
      controller: _ageController,
      decoration: InputDecoration(
        labelText: 'Tuổi *',
        hintText: 'Nhập tuổi của bạn',
        prefixIcon: const Icon(Icons.cake_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      validator: Validators.age,
      onChanged: (value) {
        final age = int.tryParse(value);
        if (age != null) {
          context.read<FinanceFormBloc>().add(UserProfileAgeChanged(age));
        }
      },
    );
  }

  Widget _buildOccupationField(FinanceFormInProgress state) {
    return DropdownButtonFormField<String>(
      value: state.occupation,
      decoration: InputDecoration(
        labelText: 'Nghề nghiệp *',
        hintText: 'Chọn nghề nghiệp',
        prefixIcon: const Icon(Icons.work_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: OccupationCategory.values.map((occupation) {
        return DropdownMenuItem(
          value: occupation.label,
          child: Text(occupation.label),
        );
      }).toList(),
      validator: (value) =>
          Validators.required(value, fieldName: 'nghề nghiệp'),
      onChanged: (value) {
        if (value != null) {
          context.read<FinanceFormBloc>().add(
            UserProfileOccupationChanged(value),
          );
        }
      },
    );
  }

  Widget _buildMaritalStatusField(FinanceFormInProgress state) {
    return DropdownButtonFormField<MaritalStatus>(
      value: state.maritalStatus,
      decoration: InputDecoration(
        labelText: 'Tình trạng hôn nhân *',
        hintText: 'Chọn tình trạng',
        prefixIcon: const Icon(Icons.favorite_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: MaritalStatus.values.map((status) {
        return DropdownMenuItem(value: status, child: Text(status.label));
      }).toList(),
      validator: (value) =>
          value == null ? 'Vui lòng chọn tình trạng hôn nhân' : null,
      onChanged: (value) {
        if (value != null) {
          context.read<FinanceFormBloc>().add(
            UserProfileMaritalStatusChanged(value),
          );
        }
      },
    );
  }

  Widget _buildIncomeField(FinanceFormInProgress state) {
    return TextFormField(
      controller: _incomeController,
      decoration: InputDecoration(
        labelText: 'Thu nhập hàng tháng *',
        hintText: 'Nhập thu nhập',
        prefixIcon: const Icon(Icons.attach_money),
        suffixText: '₫',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: Validators.income,
      onChanged: (value) {
        final income = _parseNumber(value);
        if (income != null) {
          context.read<FinanceFormBloc>().add(UserProfileIncomeChanged(income));
        }
        // Format lại số
        if (value.isNotEmpty) {
          final formatted = _formatNumber(double.tryParse(value) ?? 0);
          if (formatted != value) {
            _incomeController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
    );
  }

  Widget _buildDebtSection(FinanceFormInProgress state) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_outlined,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thông tin nợ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Has Debt Switch
            SwitchListTile(
              title: const Text('Bạn có khoản nợ nào không?'),
              subtitle: Text(
                state.hasDebt ? 'Có nợ' : 'Không có nợ',
                style: TextStyle(
                  color: state.hasDebt ? AppColors.warning : AppColors.success,
                ),
              ),
              value: state.hasDebt,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                context.read<FinanceFormBloc>().add(
                  UserProfileHasDebtChanged(value),
                );
              },
            ),

            // Total Debt Field (chỉ hiện khi hasDebt = true)
            if (state.hasDebt) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _debtController,
                decoration: InputDecoration(
                  labelText: 'Tổng số nợ *',
                  hintText: 'Nhập tổng số nợ',
                  prefixIcon: const Icon(Icons.money_off),
                  suffixText: '₫',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    Validators.debt(value, hasDebt: state.hasDebt),
                onChanged: (value) {
                  final debt = _parseNumber(value);
                  context.read<FinanceFormBloc>().add(
                    UserProfileTotalDebtChanged(debt),
                  );
                  // Format lại số
                  if (value.isNotEmpty) {
                    final formatted = _formatNumber(
                      double.tryParse(value) ?? 0,
                    );
                    if (formatted != value) {
                      _debtController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
