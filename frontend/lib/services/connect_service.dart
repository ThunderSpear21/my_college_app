import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/connect_model.dart';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class ConnectService {
  static String baseUrl = dotenv.env['BASE_URL']!;
  static final String _baseUrl = '$baseUrl/connect';

  static Future<List<PublicProfile>> getAvailableMentors() async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    final response = await http.get(
      Uri.parse('$_baseUrl/available-mentors'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final List<dynamic> mentorsJson = responseBody['data'];
      return mentorsJson.map((json) => PublicProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load available mentors');
    }
  }

  static Future<PublicProfile?> getMyMentor() async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$_baseUrl/my-mentor'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['data'] != null) {
        return PublicProfile.fromJson(responseBody['data']);
      }
      return null;
    } else {
      throw Exception('Failed to load mentor');
    }
  }

  static Future<List<PublicProfile>> getMyMentees() async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$_baseUrl/my-mentees'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final List<dynamic> menteesJson = responseBody['data'];
      return menteesJson.map((json) => PublicProfile.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      return [];
    } else {
      throw Exception('Failed to load mentees');
    }
  }

  static Future<void> sendMentorRequest(String mentorId) async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.post(
      Uri.parse('$_baseUrl/connect-mentor/$mentorId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final responseBody = json.decode(response.body);
      final message = responseBody['message'] ?? 'Failed to send request';
      throw Exception(message);
    }
  }
}
