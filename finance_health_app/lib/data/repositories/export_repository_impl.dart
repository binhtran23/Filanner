import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/export_repository.dart';
import '../datasources/remote/export_remote_datasource.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ExportRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> exportPlannerJson({String? planId}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final json = await remoteDataSource.exportPlannerJson(planId: planId);
      return Right(json);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportSummaryJson() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final json = await remoteDataSource.exportSummaryJson();
      return Right(json);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> exportPdf({
    required ExportType type,
    String? planId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final params = <String, dynamic>{
        'type': type.name,
        if (planId != null) 'plan_id': planId,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final pdfBytes = await remoteDataSource.exportPdf(params);
      return Right(pdfBytes);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportCsv({
    required ExportType type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final params = <String, dynamic>{
        'type': type.name,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final csv = await remoteDataSource.exportCsv(params);
      return Right(csv);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveToDevice({
    required String fileName,
    required dynamic data,
    required FileType fileType,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final extension = _getFileExtension(fileType);
      final filePath = '${directory.path}/$fileName$extension';
      final file = File(filePath);

      if (data is List<int>) {
        await file.writeAsBytes(data);
      } else if (data is String) {
        await file.writeAsString(data);
      } else {
        return const Left(
          ValidationFailure(message: 'Định dạng dữ liệu không hỗ trợ'),
        );
      }

      return Right(filePath);
    } catch (e) {
      return Left(CacheFailure(message: 'Không thể lưu file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> shareFile({
    required String filePath,
    String? subject,
  }) async {
    try {
      await Share.shareXFiles([XFile(filePath)], subject: subject);
      return const Right(null);
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Không thể chia sẻ file: ${e.toString()}'),
      );
    }
  }

  String _getFileExtension(FileType fileType) {
    switch (fileType) {
      case FileType.json:
        return '.json';
      case FileType.csv:
        return '.csv';
      case FileType.pdf:
        return '.pdf';
    }
  }
}
