import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/plan.dart';

/// Repository interface cho Planner Agent
abstract class PlannerRepository {
  /// Tạo plan mới từ AI
  Future<Either<Failure, Plan>> generatePlan();

  /// Lấy danh sách plans của user
  Future<Either<Failure, List<Plan>>> getPlans();

  /// Lấy chi tiết một plan
  Future<Either<Failure, Plan>> getPlanById(String planId);

  /// Cập nhật plan
  Future<Either<Failure, Plan>> updatePlan({
    required String planId,
    String? title,
    String? description,
    PlanStatus? status,
  });

  /// Xóa plan
  Future<Either<Failure, void>> deletePlan(String planId);

  /// Cập nhật node trong plan
  Future<Either<Failure, PlanNode>> updatePlanNode({
    required String nodeId,
    String? title,
    String? description,
    double? currentAmount,
    bool? isCompleted,
  });

  /// Lấy plan đang active
  Future<Either<Failure, Plan?>> getActivePlan();

  /// Đánh dấu node hoàn thành
  Future<Either<Failure, PlanNode>> completeNode(String nodeId);
}
