import '../../core/constants/enums.dart';
import '../../domain/entities/mandatory_expense.dart';

/// Model cho MandatoryExpense với JSON serialization
class MandatoryExpenseModel extends MandatoryExpense {
  const MandatoryExpenseModel({
    required super.id,
    required super.name,
    required super.estimatedAmount,
    required super.frequency,
    super.note,
    required super.createdAt,
  });

  /// Tạo từ Entity
  factory MandatoryExpenseModel.fromEntity(MandatoryExpense entity) {
    return MandatoryExpenseModel(
      id: entity.id,
      name: entity.name,
      estimatedAmount: entity.estimatedAmount,
      frequency: entity.frequency,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }

  /// Tạo từ JSON
  factory MandatoryExpenseModel.fromJson(Map<String, dynamic> json) {
    return MandatoryExpenseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      estimatedAmount: (json['estimated_amount'] as num).toDouble(),
      frequency: ExpenseFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => ExpenseFrequency.monthly,
      ),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'estimated_amount': estimatedAmount,
      'frequency': frequency.name,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Chuyển sang Entity
  MandatoryExpense toEntity() {
    return MandatoryExpense(
      id: id,
      name: name,
      estimatedAmount: estimatedAmount,
      frequency: frequency,
      note: note,
      createdAt: createdAt,
    );
  }
}
