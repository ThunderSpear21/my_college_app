import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import 'session_manager.dart';

class CourseService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/course';
  static Future<List<Course>> getCoursesBySemester(int semester) async {
    final String? token = await SessionManager.getAccessToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    final Uri url = Uri.parse('$_baseUrl/semester/$semester');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> coursesJson = responseBody['data'];
        return coursesJson.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load courses for semester $semester');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching courses.');
    }
  }

  // static Future<void> getCourseById(String id) async {
  //   final String? token = await SessionManager.getAccessToken();
  //   if (token == null) {
  //     throw Exception('Authentication token not found. Please log in.');
  //   }
  //   final Uri url = Uri.parse('$_baseUrl/id/$id');

  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //     } else {}
  //   } catch (e) {}
  // }
}
