import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoApiService {
  static const String baseUrl = 'https://todoapp-api.apps.k8s.gu.se';
  // SharedPreferences key label
  static const String _apiKeyKey = 'todo_api_key';
  String? _apiKey;

  // Get API key
  String? get apiKey => _apiKey;

  // load API key or register a new one
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedApiKey = prefs.getString(_apiKeyKey);
      
      if (savedApiKey != null && savedApiKey.isNotEmpty) {
        _apiKey = savedApiKey;
      } else {
        await registerApiKey();
      }
    } catch (e) {
      throw Exception('Error initializing API service: $e');
    }
  }

  // Register new API key
  Future<String> registerApiKey() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/register'));
      
      if (response.statusCode == 200) {
        _apiKey = response.body.trim();
        
        // Save API key locally using SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_apiKeyKey, _apiKey!);
        return _apiKey!;
      } else {
        throw Exception('Failed to register API key: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error registering API key: $e');
    }
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  void setApiKey(String key) {
    _apiKey = key;
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    if (!hasApiKey) {
      throw Exception('No API key available. Please register first.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos?key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading todos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> addTodo(String title) async {
    if (!hasApiKey) {
      throw Exception('No API key available. Please register first.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todos?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'done': false,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to add todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(String id, String title, bool done) async {
    if (!hasApiKey) {
      throw Exception('No API key available. Please register first.');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/$id?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'done': done,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    if (!hasApiKey) {
      throw Exception('No API key available. Please register first.');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/todos/$id?key=$_apiKey'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting todo: $e');
    }
  }
}
