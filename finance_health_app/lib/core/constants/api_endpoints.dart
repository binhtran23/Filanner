/// API Endpoints cho kết nối với FastAPI Backend
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - thay đổi theo môi trường
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  // WebSocket URL
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://localhost:8000/ws',
  );

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/signup';

  // User Profile endpoints
  static const String profile = '/profile';
  static const String userProfiles = '/profile/user';
  static const String fixedExpenses = '/profile/fixed-expenses';

  // Users
  static String userById(String id) => '/users/$id';

  // Financial Data endpoints
  static const String transactions = '/transactions';
  static const String incomes = '/transactions/incomes';
  static const String expenses = '/transactions/expenses';

  // Planner Agent endpoints
  static const String plannerGenerate = '/planner/generate';
  static const String plannerPlans = '/planner/plans';
  static String plannerPlanById(String id) => '/planner/plans/$id';
  static const String plannerNodes = '/planner/nodes';

  // Chatbot endpoints
  static const String chatMessage = '/chat/message';
  static const String chatHistory = '/chat/history';
  static const String chatWebSocket = '/chat';

  // Progress/Motivation endpoints
  static const String userProgress = '/progress';
  static const String streakDays = '/progress/streak';
  static const String rewardPoints = '/progress/rewards';

  // Export endpoints
  static const String exportPlanner = '/export/planner';
  static const String exportSummary = '/export/summary';
  static const String exportPdf = '/export/pdf';
  static const String exportCsv = '/export/csv';
  static const String exportJson = '/export/json';
}
