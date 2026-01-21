import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';

/// Remote data source cho Export
abstract class ExportRemoteDataSource {
  Future<String> exportPlannerJson({String? planId});
  Future<String> exportSummaryJson();
  Future<List<int>> exportPdf(Map<String, dynamic> params);
  Future<String> exportCsv(Map<String, dynamic> params);
}

class ExportRemoteDataSourceImpl implements ExportRemoteDataSource {
  final DioClient dioClient;

  ExportRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<String> exportPlannerJson({String? planId}) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.exportPlanner,
        queryParameters: {
          if (planId != null) 'plan_id': planId,
          'format': 'json',
        },
      );
      return response.data.toString();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> exportSummaryJson() async {
    try {
      final response = await dioClient.get(ApiEndpoints.exportSummary);
      return response.data.toString();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<int>> exportPdf(Map<String, dynamic> params) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.exportPdf,
        queryParameters: params,
      );
      return List<int>.from(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> exportCsv(Map<String, dynamic> params) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.exportCsv,
        queryParameters: params,
      );
      return response.data.toString();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
