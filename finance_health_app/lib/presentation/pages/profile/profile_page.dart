import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/colors.dart';
import '../../../core/utils/csv_parser_service.dart';
import '../../../injection_container.dart' as di;
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/profile/profile_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Cá Nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/financial-form'),
            tooltip: 'Chỉnh sửa hồ sơ tài chính',
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileBloc>().add(
                      const ProfileLoadRequested(),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar Card
                  _buildProfileHeader(context),
                  const SizedBox(height: 24),

                  // Personal Info Section
                  _buildSectionTitle(context, 'Thông Tin Cá Nhân'),
                  const SizedBox(height: 12),
                  _buildInfoCard(context, [
                    _buildInfoRow(
                      Icons.cake_outlined,
                      'Tuổi',
                      '${profile.age} tuổi',
                    ),
                    _buildInfoRow(
                      Icons.person_outline,
                      'Giới tính',
                      profile.gender == 'male' ? 'Nam' : 'Nữ',
                    ),
                    _buildInfoRow(
                      Icons.work_outline,
                      'Nghề nghiệp',
                      profile.occupation,
                    ),
                    _buildInfoRow(
                      Icons.people_outline,
                      'Số người phụ thuộc',
                      '${profile.dependents} người',
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Financial Info Section
                  _buildSectionTitle(context, 'Thông Tin Tài Chính'),
                  const SizedBox(height: 12),
                  _buildFinancialCards(context, profile),
                  const SizedBox(height: 24),

                  // Fixed Expenses Section
                  _buildSectionTitle(context, 'Chi Phí Cố Định'),
                  const SizedBox(height: 12),
                  _buildFixedExpensesCard(context, profile.fixedExpenses ?? []),
                  const SizedBox(height: 24),

                  // Financial Goals Section
                  _buildSectionTitle(context, 'Mục Tiêu Tài Chính'),
                  const SizedBox(height: 12),
                  _buildGoalsCard(context, profile.goals ?? []),
                  const SizedBox(height: 24),

                  // Actions
                  _buildActionButtons(context),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }

          // Initial state - prompt to create profile
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_outlined,
                  size: 80,
                  color: AppColors.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Chưa có hồ sơ tài chính',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tạo hồ sơ để bắt đầu quản lý tài chính',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/financial-form'),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo Hồ Sơ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String username = 'Người dùng';
        String email = '';
        if (state is AuthAuthenticated) {
          username = state.user.username;
          email = state.user.email;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFinancialCards(BuildContext context, dynamic profile) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                context,
                icon: Icons.account_balance_wallet,
                label: 'Thu nhập',
                value: _formatCurrency(profile.monthlyIncome),
                color: AppColors.income,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                context,
                icon: Icons.savings,
                label: 'Tiết kiệm',
                value: _formatCurrency(profile.currentSavings),
                color: AppColors.savings,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                context,
                icon: Icons.credit_card,
                label: 'Nợ hiện tại',
                value: _formatCurrency(profile.currentDebt ?? 0),
                color: AppColors.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                context,
                icon: Icons.trending_up,
                label: 'Mức chấp nhận rủi ro',
                value: _getRiskLevelText(profile.riskTolerance),
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedExpensesCard(BuildContext context, List<dynamic> expenses) {
    if (expenses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Chưa có chi phí cố định',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: expenses.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.expense.withOpacity(0.1),
              child: Icon(
                _getExpenseIcon(expense.category),
                color: AppColors.expense,
              ),
            ),
            title: Text(expense.name),
            subtitle: Text(expense.category),
            trailing: Text(
              _formatCurrency(expense.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.expense,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalsCard(BuildContext context, List<String> goals) {
    if (goals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 48,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Chưa có mục tiêu tài chính',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: goals.map((goal) {
            return Chip(
              label: Text(goal),
              avatar: const Icon(Icons.check_circle, size: 18),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: TextStyle(color: AppColors.primary),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final hasExpenses =
            state is ProfileLoaded &&
            (state.profile.fixedExpenses?.isNotEmpty ?? false);

        return Column(
          children: [
            // Export CSV button
            if (hasExpenses) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _exportToCsv(context, state as ProfileLoaded),
                  icon: const Icon(Icons.download),
                  label: const Text('Xuất file CSV chi tiêu'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/financial-form'),
                icon: const Icon(Icons.edit),
                label: const Text('Cập nhật hồ sơ tài chính'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  'Đăng xuất',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _exportToCsv(BuildContext context, ProfileLoaded state) {
    final csvParser = di.sl<CsvParserService>();
    final expenses = state.profile.fixedExpenses ?? [];

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có dữ liệu chi tiêu để xuất'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final csvContent = csvParser.exportFixedExpensesToCsv(expenses);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất CSV Chi Tiêu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File CSV với ${expenses.length} khoản chi tiêu cố định:',
              style: const TextStyle(fontSize: 14),
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
            const SizedBox(height: 8),
            Text(
              'Sao chép và lưu thành file .csv để sử dụng lại',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvContent));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép vào clipboard!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Sao chép'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} tr';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }

  String _getRiskLevelText(String? level) {
    switch (level) {
      case 'low':
        return 'Thấp';
      case 'medium':
        return 'Trung bình';
      case 'high':
        return 'Cao';
      default:
        return 'Chưa xác định';
    }
  }

  IconData _getExpenseIcon(String category) {
    switch (category.toLowerCase()) {
      case 'housing':
      case 'nhà ở':
        return Icons.home;
      case 'utilities':
      case 'tiện ích':
        return Icons.electrical_services;
      case 'transportation':
      case 'đi lại':
        return Icons.directions_car;
      case 'food':
      case 'thực phẩm':
        return Icons.restaurant;
      case 'insurance':
      case 'bảo hiểm':
        return Icons.health_and_safety;
      case 'entertainment':
      case 'giải trí':
        return Icons.movie;
      default:
        return Icons.receipt;
    }
  }
}
