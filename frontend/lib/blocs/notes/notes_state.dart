import 'package:equatable/equatable.dart';
import 'package:frontend/models/course_model.dart';
import 'package:frontend/models/notes_model.dart';

enum NotesStatus { initial, loading, success, failure }
class NoteState extends Equatable {
  const NoteState({
    this.status = NotesStatus.initial,
    this.selectedSemester,
    this.selectedCourse,
    this.allNotesForSemester = const [],
    this.filteredNotes = const [],
    this.errorMessage,
  });

  final NotesStatus status;
  final int? selectedSemester;
  final Course? selectedCourse;
  final List<Note> allNotesForSemester;
  final List<Note> filteredNotes;
  final String? errorMessage;

  NoteState copyWith({
    NotesStatus? status,
    int? selectedSemester,
    Course? selectedCourse,
    List<Note>? allNotesForSemester,
    List<Note>? filteredNotes,
    String? errorMessage,
    bool clearSelectedCourse = false,
  }) {
    return NoteState(
      status: status ?? this.status,
      selectedSemester: selectedSemester ?? this.selectedSemester,
      selectedCourse: clearSelectedCourse ? null : selectedCourse ?? this.selectedCourse,
      allNotesForSemester: allNotesForSemester ?? this.allNotesForSemester,
      filteredNotes: filteredNotes ?? this.filteredNotes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedSemester,
        selectedCourse,
        allNotesForSemester,
        filteredNotes,
        errorMessage
      ];
}
