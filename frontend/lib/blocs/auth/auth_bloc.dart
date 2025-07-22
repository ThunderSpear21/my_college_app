import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/services/user_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedOut>(_logOut);
    on<LoggedIn>(_onLoggedIn);
    on<UserUpdated>(_onUserUpdated);
  }

  Future<void> _fetchAndEmitAuthenticated(Emitter<AuthState> emit) async {
    try {
      final userData = await UserService.getCurrentUser();
      if (userData != null && userData['data']?['user'] != null) {
        emit(Authenticated(userData['data']['user']));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final valid = await AuthService.isAccessTokenValid();
    if (valid) {
      await _fetchAndEmitAuthenticated(emit);
    } else {
      final refreshed = await AuthService.refreshToken();
      if (refreshed) {
        await _fetchAndEmitAuthenticated(emit);
      } else {
        emit(Unauthenticated());
      }
    }
  }

  Future<void> _logOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await AuthService.logout();
    if (!res) emit(Unauthenticated());
    emit(Unauthenticated());
  }

  // New handler for when a user logs in.
  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _fetchAndEmitAuthenticated(emit);
  }

  // New handler to update the state with fresh user data from the profile screen.
  void _onUserUpdated(UserUpdated event, Emitter<AuthState> emit) {
    emit(Authenticated(event.updatedUser));
  }
}
