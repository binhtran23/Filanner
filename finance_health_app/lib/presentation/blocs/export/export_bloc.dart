import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/export_repository.dart';

/// Events
abstract class ExportEvent extends Equatable {
  const ExportEvent();
  @override
  List<Object?> get props => [];
}

class ExportPlannerJson extends ExportEvent {
  final String? planId;

  const ExportPlannerJson({this.planId});

  @override
  List<Object?> get props => [planId];
}

class ExportSummaryJson extends ExportEvent {
  const ExportSummaryJson();
}

class ExportPdf extends ExportEvent {
  final ExportType type;
  final String? planId;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportPdf({
    required this.type,
    this.planId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [type, planId, startDate, endDate];
}

class ExportCsv extends ExportEvent {
  final ExportType type;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportCsv({required this.type, this.startDate, this.endDate});

  @override
  List<Object?> get props => [type, startDate, endDate];
}

class ExportShare extends ExportEvent {
  final String filePath;
  final String? subject;

  const ExportShare({required this.filePath, this.subject});

  @override
  List<Object?> get props => [filePath, subject];
}

/// States
abstract class ExportState extends Equatable {
  const ExportState();
  @override
  List<Object?> get props => [];
}

class ExportInitial extends ExportState {
  const ExportInitial();
}

class ExportLoading extends ExportState {
  final String message;

  const ExportLoading({this.message = 'Đang xuất dữ liệu...'});

  @override
  List<Object?> get props => [message];
}

class ExportSuccess extends ExportState {
  final String filePath;
  final String message;

  const ExportSuccess({
    required this.filePath,
    this.message = 'Xuất dữ liệu thành công!',
  });

  @override
  List<Object?> get props => [filePath, message];
}

class ExportError extends ExportState {
  final String message;

  const ExportError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ExportShared extends ExportState {
  const ExportShared();
}

/// BLoC
class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ExportRepository exportRepository;

  ExportBloc({required this.exportRepository}) : super(const ExportInitial()) {
    on<ExportPlannerJson>(_onExportPlannerJson);
    on<ExportSummaryJson>(_onExportSummaryJson);
    on<ExportPdf>(_onExportPdf);
    on<ExportCsv>(_onExportCsv);
    on<ExportShare>(_onShare);
  }

  Future<void> _onExportPlannerJson(
    ExportPlannerJson event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportLoading(message: 'Đang xuất Planner JSON...'));

    final result = await exportRepository.exportPlannerJson(
      planId: event.planId,
    );

    await result.fold(
      (failure) async => emit(ExportError(message: failure.message)),
      (json) async {
        final fileName = 'planner_${DateTime.now().millisecondsSinceEpoch}';
        final saveResult = await exportRepository.saveToDevice(
          fileName: fileName,
          data: json,
          fileType: FileType.json,
        );

        saveResult.fold(
          (failure) => emit(ExportError(message: failure.message)),
          (filePath) => emit(ExportSuccess(filePath: filePath)),
        );
      },
    );
  }

  Future<void> _onExportSummaryJson(
    ExportSummaryJson event,
    Emitter<ExportState> emit,
  ) async {
    emit(const ExportLoading(message: 'Đang xuất Summary JSON...'));

    final result = await exportRepository.exportSummaryJson();

    await result.fold(
      (failure) async => emit(ExportError(message: failure.message)),
      (json) async {
        final fileName = 'summary_${DateTime.now().millisecondsSinceEpoch}';
        final saveResult = await exportRepository.saveToDevice(
          fileName: fileName,
          data: json,
          fileType: FileType.json,
        );

        saveResult.fold(
          (failure) => emit(ExportError(message: failure.message)),
          (filePath) => emit(ExportSuccess(filePath: filePath)),
        );
      },
    );
  }

  Future<void> _onExportPdf(ExportPdf event, Emitter<ExportState> emit) async {
    emit(const ExportLoading(message: 'Đang tạo PDF...'));

    final result = await exportRepository.exportPdf(
      type: event.type,
      planId: event.planId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    await result.fold(
      (failure) async => emit(ExportError(message: failure.message)),
      (pdfBytes) async {
        final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}';
        final saveResult = await exportRepository.saveToDevice(
          fileName: fileName,
          data: pdfBytes,
          fileType: FileType.pdf,
        );

        saveResult.fold(
          (failure) => emit(ExportError(message: failure.message)),
          (filePath) => emit(ExportSuccess(filePath: filePath)),
        );
      },
    );
  }

  Future<void> _onExportCsv(ExportCsv event, Emitter<ExportState> emit) async {
    emit(const ExportLoading(message: 'Đang xuất CSV...'));

    final result = await exportRepository.exportCsv(
      type: event.type,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    await result.fold(
      (failure) async => emit(ExportError(message: failure.message)),
      (csv) async {
        final fileName = 'data_${DateTime.now().millisecondsSinceEpoch}';
        final saveResult = await exportRepository.saveToDevice(
          fileName: fileName,
          data: csv,
          fileType: FileType.csv,
        );

        saveResult.fold(
          (failure) => emit(ExportError(message: failure.message)),
          (filePath) => emit(ExportSuccess(filePath: filePath)),
        );
      },
    );
  }

  Future<void> _onShare(ExportShare event, Emitter<ExportState> emit) async {
    final result = await exportRepository.shareFile(
      filePath: event.filePath,
      subject: event.subject,
    );

    result.fold(
      (failure) => emit(ExportError(message: failure.message)),
      (_) => emit(const ExportShared()),
    );
  }
}
