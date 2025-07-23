import 'package:equatable/equatable.dart';
import 'package:frontend/models/course_model.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class SemesterSelected extends CourseEvent {
  final int semester;

  const SemesterSelected(this.semester);

  @override
  List<Object?> get props => [semester];
}

class CourseSelected extends CourseEvent {
  final Course? course;

  const CourseSelected(this.course);

  @override
  List<Object?> get props => [course];
}
