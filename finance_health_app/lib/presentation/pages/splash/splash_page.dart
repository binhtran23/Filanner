import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../../app/routes/app_router.dart';
import '../../../app/theme/colors.dart';

/// Splash Screen - Kiểm tra trạng thái auth khi app khởi động
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Check auth state after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });

    // Safety timeout - navigate to login after 3 seconds if still stuck
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_hasNavigated) {
        debugPrint('Splash timeout - navigating to login');
        context.go(AppRoutes.login);
      }
    });
  }

  void _checkAuthState() {
    final state = context.read<AuthBloc>().state;
    debugPrint('Splash checking auth state: $state');
    _navigateBasedOnState(state);
  }

  void _navigateBasedOnState(AuthState state) {
    if (!mounted || _hasNavigated) return;

    debugPrint('Splash navigating based on state: $state');

    if (state is AuthAuthenticated) {
      _hasNavigated = true;
      context.go(AppRoutes.home);
    } else if (state is AuthUnauthenticated) {
      _hasNavigated = true;
      context.go(AppRoutes.login);
    }
    // If AuthLoading or AuthInitial, wait for state change via listener
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _navigateBasedOnState(state);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Finance Health',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quản lý tài chính thông minh',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
