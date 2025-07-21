import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedOut>(_logOut);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final valid = await AuthService.isAccessTokenValid();
    if (valid) {
      emit(Authenticated());
    } else {
      final refreshed = await AuthService.refreshToken();
      if (refreshed) {
        emit(Authenticated());
      } else {
        emit(Unauthenticated());
      }
    }
  }

  Future<void> _logOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await AuthService.logout();
    emit(Unauthenticated());
  }
}
