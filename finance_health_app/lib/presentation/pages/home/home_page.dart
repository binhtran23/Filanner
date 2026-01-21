import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../../app/routes/app_router.dart';
import '../../../app/theme/colors.dart';
import '../../../core/utils/plan_generator_service.dart';
import '../../../injection_container.dart' as di;

/// Trang chủ (Dashboard)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load profile when page loads
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError && state.message.contains('Chưa có hồ sơ')) {
          // No profile, redirect to onboarding
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.onboarding);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finance Health'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Notifications
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                } else if (value == 'settings') {
                  // TODO: Navigate to settings
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: AppColors.textSecondary),
                      SizedBox(width: 12),
                      Text('Cài đặt'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Đăng xuất'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (profileState is ProfileError &&
                !profileState.message.contains('Chưa có hồ sơ')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(profileState.message),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(
                          const ProfileLoadRequested(),
                        );
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  context.go(AppRoutes.login);
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    _buildGreetingCard(context, profileState),
                    const SizedBox(height: 24),

                    // Weekly Plan Section
                    if (profileState is ProfileLoaded) ...[
                      _buildWeeklyPlanSection(context, profileState),
                      const SizedBox(height: 24),
                    ],

                    // Quick Actions
                    Text(
                      'Thao tác nhanh',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),

                    // Financial Overview
                    Text(
                      'Tổng quan tài chính',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFinancialOverview(context),
                    const SizedBox(height: 24),

                    // Recent Activities
                    Text(
                      'Hoạt động gần đây',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRecentActivities(context),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                break; // Already on home
              case 1:
                context.push(AppRoutes.planner);
                break;
              case 2:
                context.push(AppRoutes.chat);
                break;
              case 3:
                context.push(AppRoutes.profile);
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_tree_outlined),
              activeIcon: Icon(Icons.account_tree),
              label: 'Kế hoạch',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: 'Tư vấn AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ), // Closing Scaffold
    ); // Closing BlocListener
  }

  Widget _buildGreetingCard(BuildContext context, ProfileState profileState) {
    final profile = profileState is ProfileLoaded ? profileState.profile : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final username = state is AuthAuthenticated
                            ? state.user.username
                            : 'Người dùng';
                        return Text(
                          username,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Số dư khả dụng',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '0 ₫',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.add_circle_outline,
        label: 'Thêm giao dịch',
        color: AppColors.primary,
        onTap: () {
          // TODO: Add transaction
        },
      ),
      _QuickAction(
        icon: Icons.account_tree_outlined,
        label: 'Tạo kế hoạch',
        color: AppColors.secondary,
        onTap: () => context.push(AppRoutes.planner),
      ),
      _QuickAction(
        icon: Icons.chat_bubble_outline,
        label: 'Tư vấn AI',
        color: AppColors.accent,
        onTap: () => context.push(AppRoutes.chat),
      ),
      _QuickAction(
        icon: Icons.download_outlined,
        label: 'Xuất dữ liệu',
        color: AppColors.info,
        onTap: () => context.push(AppRoutes.export),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialOverview(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            context,
            icon: Icons.arrow_upward,
            title: 'Thu nhập',
            amount: '0 ₫',
            color: AppColors.income,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            context,
            icon: Icons.arrow_downward,
            title: 'Chi tiêu',
            amount: '0 ₫',
            color: AppColors.expense,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amount,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'Chưa có hoạt động nào',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.push(AppRoutes.financialForm),
              child: const Text('Bắt đầu nhập thông tin tài chính'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPlanSection(
    BuildContext context,
    ProfileLoaded profileState,
  ) {
    // Generate plan from profile
    final planGenerator = di.sl<PlanGeneratorService>();
    final now = DateTime.now();
    final totalFixedExpenses =
        profileState.profile.fixedExpenses?.fold<double>(
          0.0,
          (sum, e) => sum + e.amount,
        ) ??
        0.0;

    final monthlyPlan = planGenerator.generateMonthlyPlan(
      userId: profileState.profile.userId,
      monthlyIncome: profileState.profile.monthlyIncome,
      fixedExpenses: totalFixedExpenses,
      month: now.month,
      year: now.year,
    );

    // Find current week
    final currentWeek = monthlyPlan.weeklyPlans.firstWhere(
      (week) => now.isAfter(week.startDate) && now.isBefore(week.endDate),
      orElse: () => monthlyPlan.weeklyPlans.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kế hoạch tuần này',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.planner),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Budget Overview Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tuần ${currentWeek.weekNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          currentWeek.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(currentWeek.status),
                        style: TextStyle(
                          color: _getStatusColor(currentWeek.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat('dd/MM').format(currentWeek.startDate)} - ${DateFormat('dd/MM').format(currentWeek.endDate)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Budget Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ngân sách'),
                        Text(
                          '${NumberFormat.currency(locale: 'vi', symbol: '₫').format(currentWeek.spentAmount)} / ${NumberFormat.currency(locale: 'vi', symbol: '₫').format(currentWeek.totalBudget)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: currentWeek.totalBudget > 0
                          ? currentWeek.spentAmount / currentWeek.totalBudget
                          : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        _getStatusColor(currentWeek.status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Daily Food Budget
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ngân sách ăn uống/ngày',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'vi',
                              symbol: '₫',
                            ).format(currentWeek.dailyFoodBudget),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'on-track':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'over-budget':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'on-track':
        return 'Đúng kế hoạch';
      case 'warning':
        return 'Cảnh báo';
      case 'over-budget':
        return 'Vượt ngân sách';
      default:
        return 'Không xác định';
    }
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
