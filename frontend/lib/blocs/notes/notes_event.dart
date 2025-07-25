import 'package:equatable/equatable.dart';
import 'package:frontend/models/course_model.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class NotesSemesterSelected extends NoteEvent {
  final int semester;

  const NotesSemesterSelected(this.semester);

  @override
  List<Object?> get props => [semester];
}

class NotesCourseFiltered extends NoteEvent {
  final Course? course;

  const NotesCourseFiltered(this.course);

  @override
  List<Object?> get props => [course];
}
