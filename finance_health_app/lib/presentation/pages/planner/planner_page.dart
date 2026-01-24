import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graphview/graphview.dart' as graphview;  // Temporarily disabled

import '../../../app/theme/colors.dart';
import '../../../domain/entities/plan.dart';
import '../../blocs/planner/planner_bloc.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  // Temporarily removed graph functionality
  // final graphview.Graph graph = graphview.Graph();
  // graphview.BuchheimWalkerConfiguration builder =
  //     graphview.BuchheimWalkerConfiguration();

  PlanNode? _selectedNode;

  @override
  void initState() {
    super.initState();
    // _setupGraphConfig();
    context.read<PlannerBloc>().add(const PlannerLoadRequested());
  }

  // void _setupGraphConfig() {
  //   builder
  //     ..siblingSeparation = 60
  //     ..levelSeparation = 80
  //     ..subtreeSeparation = 80
  //     ..orientation =
  //         graphview.BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kế Hoạch Tài Chính'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<PlannerBloc>().add(const PlannerLoadRequested()),
            tooltip: 'Tải lại',
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _showGeneratePlanDialog(),
            tooltip: 'Tạo kế hoạch mới',
          ),
        ],
      ),
      body: BlocConsumer<PlannerBloc, PlannerState>(
        listener: (context, state) {
          if (state is PlannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is PlannerGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kế hoạch đã được tạo thành công!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PlannerLoading || state is PlannerGenerating) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải kế hoạch...'),
                ],
              ),
            );
          }

          if (state is PlannerLoaded) {
            final plan = state.activePlan ?? state.selectedPlan;
            if (plan != null) {
              return _buildPlanContent(plan);
            }
            return _buildEmptyState();
          }

          if (state is PlannerGenerated) {
            return _buildPlanContent(state.plan);
          }

          // Initial state - no plan yet
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_tree_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có kế hoạch tài chính',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tạo kế hoạch tài chính cá nhân hóa dựa trên AI để đạt được mục tiêu của bạn',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showGeneratePlanDialog(),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Tạo Kế Hoạch Mới'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanContent(Plan plan) {
    // Temporarily disabled graph visualization
    // _buildGraph(plan);

    return Column(
      children: [
        // Plan Header
        _buildPlanHeader(plan),

        // Simple List View (replacing Graph View temporarily)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plan.nodes.length,
            itemBuilder: (context, index) {
              final node = plan.nodes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedNode = node),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (node.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            node.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Selected Node Details
        if (_selectedNode != null) _buildNodeDetails(_selectedNode!),
      ],
    );
  }

  // Temporarily disabled graph building
  // void _buildGraph(Plan plan) {
  //   graph.nodes.clear();
  //   graph.edges.clear();
  //
  //   if (plan.nodes.isEmpty) return;
  //
  //   // Create nodes map
  //   final nodeMap = <String, graphview.Node>{};
  //   for (final node in plan.nodes) {
  //     final graphNode = graphview.Node.Id(node);
  //     nodeMap[node.id] = graphNode;
  //     graph.addNode(graphNode);
  //   }
  //
  //   // Create edges based on parentNodeId
  //   for (final node in plan.nodes) {
  //     if (node.parentNodeId != null && nodeMap.containsKey(node.parentNodeId)) {
  //       final parentNode = nodeMap[node.parentNodeId]!;
  //       final childNode = nodeMap[node.id]!;
  //       graph.addEdge(parentNode, childNode);
  //     }
  //   }
  // }

  Widget _buildPlanHeader(Plan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cập nhật: ${_formatDate(plan.updatedAt ?? plan.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_tree,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${plan.nodes.length} bước',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (plan.description != null) ...[
            const SizedBox(height: 8),
            Text(
              plan.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          // Progress bar
          LinearProgressIndicator(
            value: plan.progress / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '${plan.progress.toStringAsFixed(0)}% hoàn thành',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget(PlanNode node) {
    final isSelected = _selectedNode?.id == node.id;
    final statusColor = _getStatusColor(node.isCompleted);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNode = isSelected ? null : node;
        });
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? statusColor.withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? statusColor
                : statusColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(node.isCompleted),
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              node.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Amount if exists
            if (node.targetAmount != null)
              Text(
                _formatCurrency(node.targetAmount!),
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

            // Status Text
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getStatusText(node.isCompleted),
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeDetails(PlanNode node) {
    final statusColor = _getStatusColor(node.isCompleted);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(node.isCompleted),
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStatusText(node.isCompleted),
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedNode = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (node.description != null)
            Text(
              node.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (node.targetAmount != null)
                Expanded(
                  child: _buildDetailItem(
                    'Mục tiêu',
                    _formatCurrency(node.targetAmount!),
                  ),
                ),
              if (node.targetDate != null)
                Expanded(
                  child: _buildDetailItem(
                    'Thời hạn',
                    _formatDate(node.targetDate!),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!node.isCompleted)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _completeNode(node),
                    icon: const Icon(Icons.check),
                    label: const Text('Hoàn thành'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showGeneratePlanDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tạo Kế Hoạch Mới'),
        content: const Text(
          'AI sẽ phân tích hồ sơ tài chính của bạn và tạo kế hoạch tài chính cá nhân hóa. '
          'Quá trình này có thể mất vài giây.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PlannerBloc>().add(const PlannerGenerateRequested());
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Tạo kế hoạch'),
          ),
        ],
      ),
    );
  }

  void _completeNode(PlanNode node) {
    context.read<PlannerBloc>().add(PlannerNodeComplete(nodeId: node.id));
    setState(() {
      _selectedNode = null;
    });
  }

  Color _getStatusColor(bool isCompleted) {
    return isCompleted ? AppColors.success : AppColors.textSecondary;
  }

  IconData _getStatusIcon(bool isCompleted) {
    return isCompleted ? Icons.check_circle : Icons.radio_button_unchecked;
  }

  String _getStatusText(bool isCompleted) {
    return isCompleted ? 'Hoàn thành' : 'Chưa hoàn thành';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '${amount.toStringAsFixed(0)}đ';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
