import '../../core/constants/enums.dart';
import '../../domain/entities/financial_goal.dart';

/// Model cho FinancialGoal với JSON serialization
class FinancialGoalModel extends FinancialGoal {
  const FinancialGoalModel({
    required super.id,
    required super.type,
    super.customName,
    super.targetAmount,
    super.targetDate,
    super.priority,
    required super.createdAt,
  });

  /// Tạo từ Entity
  factory FinancialGoalModel.fromEntity(FinancialGoal entity) {
    return FinancialGoalModel(
      id: entity.id,
      type: entity.type,
      customName: entity.customName,
      targetAmount: entity.targetAmount,
      targetDate: entity.targetDate,
      priority: entity.priority,
      createdAt: entity.createdAt,
    );
  }

  /// Tạo từ JSON
  factory FinancialGoalModel.fromJson(Map<String, dynamic> json) {
    return FinancialGoalModel(
      id: json['id'] as String,
      type: FinancialGoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FinancialGoalType.other,
      ),
      customName: json['custom_name'] as String?,
      targetAmount: json['target_amount'] != null
          ? (json['target_amount'] as num).toDouble()
          : null,
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      priority: json['priority'] as int? ?? 3,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'custom_name': customName,
      'target_amount': targetAmount,
      'target_date': targetDate?.toIso8601String(),
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Chuyển sang Entity
  FinancialGoal toEntity() {
    return FinancialGoal(
      id: id,
      type: type,
      customName: customName,
      targetAmount: targetAmount,
      targetDate: targetDate,
      priority: priority,
      createdAt: createdAt,
    );
  }
}
