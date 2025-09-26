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
    final prefs = await SharedPreferences.getInstance();
    final savedApiKey = prefs.getString(_apiKeyKey);
    
    if (savedApiKey != null && savedApiKey.isNotEmpty) {
      _apiKey = savedApiKey;
    } else {
      await registerApiKey();
    }
  }

  // Register new API key
  Future<String> registerApiKey() async {
    final response = await http.get(Uri.parse('$baseUrl/register'));
    
    _apiKey = response.body.trim();
    
    // Save API key locally using SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, _apiKey!);
    return _apiKey!;
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  void setApiKey(String key) {
    _apiKey = key;
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/todos?key=$_apiKey'),
    );

    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> addTodo(String title) async {
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

    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<void> updateTodo(String id, String title, bool done) async {
    await http.put(
      Uri.parse('$baseUrl/todos/$id?key=$_apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'done': done,
      }),
    );
  }

  Future<void> deleteTodo(String id) async {
    await http.delete(
      Uri.parse('$baseUrl/todos/$id?key=$_apiKey'),
    );
  }
}
