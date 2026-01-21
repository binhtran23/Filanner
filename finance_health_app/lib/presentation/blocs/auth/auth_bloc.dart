import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

/// BLoC xử lý logic Authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  /// Kiểm tra trạng thái đăng nhập khi app khởi động
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final isLoggedInResult = await authRepository.isLoggedIn().timeout(
        const Duration(seconds: 5),
      );

      // Use pattern matching instead of fold for async operations
      if (isLoggedInResult.isLeft()) {
        emit(const AuthUnauthenticated());
        return;
      }

      final isLoggedIn = isLoggedInResult.getOrElse(() => false);

      if (!isLoggedIn) {
        emit(const AuthUnauthenticated());
        return;
      }

      // User is logged in, get user data
      final userResult = await authRepository.getCurrentUser().timeout(
        const Duration(seconds: 5),
      );

      if (userResult.isLeft()) {
        emit(const AuthUnauthenticated());
        return;
      }

      final user = userResult.getOrElse(() => null);
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      // If any error or timeout occurs, default to unauthenticated
      emit(const AuthUnauthenticated());
    }
  }

  /// Xử lý đăng nhập
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.login(
      username: event.username,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Xử lý đăng ký
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.register(
      username: event.username,
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthRegistered(user: user)),
    );
  }

  /// Xử lý đăng xuất
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.logout();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
