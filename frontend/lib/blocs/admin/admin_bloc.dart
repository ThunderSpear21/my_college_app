import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/admin/admin_event.dart';
import 'package:frontend/blocs/admin/admin_state.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/auth/auth_state.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:frontend/services/course_service.dart';
import 'package:frontend/services/notes_service.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AuthBloc authBloc;

  AdminBloc({required this.authBloc}) : super(const AdminState()) {
    // User Management
    on<AdminPeersFetched>(_onAdminPeersFetched);
    on<AdminJuniorsFetched>(_onAdminJuniorsFetched);
    on<AdminMentorStatusToggled>(_onAdminMentorStatusToggled);
    on<AdminStatusToggled>(_onAdminStatusToggled);

    // Content Management
    on<AdminCoursesFetched>(_onAdminCoursesFetched);
    on<AdminNotesFetched>(_onAdminNotesFetched);
    on<AdminCourseUploaded>(_onAdminCourseUploaded);
    on<AdminNoteUploaded>(_onAdminNoteUploaded);
    on<AdminCourseDeleted>(_onAdminCourseDeleted);
    on<AdminNoteDeleted>(_onAdminNoteDeleted);
  }

  int? _getCurrentUserYear() {
    final authState = authBloc.state;
    if (authState is Authenticated) {
      return authState.user['yearOfAdmission'];
    }
    return null;
  }

  // --- User Handlers ---

  Future<void> _onAdminPeersFetched(
    AdminPeersFetched event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final currentYear = _getCurrentUserYear();
      if (currentYear == null)
        throw Exception('Could not identify current user.');

      final peers = await AdminService.getStudentsByYear(currentYear);
      emit(state.copyWith(status: AdminStatus.success, peers: peers));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdminJuniorsFetched(
    AdminJuniorsFetched event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final currentYear = _getCurrentUserYear();
      if (currentYear == null)
        throw Exception('Could not identify current user.');

      final juniors = await AdminService.getStudentsByYear(currentYear + 1);
      emit(state.copyWith(status: AdminStatus.success, juniors: juniors));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdminMentorStatusToggled(
    AdminMentorStatusToggled event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.updating));
    try {
      await AdminService.toggleMentorStatus(event.userId);
      add(AdminPeersFetched());
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdminStatusToggled(
    AdminStatusToggled event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.updating));
    try {
      await AdminService.toggleAdminStatus(event.userId);
      add(AdminJuniorsFetched());
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  // --- Content Handlers ---

  Future<void> _onAdminCoursesFetched(
    AdminCoursesFetched event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final courses = await CourseService.getCoursesBySemester(event.semester);
      emit(state.copyWith(status: AdminStatus.success, courses: courses));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdminNotesFetched(
    AdminNotesFetched event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final notes = await NoteService.getNotesBySemester(event.semester);
      emit(state.copyWith(status: AdminStatus.success, notes: notes));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdminCourseUploaded(
    AdminCourseUploaded event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.uploading));
    try {
      await AdminService.uploadCourseStructure(
        event.file,
        event.courseId,
        event.courseName,
        event.semester,
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdminNoteUploaded(
    AdminNoteUploaded event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.uploading));
    try {
      await AdminService.uploadNote(event.file, event.title, event.courseId);
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdminCourseDeleted(
    AdminCourseDeleted event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.deleting));
    try {
      await AdminService.deleteCourseStructure(event.courseId);
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdminNoteDeleted(
    AdminNoteDeleted event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.deleting));
    try {
      await AdminService.deleteNote(event.noteId);
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
