import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class UserService {
  static const _baseUrl = 'http://10.0.2.2:8000/api/auth';
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await SessionManager.getAccessToken();
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/get-current-user'),
        headers: {'Authorization': 'Bearer $token'},
      );
      //print(res.body.toString());
      return jsonDecode(res.body);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateAccountDetails({
    required String name,
  }) async {
    final token = await SessionManager.getAccessToken();
    try {
      final res = await http.patch(
        Uri.parse('$_baseUrl/update-account'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'name': name}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}
