import 'dart:convert';
import 'package:frontend/models/notes_model.dart';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class NoteService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/notes';
  static Future<List<Note>> getNotesBySemester(int semester) async {
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
        final List<dynamic> notesJson = responseBody['data'];
        return notesJson.map((json) => Note.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notes for semester $semester');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching notes.');
    }
  }

  // Fetches all notes for a given course ID
  static Future<List<Note>> getNotesByCourseId(String courseId) async {
    final String? token = await SessionManager.getAccessToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    final Uri url = Uri.parse('$_baseUrl/id/$courseId');

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
        final List<dynamic> notesJson = responseBody['data'];
        return notesJson.map((json) => Note.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notes for course $courseId');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching notes.');
    }
  }
}
