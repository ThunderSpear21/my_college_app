import 'package:equatable/equatable.dart';

abstract class ConnectEvent extends Equatable {
  const ConnectEvent();

  @override
  List<Object> get props => [];
}

class ConnectDataLoaded extends ConnectEvent {}

class MentorRequestSent extends ConnectEvent {
  final String mentorId;

  const MentorRequestSent(this.mentorId);

  @override
  List<Object> get props => [mentorId];
}
