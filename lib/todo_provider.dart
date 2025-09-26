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
  final TodoApiService _apiService = TodoApiService();

  List<TodoModel> get todos => List.unmodifiable(_todos);
  TodoFilter get currentFilter => _currentFilter;
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
    await _apiService.initialize();
    await loadTodos();
  }

  Future<void> loadTodos() async {
    final todosJson = await _apiService.getTodos();
    _todos = todosJson.map((json) => TodoModel.fromApi(json)).toList();
    notifyListeners();
  }

  Future<void> addTodo(String text) async {
    if (text.trim().isEmpty) return;
    
    final todosJson = await _apiService.addTodo(text.trim());
    _todos = todosJson.map((json) => TodoModel.fromApi(json)).toList();
    notifyListeners();
  }

  Future<void> toggleTodoCompletion(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    
    await _apiService.updateTodo(id, todo.text, !todo.isCompleted);
    
    // Update local state
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    await _apiService.deleteTodo(id);
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }
}
