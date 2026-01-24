import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/financial_profile_model.dart';

/// Remote data source cho Profile
abstract class ProfileRemoteDataSource {
  Future<FinancialProfileModel> getProfile();

  Future<FinancialProfileModel> createProfile({
    required int age,
    required String gender,
    required String occupation,
    required String educationLevel,
    required double monthlyIncome,
    double? otherIncome,
    int? dependents,
    double? currentSavings,
    double? currentDebt,
    required List<Map<String, dynamic>> fixedExpenses,
    List<String>? goals,
    String? riskTolerance,
  });

  Future<FinancialProfileModel> updateProfile(Map<String, dynamic> data);

  Future<FixedExpenseModel> addFixedExpense(Map<String, dynamic> data);

  Future<FixedExpenseModel> updateFixedExpense(
    String id,
    Map<String, dynamic> data,
  );

  Future<void> deleteFixedExpense(String id);

  Future<List<FixedExpenseModel>> getFixedExpenses();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<FinancialProfileModel> getProfile() async {
    try {
      final response = await dioClient.get(ApiEndpoints.profile);
      return FinancialProfileModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<FinancialProfileModel> createProfile({
    required int age,
    required String gender,
    required String occupation,
    required String educationLevel,
    required double monthlyIncome,
    double? otherIncome,
    int? dependents,
    double? currentSavings,
    double? currentDebt,
    required List<Map<String, dynamic>> fixedExpenses,
    List<String>? goals,
    String? riskTolerance,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.profile,
        data: {
          'age': age,
          'gender': gender,
          'occupation': occupation,
          'education_level': educationLevel,
          'monthly_income': monthlyIncome,
          'other_income': otherIncome,
          'dependents': dependents,
          'current_savings': currentSavings,
          'current_debt': currentDebt,
          'fixed_expenses': fixedExpenses,
          'goals': goals,
          'risk_tolerance': riskTolerance,
        },
      );
      return FinancialProfileModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<FinancialProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(ApiEndpoints.profile, data: data);
      return FinancialProfileModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<FixedExpenseModel> addFixedExpense(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.fixedExpenses,
        data: data,
      );
      return FixedExpenseModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<FixedExpenseModel> updateFixedExpense(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dioClient.put(
        '${ApiEndpoints.fixedExpenses}/$id',
        data: data,
      );
      return FixedExpenseModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteFixedExpense(String id) async {
    try {
      await dioClient.delete('${ApiEndpoints.fixedExpenses}/$id');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<FixedExpenseModel>> getFixedExpenses() async {
    try {
      final response = await dioClient.get(ApiEndpoints.fixedExpenses);
      return (response.data as List)
          .map((e) => FixedExpenseModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
