import 'package:equatable/equatable.dart';
import 'package:frontend/models/course_model.dart';

enum CourseStatus { initial, loading, success, failure }

class CourseState extends Equatable {
  const CourseState({
    this.status = CourseStatus.initial,
    this.courses = const [],
    this.selectedSemester,
    this.selectedCourse,
    this.errorMessage,
  });

  final CourseStatus status;
  final List<Course> courses;
  final int? selectedSemester;
  final Course? selectedCourse;
  final String? errorMessage;

  CourseState copyWith({
    CourseStatus? status,
    List<Course>? courses,
    int? selectedSemester,
    Course? selectedCourse,
    String? errorMessage,
    bool clearSelectedCourse = false,
  }) {
    return CourseState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      selectedSemester: selectedSemester ?? this.selectedSemester,
      selectedCourse:
          clearSelectedCourse ? null : selectedCourse ?? this.selectedCourse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    courses,
    selectedSemester,
    selectedCourse,
    errorMessage,
  ];
}
