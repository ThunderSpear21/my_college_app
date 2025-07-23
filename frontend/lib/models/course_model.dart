import 'dart:convert';

List<Course> courseFromJson(String str) =>
    List<Course>.from(json.decode(str).map((x) => Course.fromJson(x)));

class Uploader {
  final String id;
  final String name;

  Uploader({
    required this.id,
    required this.name,
  });

  factory Uploader.fromJson(Map<String, dynamic> json) => Uploader(
        id: json["_id"],
        name: json["name"],
      );
}

class Course {
  final String id;
  final String courseId;
  final String courseName;
  final int semester;
  final String url;
  final Uploader uploadedBy; // Changed from String to Uploader
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.semester,
    required this.url,
    required this.uploadedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json["_id"],
      courseId: json["courseId"],
      courseName: json["courseName"],
      semester: json["semester"],
      url: json["url"],
      // Parse the nested 'uploadedBy' object using the Uploader.fromJson factory.
      uploadedBy: Uploader.fromJson(json["uploadedBy"]),
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}
