import '../../domain/entities/monthly_plan.dart';
import 'weekly_plan_model.dart';

/// Model cho MonthlyPlan với JSON serialization
class MonthlyPlanModel extends MonthlyPlan {
  const MonthlyPlanModel({
    required super.id,
    required super.userId,
    required super.month,
    required super.year,
    required super.monthlyIncome,
    required super.fixedExpenses,
    required super.availableBudget,
    required super.savingsTarget,
    required super.weeklyPlans,
    required super.createdAt,
  });

  factory MonthlyPlanModel.fromJson(Map<String, dynamic> json) {
    return MonthlyPlanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
      monthlyIncome: (json['monthly_income'] as num).toDouble(),
      fixedExpenses: (json['fixed_expenses'] as num).toDouble(),
      availableBudget: (json['available_budget'] as num).toDouble(),
      savingsTarget: (json['savings_target'] as num).toDouble(),
      weeklyPlans: (json['weekly_plans'] as List)
          .map((e) => WeeklyPlanModel.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'month': month,
      'year': year,
      'monthly_income': monthlyIncome,
      'fixed_expenses': fixedExpenses,
      'available_budget': availableBudget,
      'savings_target': savingsTarget,
      'weekly_plans': weeklyPlans
          .map((e) => (e as WeeklyPlanModel).toJson())
          .toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
