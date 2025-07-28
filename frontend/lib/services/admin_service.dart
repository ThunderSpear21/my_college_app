import 'dart:convert';
import 'dart:io';
import 'package:frontend/models/connect_model.dart';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class AdminService {
  // Base URLs for different API sections
  static const String _userBaseUrl = 'http://10.0.2.2:8000/api/user';
  static const String _courseBaseUrl = 'http://10.0.2.2:8000/api/course';
  static const String _notesBaseUrl = 'http://10.0.2.2:8000/api/notes';

  // --- User Management ---

  /// Fetches a list of students by their year of admission.
  static Future<List<PublicProfile>> getStudentsByYear(int year) async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$_userBaseUrl/students/year/$year'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final List<dynamic> usersJson = responseBody['data'];
      return usersJson.map((json) => PublicProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load students for year $year');
    }
  }

  /// Toggles the mentor eligibility status for a given user.
  static Future<void> toggleMentorStatus(String userId) async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.put(
      Uri.parse('$_userBaseUrl/mark-mentor-eligible'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'toToggleUserId': userId}),
    );

    if (response.statusCode != 200) {
      final responseBody = json.decode(response.body);
      throw Exception(
        responseBody['message'] ?? 'Failed to toggle mentor status',
      );
    }
  }

  /// Toggles the admin status for a given user.
  static Future<void> toggleAdminStatus(String userId) async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    final response = await http.put(
      Uri.parse('$_userBaseUrl/promote-admin'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'toToggleUserId': userId}),
    );

    if (response.statusCode != 200) {
      final responseBody = json.decode(response.body);
      throw Exception(
        responseBody['message'] ?? 'Failed to toggle admin status',
      );
    }
  }

  // --- Content Management ---

  static Future<void> uploadCourseStructure(
    File file,
    String courseId,
    String courseName,
    int semester,
  ) async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_courseBaseUrl/upload'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['courseId'] = courseId;
    request.fields['courseName'] = courseName;
    request.fields['semester'] = semester.toString();
    request.files.add(
      await http.MultipartFile.fromPath('coursePdf', file.path),
    );

    final response = await request.send();

    if (response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      final decodedBody = json.decode(responseBody);
      throw Exception(
        decodedBody['message'] ?? 'Failed to upload course structure',
      );
    }
  }

  /// Deletes a course structure by its ID.
  static Future<void> deleteCourseStructure(String courseId) async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.delete(
      Uri.parse('$_courseBaseUrl/id/$courseId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final responseBody = json.decode(response.body);
      throw Exception(
        responseBody['message'] ?? 'Failed to delete course structure',
      );
    }
  }

  /// Uploads a notes file.
  static Future<void> uploadNote(
    File file,
    String title,
    String courseId,
  ) async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_notesBaseUrl/upload'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['courseId'] = courseId;
    request.files.add(await http.MultipartFile.fromPath('notesPdf', file.path));

    final response = await request.send();

    if (response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      final decodedBody = json.decode(responseBody);
      throw Exception(decodedBody['message'] ?? 'Failed to upload note');
    }
  }

  /// Deletes a note by its ID.
  static Future<void> deleteNote(String noteId) async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.delete(
      Uri.parse('$_notesBaseUrl/id/$noteId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final responseBody = json.decode(response.body);
      throw Exception(responseBody['message'] ?? 'Failed to delete note');
    }
  }
}
