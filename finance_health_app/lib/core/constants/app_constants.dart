/// Các hằng số chung cho ứng dụng
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Finance Health';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String onboardingKey = 'onboarding_completed';

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String profileBox = 'profile_box';
  static const String transactionsBox = 'transactions_box';
  static const String plannerBox = 'planner_box';
  static const String chatBox = 'chat_box';
  static const String settingsBox = 'settings_box';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Currency
  static const String defaultCurrency = 'VND';
  static const String currencySymbol = '₫';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String monthYearFormat = 'MM/yyyy';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;

  // Financial Categories
  static const List<String> expenseCategories = [
    'Ăn uống',
    'Đi lại',
    'Nhà cửa',
    'Điện nước',
    'Giải trí',
    'Mua sắm',
    'Sức khỏe',
    'Giáo dục',
    'Tiết kiệm',
    'Khác',
  ];

  static const List<String> incomeCategories = [
    'Lương',
    'Thưởng',
    'Đầu tư',
    'Kinh doanh',
    'Freelance',
    'Khác',
  ];

  // Education Levels
  static const List<String> educationLevels = [
    'Trung học cơ sở',
    'Trung học phổ thông',
    'Cao đẳng',
    'Đại học',
    'Thạc sĩ',
    'Tiến sĩ',
    'Khác',
  ];

  // Gender Options
  static const List<String> genderOptions = ['Nam', 'Nữ', 'Khác'];

  // Financial Goals
  static const List<String> financialGoals = [
    'Tiết kiệm khẩn cấp',
    'Mua nhà',
    'Mua xe',
    'Du lịch',
    'Nghỉ hưu',
    'Đầu tư',
    'Trả nợ',
    'Giáo dục con cái',
    'Kết hôn',
    'Kinh doanh',
    'Khác',
  ];

  // Risk Tolerance Levels
  static const List<String> riskToleranceLevels = ['low', 'medium', 'high'];
}
