import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/financial_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/remote/profile_remote_datasource.dart';
import '../models/financial_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, FinancialProfile>> getProfile() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final profile = await remoteDataSource.createProfile(
        age: age,
        gender: gender,
        occupation: occupation,
        educationLevel: educationLevel,
        monthlyIncome: monthlyIncome,
        otherIncome: otherIncome,
        dependents: dependents ?? 0,
        currentSavings: currentSavings ?? 0,
        currentDebt: currentDebt,
        fixedExpenses: fixedExpenses
            .map((e) => FixedExpenseModel.fromEntity(e).toJson())
            .toList(),
        goals: goals ?? const [],
        riskTolerance: riskTolerance,
      );
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = <String, dynamic>{};
      if (age != null) data['age'] = age;
      if (gender != null) data['gender'] = gender;
      if (occupation != null) data['occupation'] = occupation;
      if (educationLevel != null) data['education_level'] = educationLevel;
      if (monthlyIncome != null) data['monthly_income'] = monthlyIncome;
      if (otherIncome != null) data['other_income'] = otherIncome;
      if (dependents != null) data['dependents'] = dependents;
      if (currentSavings != null) data['current_savings'] = currentSavings;
      if (currentDebt != null) data['current_debt'] = currentDebt;
      if (fixedExpenses != null) {
        data['fixed_expenses'] = fixedExpenses
            .map((e) => FixedExpenseModel.fromEntity(e).toJson())
            .toList();
      }
      if (goals != null) data['goals'] = goals;
      if (riskTolerance != null) data['risk_tolerance'] = riskTolerance;

      final profile = await remoteDataSource.updateProfile(data);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FixedExpense>> addFixedExpense({
    required String name,
    required String category,
    required double amount,
    String? description,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final expense = await remoteDataSource.addFixedExpense({
        'name': name,
        'category': category,
        'amount': amount,
        'description': description,
      });
      return Right(expense);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FixedExpense>> updateFixedExpense({
    required String id,
    String? name,
    String? category,
    double? amount,
    String? description,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (category != null) data['category'] = category;
      if (amount != null) data['amount'] = amount;
      if (description != null) data['description'] = description;

      final expense = await remoteDataSource.updateFixedExpense(id, data);
      return Right(expense);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFixedExpense(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteFixedExpense(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FixedExpense>>> getFixedExpenses() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final expenses = await remoteDataSource.getFixedExpenses();
      return Right(expenses);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
