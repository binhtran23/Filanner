/// Tần suất chi tiêu
enum ExpenseFrequency {
  daily('Hàng ngày', 30),
  weekly('Hàng tuần', 4),
  monthly('Hàng tháng', 1);

  final String label;
  final int multiplier; // Hệ số quy đổi về tháng

  const ExpenseFrequency(this.label, this.multiplier);

  /// Quy đổi số tiền về tháng
  double toMonthlyAmount(double amount) => amount * multiplier;
}

/// Tình trạng hôn nhân
enum MaritalStatus {
  single('Độc thân'),
  married('Đã kết hôn'),
  divorced('Đã ly hôn'),
  widowed('Góa');

  final String label;
  const MaritalStatus(this.label);
}

/// Loại mục tiêu tài chính
enum FinancialGoalType {
  emergencySavings('Tiết kiệm khẩn cấp'),
  buyHouse('Mua nhà'),
  buyCar('Mua xe'),
  travel('Du lịch'),
  retirement('Nghỉ hưu'),
  investment('Đầu tư'),
  payDebt('Trả nợ'),
  childEducation('Giáo dục con cái'),
  wedding('Kết hôn'),
  business('Kinh doanh'),
  other('Khác');

  final String label;
  const FinancialGoalType(this.label);
}

/// Danh mục nghề nghiệp
enum OccupationCategory {
  employee('Nhân viên văn phòng'),
  freelancer('Freelancer'),
  business('Kinh doanh'),
  student('Sinh viên'),
  teacher('Giáo viên'),
  doctor('Bác sĩ'),
  engineer('Kỹ sư'),
  worker('Công nhân'),
  retired('Đã nghỉ hưu'),
  unemployed('Chưa có việc làm'),
  other('Khác');

  final String label;
  const OccupationCategory(this.label);
}
