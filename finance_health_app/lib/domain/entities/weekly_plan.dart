import 'package:equatable/equatable.dart';

/// Entity cho kế hoạch hàng tuần
class WeeklyPlan extends Equatable {
  final String id;
  final String planId;
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;
  final double totalBudget;
  final double spentAmount;
  final Map<String, double> categoryBudgets;
  final double dailyFoodBudget;
  final String status; // on-track | warning | over-budget

  const WeeklyPlan({
    required this.id,
    required this.planId,
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.totalBudget,
    required this.spentAmount,
    required this.categoryBudgets,
    required this.dailyFoodBudget,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    planId,
    weekNumber,
    startDate,
    endDate,
    totalBudget,
    spentAmount,
    categoryBudgets,
    dailyFoodBudget,
    status,
  ];
}
