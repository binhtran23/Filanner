import '../../domain/entities/personal_finance.dart';
import 'financial_goal_model.dart';
import 'incidental_expense_model.dart';
import 'mandatory_expense_model.dart';
import 'user_profile_model.dart';

/// Model cho PersonalFinance với JSON serialization
class PersonalFinanceModel extends PersonalFinance {
  const PersonalFinanceModel({
    required super.id,
    required super.userProfile,
    required super.mandatoryExpenses,
    required super.incidentalExpense,
    required super.financialGoals,
    required super.createdAt,
    super.updatedAt,
  });

  /// Tạo từ Entity
  factory PersonalFinanceModel.fromEntity(PersonalFinance entity) {
    return PersonalFinanceModel(
      id: entity.id,
      userProfile: entity.userProfile,
      mandatoryExpenses: entity.mandatoryExpenses,
      incidentalExpense: entity.incidentalExpense,
      financialGoals: entity.financialGoals,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Tạo từ JSON
  factory PersonalFinanceModel.fromJson(Map<String, dynamic> json) {
    return PersonalFinanceModel(
      id: json['id'] as String,
      userProfile: UserProfileModel.fromJson(
        json['user_profile'] as Map<String, dynamic>,
      ),
      mandatoryExpenses: (json['mandatory_expenses'] as List<dynamic>)
          .map((e) => MandatoryExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      incidentalExpense: IncidentalExpenseModel.fromJson(
        json['incidental_expense'] as Map<String, dynamic>,
      ),
      financialGoals: (json['financial_goals'] as List<dynamic>)
          .map((e) => FinancialGoalModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_profile': UserProfileModel.fromEntity(userProfile).toJson(),
      'mandatory_expenses': mandatoryExpenses
          .map((e) => MandatoryExpenseModel.fromEntity(e).toJson())
          .toList(),
      'incidental_expense': IncidentalExpenseModel.fromEntity(
        incidentalExpense,
      ).toJson(),
      'financial_goals': financialGoals
          .map((e) => FinancialGoalModel.fromEntity(e).toJson())
          .toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Chuyển sang Entity
  PersonalFinance toEntity() {
    return PersonalFinance(
      id: id,
      userProfile: userProfile,
      mandatoryExpenses: mandatoryExpenses,
      incidentalExpense: incidentalExpense,
      financialGoals: financialGoals,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
