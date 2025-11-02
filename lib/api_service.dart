import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_service.dart'; // For Activity class

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<Activity>> fetchActivities() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/activities'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Activity.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching activities: $e');
    }
  }
}
