import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _baseUrl =
      'http://10.0.2.2:8000/api/auth'; // Android emulator localhost

  // --- Token Storage ---
  static Future<void> saveTokens(
  String accessToken,
  String refreshToken,
) async {
  await SessionManager.saveTokens(accessToken, refreshToken);
}


  static Future<void> clearTokens() async {
  await SessionManager.clearTokens();
}


  // --- Token Validation ---
  static Future<bool> isAccessTokenValid() async {
    final token = await SessionManager.getAccessToken();
    if (token == null) return false;
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/get-current-user'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> refreshToken() async {
    final refreshToken = await SessionManager.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await saveTokens(
          data['accessToken'],
          data['refreshToken'],
        ); // ✅ Correct keys
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      final data = responseData['data'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', data['accessToken']);
      await prefs.setString('refreshToken', data['refreshToken']);

      // Optional: Store user info
      await prefs.setString('userId', data['user']['_id']);
      await prefs.setString('userEmail', data['user']['email']);
      await prefs.setString('userName', data['user']['name']);
      // Step 3: Return a User model (or any object you use)
      return User.fromJson(data['user']);
    } else {
      throw Exception(responseData['message'] ?? 'Login failed');
    }
  }

  static Future<void> sendOTP(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    // Check if response is JSON
    final isJson =
        response.headers['content-type']?.contains('application/json') ?? false;

    if (isJson) {
      final responseData = jsonDecode(response.body);
      print(responseData.toString());

      if (response.statusCode == 200 && responseData['success'] == true) {
        return;
      } else {
        throw Exception(responseData['message'] ?? 'Something went wrong');
      }
    } else {
      print("Non-JSON response: ${response.body}");
      throw Exception("Unexpected server response. Please try again.");
    }
  }

  static Future<void> registerUser(
  String email,
  String name,
  String password,
  String otp,
) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'name': name,
      'password': password,
      'otp': otp,
    }),
  );

  final contentType = response.headers['content-type'];
  final isJson = contentType?.contains('application/json') ?? false;

  if (isJson) {
    final responseData = jsonDecode(response.body);
    print(responseData);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData['success'] == true) {
      return;
    } else {
      throw Exception(responseData['message'] ?? 'Registration failed');
    }
  } else {
    print("Non-JSON response: ${response.body}");
    throw Exception("Unexpected server response.");
  }
}
}
