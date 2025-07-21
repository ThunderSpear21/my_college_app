import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/view_profile/view_profile_event.dart';
import 'package:frontend/blocs/view_profile/view_profile_state.dart';
import 'package:frontend/services/user_service.dart';

class ViewProfileBloc extends Bloc<ViewProfileEvent, ViewProfileState> {
  ViewProfileBloc() : super(const ViewProfileState()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateSubmitted>(_onProfileUpdateSubmitted);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ViewProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final userData = await UserService.getCurrentUser();
      final user = userData?['data']?['user'];
      if (user != null) {
        emit(state.copyWith(status: ProfileStatus.success, user: user));
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
  Future<void> _onProfileUpdateSubmitted(
    ProfileUpdateSubmitted event,
    Emitter<ViewProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));
    try {
      final updatedUserData = await UserService.updateAccountDetails(
        name: event.newName,
      );
      final updatedUser = updatedUserData?['data'];
      if (updatedUser != null) {
        emit(state.copyWith(status: ProfileStatus.success, user: updatedUser));
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      emit(state.copyWith(status: ProfileStatus.success));
    }
  }
}
