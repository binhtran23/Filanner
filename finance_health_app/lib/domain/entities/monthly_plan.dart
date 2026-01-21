import 'package:equatable/equatable.dart';
import 'weekly_plan.dart';

/// Entity cho kế hoạch hàng tháng
class MonthlyPlan extends Equatable {
  final String id;
  final String userId;
  final int month;
  final int year;
  final double monthlyIncome;
  final double fixedExpenses;
  final double availableBudget;
  final double savingsTarget;
  final List<WeeklyPlan> weeklyPlans;
  final DateTime createdAt;

  const MonthlyPlan({
    required this.id,
    required this.userId,
    required this.month,
    required this.year,
    required this.monthlyIncome,
    required this.fixedExpenses,
    required this.availableBudget,
    required this.savingsTarget,
    required this.weeklyPlans,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    month,
    year,
    monthlyIncome,
    fixedExpenses,
    availableBudget,
    savingsTarget,
    weeklyPlans,
    createdAt,
  ];
}
