import '../../domain/entities/plan.dart';

/// Model cho Plan với JSON serialization
class PlanModel extends Plan {
  const PlanModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.nodes,
    required super.status,
    required super.startDate,
    super.endDate,
    required super.createdAt,
    super.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      nodes:
          (json['nodes'] as List<dynamic>?)
              ?.map((e) => PlanNodeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: PlanStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PlanStatus.draft,
      ),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'nodes': nodes.map((e) => PlanNodeModel.fromEntity(e).toJson()).toList(),
      'status': status.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Model cho PlanNode
class PlanNodeModel extends PlanNode {
  const PlanNodeModel({
    required super.id,
    required super.planId,
    required super.type,
    required super.title,
    super.description,
    super.targetAmount,
    super.currentAmount,
    super.targetDate,
    super.isCompleted = false,
    super.parentNodeId,
    super.childNodeIds = const [],
    required super.order,
  });

  factory PlanNodeModel.fromJson(Map<String, dynamic> json) {
    return PlanNodeModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      type: PlanNodeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PlanNodeType.action,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      targetAmount: json['target_amount'] != null
          ? (json['target_amount'] as num).toDouble()
          : null,
      currentAmount: json['current_amount'] != null
          ? (json['current_amount'] as num).toDouble()
          : null,
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      parentNodeId: json['parent_node_id'] as String?,
      childNodeIds:
          (json['child_node_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'type': type.name,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate?.toIso8601String(),
      'is_completed': isCompleted,
      'parent_node_id': parentNodeId,
      'child_node_ids': childNodeIds,
      'order': order,
    };
  }

  factory PlanNodeModel.fromEntity(PlanNode node) {
    return PlanNodeModel(
      id: node.id,
      planId: node.planId,
      type: node.type,
      title: node.title,
      description: node.description,
      targetAmount: node.targetAmount,
      currentAmount: node.currentAmount,
      targetDate: node.targetDate,
      isCompleted: node.isCompleted,
      parentNodeId: node.parentNodeId,
      childNodeIds: node.childNodeIds,
      order: node.order,
    );
  }
}
