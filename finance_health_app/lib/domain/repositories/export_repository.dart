import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Repository interface cho Export Data
abstract class ExportRepository {
  /// Xuất planner dưới dạng JSON
  Future<Either<Failure, String>> exportPlannerJson({String? planId});

  /// Xuất summary dưới dạng JSON
  Future<Either<Failure, String>> exportSummaryJson();

  /// Xuất báo cáo PDF
  Future<Either<Failure, List<int>>> exportPdf({
    required ExportType type,
    String? planId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Xuất dữ liệu CSV
  Future<Either<Failure, String>> exportCsv({
    required ExportType type,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Lưu file xuất vào thiết bị
  Future<Either<Failure, String>> saveToDevice({
    required String fileName,
    required dynamic data,
    required FileType fileType,
  });

  /// Chia sẻ file
  Future<Either<Failure, void>> shareFile({
    required String filePath,
    String? subject,
  });
}

/// Loại export
enum ExportType { planner, transactions, profile, summary, fullBackup }

/// Loại file
enum FileType { json, csv, pdf }
