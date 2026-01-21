import '../../domain/entities/weekly_plan.dart';

/// Model cho WeeklyPlan với JSON serialization
class WeeklyPlanModel extends WeeklyPlan {
  const WeeklyPlanModel({
    required super.id,
    required super.planId,
    required super.weekNumber,
    required super.startDate,
    required super.endDate,
    required super.totalBudget,
    required super.spentAmount,
    required super.categoryBudgets,
    required super.dailyFoodBudget,
    required super.status,
  });

  factory WeeklyPlanModel.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      weekNumber: json['week_number'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalBudget: (json['total_budget'] as num).toDouble(),
      spentAmount: (json['spent_amount'] as num).toDouble(),
      categoryBudgets: Map<String, double>.from(
        (json['category_budgets'] as Map).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      dailyFoodBudget: (json['daily_food_budget'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'week_number': weekNumber,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_budget': totalBudget,
      'spent_amount': spentAmount,
      'category_budgets': categoryBudgets,
      'daily_food_budget': dailyFoodBudget,
      'status': status,
    };
  }
}
