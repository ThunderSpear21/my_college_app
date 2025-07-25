import 'dart:convert';

List<Note> noteFromJson(String str) =>
    List<Note>.from(json.decode(str).map((x) => Note.fromJson(x)));

class NoteCourseInfo {
  final String courseId;
  final String courseName;
  final int semester;

  NoteCourseInfo({
    required this.courseId,
    required this.courseName,
    required this.semester,
  });

  factory NoteCourseInfo.fromJson(Map<String, dynamic> json) => NoteCourseInfo(
        courseId: json["courseId"],
        courseName: json["courseName"],
        semester: json["semester"],
      );
}

class NoteUploaderInfo {
  final String name;
  final String email;

  NoteUploaderInfo({
    required this.name,
    required this.email,
  });

  factory NoteUploaderInfo.fromJson(Map<String, dynamic> json) => NoteUploaderInfo(
        name: json["name"],
        email: json["email"],
      );
}

// The main Note model.
class Note {
  final String id;
  final String title;
  final String url;
  final NoteCourseInfo course;
  final NoteUploaderInfo uploadedBy;

  Note({
    required this.id,
    required this.title,
    required this.url,
    required this.course,
    required this.uploadedBy,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json["_id"],
        title: json["title"],
        url: json["url"],
        course: NoteCourseInfo.fromJson(json["course"]),
        uploadedBy: NoteUploaderInfo.fromJson(json["uploadedBy"]),
      );
}
