import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/colors.dart';
import '../../../domain/repositories/export_repository.dart';
import '../../blocs/export/export_bloc.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xuất Dữ Liệu')),
      body: BlocConsumer<ExportBloc, ExportState>(
        listener: (context, state) {
          if (state is ExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Xuất file thành công: ${state.filePath.split('/').last}',
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                action: SnackBarAction(
                  label: 'Chia sẻ',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ExportBloc>().add(
                      ExportShare(filePath: state.filePath),
                    );
                  },
                ),
              ),
            );
          }

          if (state is ExportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(context),
                const SizedBox(height: 24),

                // Export Options
                Text(
                  'Chọn định dạng xuất',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // JSON Export
                _buildExportCard(
                  context,
                  state: state,
                  icon: Icons.code,
                  title: 'JSON',
                  description:
                      'Xuất dữ liệu thô dưới dạng JSON.\n'
                      'Phù hợp để backup hoặc chuyển đổi dữ liệu.',
                  color: AppColors.secondary,
                  format: 'json',
                ),
                const SizedBox(height: 12),

                // CSV Export
                _buildExportCard(
                  context,
                  state: state,
                  icon: Icons.table_chart,
                  title: 'CSV',
                  description:
                      'Xuất bảng tính dạng CSV.\nMở được bằng Excel, Google Sheets.',
                  color: AppColors.income,
                  format: 'csv',
                ),
                const SizedBox(height: 12),

                // PDF Export
                _buildExportCard(
                  context,
                  state: state,
                  icon: Icons.picture_as_pdf,
                  title: 'PDF',
                  description:
                      'Báo cáo tài chính dạng PDF.\n'
                      'Đẹp mắt, dễ đọc và chia sẻ.',
                  color: AppColors.expense,
                  format: 'pdf',
                ),
                const SizedBox(height: 32),

                // Data Selection Section
                Text(
                  'Chọn dữ liệu xuất',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDataSelectionCard(context),
                const SizedBox(height: 32),

                // Info Section
                _buildInfoSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.download_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xuất Dữ Liệu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tải xuống hoặc chia sẻ dữ liệu tài chính của bạn',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(
    BuildContext context, {
    required ExportState state,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String format,
  }) {
    final isLoading = state is ExportLoading;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isLoading ? null : () => _handleExport(context, format),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.download, color: color, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSelectionCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDataOption(
              context,
              icon: Icons.person_outline,
              title: 'Hồ sơ tài chính',
              subtitle: 'Thông tin cá nhân và mục tiêu',
              isSelected: true,
            ),
            const Divider(height: 24),
            _buildDataOption(
              context,
              icon: Icons.receipt_long_outlined,
              title: 'Giao dịch',
              subtitle: 'Lịch sử thu chi',
              isSelected: true,
            ),
            const Divider(height: 24),
            _buildDataOption(
              context,
              icon: Icons.account_tree_outlined,
              title: 'Kế hoạch tài chính',
              subtitle: 'Kế hoạch và mục tiêu',
              isSelected: true,
            ),
            const Divider(height: 24),
            _buildDataOption(
              context,
              icon: Icons.chat_outlined,
              title: 'Lịch sử chat',
              subtitle: 'Các cuộc hội thoại với AI',
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Checkbox(
          value: isSelected,
          onChanged: (value) {
            // Handle selection change
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lưu ý về bảo mật',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dữ liệu xuất ra có thể chứa thông tin tài chính nhạy cảm. '
                  'Vui lòng bảo mật file và chỉ chia sẻ với người bạn tin tưởng.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleExport(BuildContext context, String format) {
    switch (format) {
      case 'json':
        context.read<ExportBloc>().add(const ExportSummaryJson());
        break;
      case 'csv':
        context.read<ExportBloc>().add(
          const ExportCsv(type: ExportType.summary),
        );
        break;
      case 'pdf':
        context.read<ExportBloc>().add(
          const ExportPdf(type: ExportType.summary),
        );
        break;
    }
  }
}
