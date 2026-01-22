import '../../core/constants/enums.dart';
import '../../domain/entities/user_profile.dart';

/// Model cho UserProfile với JSON serialization
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.age,
    required super.occupation,
    required super.maritalStatus,
    required super.monthlyIncome,
    super.hasDebt,
    super.totalDebt,
    required super.createdAt,
    super.updatedAt,
  });

  /// Tạo từ Entity
  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      age: entity.age,
      occupation: entity.occupation,
      maritalStatus: entity.maritalStatus,
      monthlyIncome: entity.monthlyIncome,
      hasDebt: entity.hasDebt,
      totalDebt: entity.totalDebt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Tạo từ JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      age: json['age'] as int,
      occupation: json['occupation'] as String,
      maritalStatus: MaritalStatus.values.firstWhere(
        (e) => e.name == json['marital_status'],
        orElse: () => MaritalStatus.single,
      ),
      monthlyIncome: (json['monthly_income'] as num).toDouble(),
      hasDebt: json['has_debt'] as bool? ?? false,
      totalDebt: json['total_debt'] != null
          ? (json['total_debt'] as num).toDouble()
          : null,
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
      'age': age,
      'occupation': occupation,
      'marital_status': maritalStatus.name,
      'monthly_income': monthlyIncome,
      'has_debt': hasDebt,
      'total_debt': totalDebt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Chuyển sang Entity
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      age: age,
      occupation: occupation,
      maritalStatus: maritalStatus,
      monthlyIncome: monthlyIncome,
      hasDebt: hasDebt,
      totalDebt: totalDebt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
