import 'package:equatable/equatable.dart';

/// Entity đại diện cho Plan được AI tạo ra
class Plan extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final List<PlanNode> nodes;
  final PlanStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Plan({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.nodes,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  /// Tổng mục tiêu tiết kiệm
  double get totalSavingsGoal => nodes
      .where((n) => n.type == PlanNodeType.savings)
      .fold(0, (sum, node) => sum + (node.targetAmount ?? 0));

  /// Tiến độ hoàn thành (%)
  double get progress {
    if (nodes.isEmpty) return 0;
    final completed = nodes.where((n) => n.isCompleted).length;
    return (completed / nodes.length) * 100;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    nodes,
    status,
    startDate,
    endDate,
    createdAt,
    updatedAt,
  ];
}

/// Entity đại diện cho một node trong plan
class PlanNode extends Equatable {
  final String id;
  final String planId;
  final PlanNodeType type;
  final String title;
  final String? description;
  final double? targetAmount;
  final double? currentAmount;
  final DateTime? targetDate;
  final bool isCompleted;
  final String? parentNodeId;
  final List<String> childNodeIds;
  final int order;

  const PlanNode({
    required this.id,
    required this.planId,
    required this.type,
    required this.title,
    this.description,
    this.targetAmount,
    this.currentAmount,
    this.targetDate,
    this.isCompleted = false,
    this.parentNodeId,
    this.childNodeIds = const [],
    required this.order,
  });

  /// Tiến độ của node (%)
  double get progress {
    if (targetAmount == null || targetAmount == 0) return 0;
    return ((currentAmount ?? 0) / targetAmount!) * 100;
  }

  @override
  List<Object?> get props => [
    id,
    planId,
    type,
    title,
    description,
    targetAmount,
    currentAmount,
    targetDate,
    isCompleted,
    parentNodeId,
    childNodeIds,
    order,
  ];
}

/// Loại node trong plan
enum PlanNodeType {
  income('Thu nhập'),
  expense('Chi tiêu'),
  savings('Tiết kiệm'),
  goal('Mục tiêu'),
  milestone('Cột mốc'),
  action('Hành động');

  final String label;
  const PlanNodeType(this.label);
}

/// Trạng thái của plan
enum PlanStatus {
  draft('Bản nháp'),
  active('Đang thực hiện'),
  completed('Hoàn thành'),
  archived('Đã lưu trữ');

  final String label;
  const PlanStatus(this.label);
}
