import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/notes/notes_event.dart';
import 'package:frontend/blocs/notes/notes_state.dart';
import 'package:frontend/services/notes_service.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(const NoteState()) {
    on<NotesSemesterSelected>(_onNotesSemesterSelected);
    on<NotesCourseFiltered>(_onNotesCourseFiltered);
  }

  Future<void> _onNotesSemesterSelected(
    NotesSemesterSelected event,
    Emitter<NoteState> emit,
  ) async {
    emit(
      state.copyWith(
        status: NotesStatus.loading,
        selectedSemester: event.semester,
        allNotesForSemester: [],
        filteredNotes: [],
        clearSelectedCourse: true,
      ),
    );

    try {
      final notes = await NoteService.getNotesBySemester(event.semester);
      emit(
        state.copyWith(
          status: NotesStatus.success,
          allNotesForSemester: notes,
          filteredNotes: notes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  void _onNotesCourseFiltered(
    NotesCourseFiltered event,
    Emitter<NoteState> emit,
  ) {
    final selectedCourse = event.course;
    if (selectedCourse == null) {
      emit(
        state.copyWith(
          selectedCourse: null,
          filteredNotes: state.allNotesForSemester,
        ),
      );
    } else {
      final filteredList =
          state.allNotesForSemester.where((note) {
            return note.course.courseId == selectedCourse.courseId;
          }).toList();

      emit(
        state.copyWith(
          selectedCourse: selectedCourse,
          filteredNotes: filteredList,
        ),
      );
    }
  }
}
