import 'package:equatable/equatable.dart';
import 'package:frontend/models/connect_model.dart';

enum ConnectStatus {
  initial,
  loading,
  success,
  failure,
  sendingRequest,
  requestSuccess,
  requestFailure,
}

class ConnectState extends Equatable {
  const ConnectState({
    this.status = ConnectStatus.initial,
    this.myMentor,
    this.availableMentors = const [],
    this.myMentees = const [],
    this.errorMessage,
    this.hasMentor,
  });

  final ConnectStatus status;
  final PublicProfile? myMentor;
  final List<PublicProfile> availableMentors;
  final List<PublicProfile> myMentees;
  final String? errorMessage;
  // A flag to easily check if the user has a mentor, to decide which UI to show.
  final bool? hasMentor;

  ConnectState copyWith({
    ConnectStatus? status,
    PublicProfile? myMentor,
    List<PublicProfile>? availableMentors,
    List<PublicProfile>? myMentees,
    String? errorMessage,
    bool? hasMentor,
  }) {
    return ConnectState(
      status: status ?? this.status,
      myMentor: myMentor ?? this.myMentor,
      availableMentors: availableMentors ?? this.availableMentors,
      myMentees: myMentees ?? this.myMentees,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMentor: hasMentor ?? this.hasMentor,
    );
  }

  @override
  List<Object?> get props => [
    status,
    myMentor,
    availableMentors,
    myMentees,
    errorMessage,
    hasMentor,
  ];
}
