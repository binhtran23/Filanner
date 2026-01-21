import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';

// Pages
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/profile/financial_form_page.dart';
import '../../presentation/pages/planner/planner_page.dart';
import '../../presentation/pages/chat/chat_page.dart';
import '../../presentation/pages/progress/progress_page.dart';
import '../../presentation/pages/export/export_page.dart';

/// Route paths
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String financialForm = '/financial-form';
  static const String planner = '/planner';
  static const String chat = '/chat';
  static const String progress = '/progress';
  static const String export = '/export';
}

/// Router configuration
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,

      // Redirect logic based on auth state
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isLoading = authState is AuthLoading || authState is AuthInitial;
        final isLoggingIn = state.matchedLocation == AppRoutes.login;
        final isRegistering = state.matchedLocation == AppRoutes.register;
        final isSplash = state.matchedLocation == AppRoutes.splash;

        // Nếu đang loading, ở lại splash
        if (isLoading && isSplash) return null;

        // Nếu đang ở splash và đã xác định auth state
        if (isSplash && !isLoading) {
          return isAuthenticated ? AppRoutes.home : AppRoutes.login;
        }

        // Nếu chưa đăng nhập và không phải đang ở login/register/splash
        if (!isAuthenticated &&
            !isLoading &&
            !isLoggingIn &&
            !isRegistering &&
            !isSplash) {
          return AppRoutes.login;
        }

        // Nếu đã đăng nhập và đang ở login/register
        if (isAuthenticated && (isLoggingIn || isRegistering)) {
          return AppRoutes.home;
        }

        return null;
      },

      // Listen to auth changes
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

      routes: [
        // Splash
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),

        // Auth routes
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),

        // Onboarding
        GoRoute(
          path: AppRoutes.onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),

        // Main routes (authenticated)
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.financialForm,
          name: 'financialForm',
          builder: (context, state) => const FinancialFormPage(),
        ),
        GoRoute(
          path: AppRoutes.planner,
          name: 'planner',
          builder: (context, state) => const PlannerPage(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          name: 'chat',
          builder: (context, state) => const ChatPage(),
        ),
        GoRoute(
          path: AppRoutes.progress,
          name: 'progress',
          builder: (context, state) => const ProgressPage(),
        ),
        GoRoute(
          path: AppRoutes.export,
          name: 'export',
          builder: (context, state) => const ExportPage(),
        ),
      ],

      errorBuilder: (context, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
    );
  }
}

/// Helper class để refresh router khi auth state thay đổi
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) {
      notifyListeners();
    });
  }
}
