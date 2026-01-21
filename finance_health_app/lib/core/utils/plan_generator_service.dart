import '../../data/models/monthly_plan_model.dart';
import '../../data/models/weekly_plan_model.dart';

/// Service để generate kế hoạch tài chính tự động
class PlanGeneratorService {
  /// Generate monthly plan from profile data
  MonthlyPlanModel generateMonthlyPlan({
    required String userId,
    required double monthlyIncome,
    required double fixedExpenses,
    int? month,
    int? year,
  }) {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    // Calculate available budget
    final availableBudget = monthlyIncome - fixedExpenses;
    final savingsTarget = availableBudget * 0.2; // 20% savings

    // Budget for spending (80% of available)
    final spendingBudget = availableBudget - savingsTarget;

    // Divide into 4 weeks
    final weeklyBudget = spendingBudget / 4;

    // Generate weekly plans
    final weeklyPlans = _generateWeeklyPlans(
      targetMonth: targetMonth,
      targetYear: targetYear,
      weeklyBudget: weeklyBudget,
      userId: userId,
    );

    return MonthlyPlanModel(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      month: targetMonth,
      year: targetYear,
      monthlyIncome: monthlyIncome,
      fixedExpenses: fixedExpenses,
      availableBudget: availableBudget,
      savingsTarget: savingsTarget,
      weeklyPlans: weeklyPlans,
      createdAt: DateTime.now(),
    );
  }

  List<WeeklyPlanModel> _generateWeeklyPlans({
    required int targetMonth,
    required int targetYear,
    required double weeklyBudget,
    required String userId,
  }) {
    final weeks = <WeeklyPlanModel>[];
    final firstDayOfMonth = DateTime(targetYear, targetMonth, 1);

    for (int weekNum = 1; weekNum <= 4; weekNum++) {
      final startDay = (weekNum - 1) * 7 + 1;
      final endDay = weekNum * 7;

      final startDate = DateTime(targetYear, targetMonth, startDay);
      final endDate = DateTime(targetYear, targetMonth, endDay);

      // Simple allocation: 40% food, 30% entertainment, 20% shopping, 10% other
      final categoryBudgets = {
        'Ăn uống': weeklyBudget * 0.4,
        'Giải trí': weeklyBudget * 0.3,
        'Mua sắm': weeklyBudget * 0.2,
        'Khác': weeklyBudget * 0.1,
      };

      final dailyFoodBudget = (weeklyBudget * 0.4) / 7;

      weeks.add(
        WeeklyPlanModel(
          id: 'week_${weekNum}_${DateTime.now().millisecondsSinceEpoch}',
          planId: 'plan_${DateTime.now().millisecondsSinceEpoch}',
          weekNumber: weekNum,
          startDate: startDate,
          endDate: endDate,
          totalBudget: weeklyBudget,
          spentAmount: 0,
          categoryBudgets: categoryBudgets,
          dailyFoodBudget: dailyFoodBudget,
          status: 'on-track',
        ),
      );
    }

    return weeks;
  }
}
