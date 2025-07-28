import 'package:equatable/equatable.dart';
import 'package:frontend/models/connect_model.dart';
import 'package:frontend/models/course_model.dart';
import 'package:frontend/models/notes_model.dart';

enum AdminStatus {
  initial,
  loading,
  success,
  failure,
  updating,
  uploading,
  deleting,
}

class AdminState extends Equatable {
  const AdminState({
    this.status = AdminStatus.initial,
    this.peers = const [],
    this.juniors = const [],
    this.courses = const [],
    this.notes = const [],
    this.errorMessage,
  });

  final AdminStatus status;
  final List<PublicProfile> peers;
  final List<PublicProfile> juniors;
  final List<Course> courses; // To hold course structures for deletion
  final List<Note> notes; // To hold notes for deletion
  final String? errorMessage;

  AdminState copyWith({
    AdminStatus? status,
    List<PublicProfile>? peers,
    List<PublicProfile>? juniors,
    List<Course>? courses,
    List<Note>? notes,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      peers: peers ?? this.peers,
      juniors: juniors ?? this.juniors,
      courses: courses ?? this.courses,
      notes: notes ?? this.notes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    peers,
    juniors,
    courses,
    notes,
    errorMessage,
  ];
}
