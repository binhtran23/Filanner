import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/plan_model.dart';

/// Remote data source cho Planner
abstract class PlannerRemoteDataSource {
  Future<PlanModel> generatePlan();
  Future<List<PlanModel>> getPlans();
  Future<PlanModel> getPlanById(String planId);
  Future<PlanModel> updatePlan(String planId, Map<String, dynamic> data);
  Future<void> deletePlan(String planId);
  Future<PlanNodeModel> updatePlanNode(
    String nodeId,
    Map<String, dynamic> data,
  );
  Future<PlanModel?> getActivePlan();
}

class PlannerRemoteDataSourceImpl implements PlannerRemoteDataSource {
  final DioClient dioClient;

  PlannerRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<PlanModel> generatePlan() async {
    try {
      final response = await dioClient.post(ApiEndpoints.plannerGenerate);
      return PlanModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PlanModel>> getPlans() async {
    try {
      final response = await dioClient.get(ApiEndpoints.plannerPlans);
      return (response.data as List).map((e) => PlanModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PlanModel> getPlanById(String planId) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.plannerPlanById(planId),
      );
      return PlanModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PlanModel> updatePlan(String planId, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        ApiEndpoints.plannerPlanById(planId),
        data: data,
      );
      return PlanModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deletePlan(String planId) async {
    try {
      await dioClient.delete(ApiEndpoints.plannerPlanById(planId));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PlanNodeModel> updatePlanNode(
    String nodeId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dioClient.put(
        '${ApiEndpoints.plannerNodes}/$nodeId',
        data: data,
      );
      return PlanNodeModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PlanModel?> getActivePlan() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.plannerPlans,
        queryParameters: {'status': 'active'},
      );
      final plans = (response.data as List)
          .map((e) => PlanModel.fromJson(e))
          .toList();
      return plans.isNotEmpty ? plans.first : null;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
