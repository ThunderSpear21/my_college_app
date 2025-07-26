import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/connect/connect_event.dart';
import 'package:frontend/blocs/connect/connect_state.dart';
import 'package:frontend/models/connect_model.dart';
import 'package:frontend/services/connect_service.dart';

class ConnectBloc extends Bloc<ConnectEvent, ConnectState> {
  ConnectBloc() : super(const ConnectState()) {
    on<ConnectDataLoaded>(_onConnectDataLoaded);
    on<MentorRequestSent>(_onMentorRequestSent);
  }

  // This single event fetches all data needed for the screen at once.
  Future<void> _onConnectDataLoaded(
    ConnectDataLoaded event,
    Emitter<ConnectState> emit,
  ) async {
    emit(state.copyWith(status: ConnectStatus.loading));
    try {
      // Fetch data for both tabs in parallel for better performance.
      final results = await Future.wait([
        ConnectService.getMyMentor(),
        ConnectService.getAvailableMentors(),
        ConnectService.getMyMentees(),
      ]);
      final PublicProfile? myMentor = results[0] as PublicProfile?;
      final List<PublicProfile> availableMentors = results[1] as List<PublicProfile>;
      final List<PublicProfile> myMentees = results[2] as List<PublicProfile>;
      emit(state.copyWith(
        status: ConnectStatus.success,
        myMentor: myMentor,
        availableMentors: availableMentors,
        myMentees: myMentees,
        hasMentor: myMentor != null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ConnectStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMentorRequestSent(
    MentorRequestSent event,
    Emitter<ConnectState> emit,
  ) async {
    emit(state.copyWith(status: ConnectStatus.sendingRequest));
    try {
      await ConnectService.sendMentorRequest(event.mentorId);
      emit(state.copyWith(status: ConnectStatus.requestSuccess));
      // After a successful request, refresh all the data to reflect the change.
      add(ConnectDataLoaded());
    } catch (e) {
      emit(state.copyWith(
        status: ConnectStatus.requestFailure,
        errorMessage: e.toString(),
      ));
      // Revert to the success state so the user can see the lists again.
      emit(state.copyWith(status: ConnectStatus.success));
    }
  }
}
