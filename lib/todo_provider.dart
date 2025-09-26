import 'package:flutter/foundation.dart';
import 'todo_api_service.dart';

class TodoModel {
  final String id;
  final String text;
  final bool isCompleted;

  TodoModel({
    required this.id,
    required this.text,
    required this.isCompleted,
  });

  TodoModel copyWith({
    String? id,
    String? text,
    bool? isCompleted,
  }) {
    return TodoModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convert from API format to used model
  factory TodoModel.fromApi(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      text: json['title'],
      isCompleted: json['done'],
    );
  }

  // Convert to API format
  Map<String, dynamic> toApi() {
    return {
      'id': id,
      'title': text,
      'done': isCompleted,
    };
  }
}

enum TodoFilter { all, done, undone }

class TodoProvider with ChangeNotifier {
  List<TodoModel> _todos = [];
  TodoFilter _currentFilter = TodoFilter.all;
  bool _isLoading = false;
  String? _error;
  final TodoApiService _apiService = TodoApiService();

  List<TodoModel> get todos => List.unmodifiable(_todos);
  TodoFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasApiKey => _apiService.hasApiKey;

  List<TodoModel> get filteredTodos {
    switch (_currentFilter) {
      case TodoFilter.done:
        return _todos.where((todo) => todo.isCompleted).toList();
      case TodoFilter.undone:
        return _todos.where((todo) => !todo.isCompleted).toList();
      case TodoFilter.all:
        return _todos;
    }
  }

  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((todo) => todo.isCompleted).length;
  int get pendingTodos => _todos.where((todo) => !todo.isCompleted).length;

  // API Methods
  Future<void> initializeApi() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.initialize();
      await loadTodos();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTodos() async {
    _setLoading(true);
    _clearError();
    
    try {
      final todosJson = await _apiService.getTodos();
      _todos = todosJson.map((json) => TodoModel.fromApi(json)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load todos: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTodo(String text) async {
    if (text.trim().isEmpty) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final todosJson = await _apiService.addTodo(text.trim());
      _todos = todosJson.map((json) => TodoModel.fromApi(json)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTodoCompletion(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.updateTodo(id, todo.text, !todo.isCompleted);
      
      // Update local state
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(
          isCompleted: !_todos[index].isCompleted,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTodo(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.deleteTodo(id);
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
