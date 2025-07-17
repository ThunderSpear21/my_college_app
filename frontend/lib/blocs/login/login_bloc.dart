import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/login/login_event.dart';
import 'package:frontend/blocs/login/login_state.dart';
import 'package:frontend/services/auth_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        await AuthService.login(event.email, event.password);
        emit(LoginSuccess());
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}
