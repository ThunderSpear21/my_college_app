import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/course/course_event.dart';
import 'package:frontend/blocs/course/course_state.dart';
import 'package:frontend/services/course_service.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  CourseBloc() : super(const CourseState()) {
    on<SemesterSelected>(_onSemesterSelected);
    on<CourseSelected>(_onCourseSelected);
  }

  Future<void> _onSemesterSelected(
    SemesterSelected event,
    Emitter<CourseState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CourseStatus.loading,
        selectedSemester: event.semester,
        courses: [],
        clearSelectedCourse: true,
      ),
    );

    try {
      final courses = await CourseService.getCoursesBySemester(event.semester);
      emit(state.copyWith(status: CourseStatus.success, courses: courses));
    } catch (e) {
      emit(
        state.copyWith(
          status: CourseStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onCourseSelected(CourseSelected event, Emitter<CourseState> emit) {
    emit(state.copyWith(selectedCourse: event.course));
  }
}
