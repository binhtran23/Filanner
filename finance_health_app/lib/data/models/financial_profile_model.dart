import '../../domain/entities/financial_profile.dart';

/// Model cho FinancialProfile với JSON serialization
class FinancialProfileModel extends FinancialProfile {
  const FinancialProfileModel({
    required super.id,
    required super.userId,
    required super.age,
    required super.gender,
    required super.occupation,
    super.educationLevel,
    super.dependents,
    required super.monthlyIncome,
    super.otherIncome,
    super.currentSavings,
    super.currentDebt,
    super.fixedExpenses,
    super.goals,
    super.riskTolerance,
    required super.createdAt,
    super.updatedAt,
  });

  /// Tạo từ JSON
  factory FinancialProfileModel.fromJson(Map<String, dynamic> json) {
    return FinancialProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      occupation: json['occupation'] as String,
      educationLevel: json['education_level'] as String?,
      dependents: json['dependents'] as int? ?? 0,
      monthlyIncome: (json['monthly_income'] as num).toDouble(),
      otherIncome: json['other_income'] != null
          ? (json['other_income'] as num).toDouble()
          : null,
      currentSavings: json['current_savings'] != null
          ? (json['current_savings'] as num).toDouble()
          : 0,
      currentDebt: json['current_debt'] != null
          ? (json['current_debt'] as num).toDouble()
          : null,
      fixedExpenses: (json['fixed_expenses'] as List<dynamic>?)
          ?.map((e) => FixedExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      goals: (json['goals'] as List<dynamic>?)?.cast<String>(),
      riskTolerance: json['risk_tolerance'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'education_level': educationLevel,
      'dependents': dependents,
      'monthly_income': monthlyIncome,
      'other_income': otherIncome,
      'current_savings': currentSavings,
      'current_debt': currentDebt,
      'fixed_expenses': fixedExpenses
          ?.map((e) => FixedExpenseModel.fromEntity(e).toJson())
          .toList(),
      'goals': goals,
      'risk_tolerance': riskTolerance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Model cho FixedExpense
class FixedExpenseModel extends FixedExpense {
  const FixedExpenseModel({
    required super.id,
    required super.name,
    required super.category,
    required super.amount,
    super.description,
  });

  factory FixedExpenseModel.fromJson(Map<String, dynamic> json) {
    return FixedExpenseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'description': description,
    };
  }

  factory FixedExpenseModel.fromEntity(FixedExpense expense) {
    return FixedExpenseModel(
      id: expense.id,
      name: expense.name,
      category: expense.category,
      amount: expense.amount,
      description: expense.description,
    );
  }
}
