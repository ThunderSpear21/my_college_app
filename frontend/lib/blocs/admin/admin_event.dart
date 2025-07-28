import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

// --- User Management Events ---

/// Event to fetch the list of peers (same admission year).
class AdminPeersFetched extends AdminEvent {}

/// Event to fetch the list of juniors (previous admission year).
class AdminJuniorsFetched extends AdminEvent {}

/// Event to toggle a peer's mentor eligibility.
class AdminMentorStatusToggled extends AdminEvent {
  final String userId;
  const AdminMentorStatusToggled(this.userId);

  @override
  List<Object> get props => [userId];
}

/// Event to toggle a junior's admin status.
class AdminStatusToggled extends AdminEvent {
  final String userId;
  const AdminStatusToggled(this.userId);

  @override
  List<Object> get props => [userId];
}

// --- Content Management Events ---

/// Event to fetch all course structures to display in the delete list.
class AdminCoursesFetched extends AdminEvent {
  final int semester;
  const AdminCoursesFetched(this.semester);
  @override
  List<Object> get props => [semester];
}

/// Event to fetch all notes to display in the delete list.
class AdminNotesFetched extends AdminEvent {
  final int semester;
  const AdminNotesFetched(this.semester);
  @override
  List<Object> get props => [semester];
}

/// Event dispatched when an admin uploads a new course structure.
class AdminCourseUploaded extends AdminEvent {
  final File file;
  final String courseId;
  final String courseName;
  final int semester;

  const AdminCourseUploaded({
    required this.file,
    required this.courseId,
    required this.courseName,
    required this.semester,
  });

  @override
  List<Object?> get props => [file, courseId, courseName, semester];
}

/// Event dispatched when an admin uploads a new note.
class AdminNoteUploaded extends AdminEvent {
  final File file;
  final String title;
  final String courseId; // The ID of the course the note belongs to

  const AdminNoteUploaded({
    required this.file,
    required this.title,
    required this.courseId,
  });

  @override
  List<Object?> get props => [file, title, courseId];
}

/// Event to delete a course structure.
class AdminCourseDeleted extends AdminEvent {
  final String courseId;
  const AdminCourseDeleted(this.courseId);

  @override
  List<Object> get props => [courseId];
}

/// Event to delete a note.
class AdminNoteDeleted extends AdminEvent {
  final String noteId;
  const AdminNoteDeleted(this.noteId);

  @override
  List<Object> get props => [noteId];
}
