import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/financial_profile.dart';

/// Repository interface cho Profile & Financial Data
abstract class ProfileRepository {
  /// Lấy thông tin profile tài chính của user
  Future<Either<Failure, FinancialProfile>> getProfile();

  /// Tạo profile tài chính mới
  Future<Either<Failure, FinancialProfile>> createProfile({
    required int age,
    required String gender,
    required String occupation,
    required String educationLevel,
    required double monthlyIncome,
    double? otherIncome,
    int? dependents,
    double? currentSavings,
    double? currentDebt,
    required List<FixedExpense> fixedExpenses,
    List<String>? goals,
    String? riskTolerance,
  });

  /// Cập nhật profile tài chính
  Future<Either<Failure, FinancialProfile>> updateProfile({
    int? age,
    String? gender,
    String? occupation,
    String? educationLevel,
    double? monthlyIncome,
    double? otherIncome,
    int? dependents,
    double? currentSavings,
    double? currentDebt,
    List<FixedExpense>? fixedExpenses,
    List<String>? goals,
    String? riskTolerance,
  });

  /// Thêm chi tiêu cố định
  Future<Either<Failure, FixedExpense>> addFixedExpense({
    required String name,
    required String category,
    required double amount,
    String? description,
  });

  /// Cập nhật chi tiêu cố định
  Future<Either<Failure, FixedExpense>> updateFixedExpense({
    required String id,
    String? name,
    String? category,
    double? amount,
    String? description,
  });

  /// Xóa chi tiêu cố định
  Future<Either<Failure, void>> deleteFixedExpense(String id);

  /// Lấy danh sách chi tiêu cố định
  Future<Either<Failure, List<FixedExpense>>> getFixedExpenses();
}
