import '../../../core/errors/exceptions.dart';
import '../../models/financial_profile_model.dart';
import 'profile_remote_datasource.dart';

/// Mock implementation for Profile without backend
class ProfileRemoteDataSourceMock implements ProfileRemoteDataSource {
  FinancialProfileModel? _mockProfile;
  final List<FixedExpenseModel> _mockExpenses = [];

  @override
  Future<FinancialProfileModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_mockProfile == null) {
      throw ServerException(message: 'Chưa có hồ sơ tài chính');
    }
    return _mockProfile!;
  }

  @override
  Future<FinancialProfileModel> createProfile({
    required int age,
    required String gender,
    required String occupation,
    required String educationLevel,
    required double monthlyIncome,
    double? otherIncome,
    required List<Map<String, dynamic>> fixedExpenses,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    _mockProfile = FinancialProfileModel(
      id: 'profile_mock',
      userId: 'mock_user_id',
      age: age,
      gender: gender,
      occupation: occupation,
      educationLevel: educationLevel,
      monthlyIncome: monthlyIncome,
      otherIncome: otherIncome ?? 0,
      fixedExpenses: fixedExpenses
          .map(
            (e) => FixedExpenseModel(
              id: 'expense_${DateTime.now().millisecondsSinceEpoch}',
              name: e['name'] as String,
              amount: (e['amount'] as num).toDouble(),
              category: e['category'] as String,
            ),
          )
          .toList(),
      createdAt: DateTime.now(),
    );

    return _mockProfile!;
  }

  @override
  Future<FinancialProfileModel> updateProfile(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_mockProfile == null) {
      throw ServerException(message: 'Chưa có hồ sơ tài chính');
    }
    return _mockProfile!;
  }

  @override
  Future<FixedExpenseModel> addFixedExpense(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final expense = FixedExpenseModel(
      id: 'expense_${DateTime.now().millisecondsSinceEpoch}',
      name: data['name'] as String,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
    );

    _mockExpenses.add(expense);
    return expense;
  }

  @override
  Future<FixedExpenseModel> updateFixedExpense(
    String id,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockExpenses.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw ServerException(message: 'Không tìm thấy khoản chi');
    }
    return _mockExpenses[index];
  }

  @override
  Future<void> deleteFixedExpense(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockExpenses.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<FixedExpenseModel>> getFixedExpenses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockExpenses;
  }
}
