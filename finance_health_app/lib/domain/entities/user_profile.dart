import 'package:equatable/equatable.dart';

import '../../core/constants/enums.dart';

/// Entity đại diện cho thông tin người dùng
/// Bao gồm các trường bắt buộc (*) và tùy chọn (?)
class UserProfile extends Equatable {
  /// ID duy nhất của profile
  final String id;

  // ===== TRƯỜNG BẮT BUỘC (*) =====

  /// Tuổi tác (*)
  final int age;

  /// Nghề nghiệp (*)
  final String occupation;

  /// Tình trạng hôn nhân (*)
  final MaritalStatus maritalStatus;

  /// Thu nhập hàng tháng (*) - phải > 0
  final double monthlyIncome;

  // ===== TRƯỜNG TÙY CHỌN (?) =====

  /// Có nợ hay không (?)
  /// true: Có nợ -> yêu cầu totalDebt
  /// false: Không có nợ
  final bool hasDebt;

  /// Tổng nợ (?) - chỉ yêu cầu khi hasDebt = true
  final double? totalDebt;

  /// Ngày tạo
  final DateTime createdAt;

  /// Ngày cập nhật
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.age,
    required this.occupation,
    required this.maritalStatus,
    required this.monthlyIncome,
    this.hasDebt = false,
    this.totalDebt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Tạo bản sao với các giá trị mới
  UserProfile copyWith({
    String? id,
    int? age,
    String? occupation,
    MaritalStatus? maritalStatus,
    double? monthlyIncome,
    bool? hasDebt,
    double? totalDebt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      age: age ?? this.age,
      occupation: occupation ?? this.occupation,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      hasDebt: hasDebt ?? this.hasDebt,
      totalDebt: totalDebt ?? this.totalDebt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Kiểm tra tính hợp lệ của profile
  bool get isValid {
    // Thu nhập phải > 0
    if (monthlyIncome <= 0) return false;

    // Nếu có nợ thì totalDebt phải > 0
    if (hasDebt && (totalDebt == null || totalDebt! <= 0)) return false;

    // Tuổi hợp lệ
    if (age < 18 || age > 120) return false;

    return true;
  }

  @override
  List<Object?> get props => [
    id,
    age,
    occupation,
    maritalStatus,
    monthlyIncome,
    hasDebt,
    totalDebt,
    createdAt,
    updatedAt,
  ];
}
