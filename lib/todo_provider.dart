import 'package:flutter/foundation.dart';

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
}

enum TodoFilter { all, done, undone }

class TodoProvider with ChangeNotifier {
  List<TodoModel> _todos = [
    TodoModel(id: '1', text: 'Write a book', isCompleted: false),
    TodoModel(id: '2', text: 'Do homework', isCompleted: false),
    TodoModel(id: '3', text: 'Tidy room', isCompleted: true),
    TodoModel(id: '4', text: 'Watch TV', isCompleted: false),
    TodoModel(id: '5', text: 'Nap', isCompleted: false),
    TodoModel(id: '6', text: 'Shop groceries', isCompleted: false),
    TodoModel(id: '7', text: 'Have fun', isCompleted: false),
    TodoModel(id: '8', text: 'Meditate', isCompleted: false),
  ];

  TodoFilter _currentFilter = TodoFilter.all;

  // Getters
  List<TodoModel> get todos => List.unmodifiable(_todos);
  TodoFilter get currentFilter => _currentFilter;

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

  // Methods
  void addTodo(String text) {
    if (text.trim().isEmpty) return;

    final newTodo = TodoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isCompleted: false,
    );

    _todos.add(newTodo);
    notifyListeners();
  }

  void toggleTodoCompletion(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }
}
