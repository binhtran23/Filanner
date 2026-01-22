import '../../domain/entities/incidental_expense.dart';

/// Model cho IncidentalExpense với JSON serialization
class IncidentalExpenseModel extends IncidentalExpense {
  const IncidentalExpenseModel({
    required super.percentage,
    required super.monthlyIncome,
  });

  /// Tạo từ Entity
  factory IncidentalExpenseModel.fromEntity(IncidentalExpense entity) {
    return IncidentalExpenseModel(
      percentage: entity.percentage,
      monthlyIncome: entity.monthlyIncome,
    );
  }

  /// Tạo từ JSON
  factory IncidentalExpenseModel.fromJson(Map<String, dynamic> json) {
    return IncidentalExpenseModel(
      percentage: (json['percentage'] as num).toDouble(),
      monthlyIncome: (json['monthly_income'] as num).toDouble(),
    );
  }

  /// Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {'percentage': percentage, 'monthly_income': monthlyIncome};
  }

  /// Chuyển sang Entity
  IncidentalExpense toEntity() {
    return IncidentalExpense(
      percentage: percentage,
      monthlyIncome: monthlyIncome,
    );
  }
}
