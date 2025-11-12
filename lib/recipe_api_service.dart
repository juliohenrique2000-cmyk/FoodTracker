import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecipeApiService {
  static const String baseUrl = 'https://api-receitas-pi.vercel.app';

  // Store and retrieve JWT token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    } catch (e) {
      // Handle SharedPreferences initialization error
      // Use logging instead of print
      return null;
    }
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Login to external API
  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        await saveToken(token);
        return token;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  // Fetch all recipes with pagination
  static Future<List<Map<String, dynamic>>> fetchRecipes({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receitas/todas?page=$page&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['items']);
      } else {
        throw Exception('Failed to fetch recipes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  // Search recipes by description
  static Future<List<Map<String, dynamic>>> searchRecipes(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    final token = await getToken();
    final headers = token != null
        ? {'Authorization': 'Bearer $token'}
        : <String, String>{};

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/receitas/descricao?descricao=$query&page=$page&limit=$limit',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to search recipes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error searching recipes: $e');
    }
  }

  // Fetch recipes by type
  static Future<List<Map<String, dynamic>>> fetchRecipesByType(
    String type,
  ) async {
    final token = await getToken();
    final headers = token != null
        ? {'Authorization': 'Bearer $token'}
        : <String, String>{};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receitas/tipo/$type'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch recipes by type: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching recipes by type: $e');
    }
  }

  // Water intake methods
  static Future<int> getWaterIntake(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/water-intake'),
        headers: {
          'Content-Type': 'application/json',
          'user-id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['cups'] ?? 0;
      } else {
        throw Exception('Failed to get water intake: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting water intake: $e');
    }
  }

  static Future<int> addWaterCup(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/water-intake'),
        headers: {
          'Content-Type': 'application/json',
          'user-id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['cups'] ?? 0;
      } else {
        throw Exception('Failed to add water cup: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding water cup: $e');
    }
  }
}
