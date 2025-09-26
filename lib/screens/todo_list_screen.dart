import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../todo_provider.dart';
import 'add_task_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().initializeApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E5A8A),
        title: Text(
          'TIG333 TODO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              return PopupMenuButton<TodoFilter>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (TodoFilter filter) {
                  todoProvider.setFilter(filter);
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: TodoFilter.all,
                    child: Text('All'),
                  ),
                  PopupMenuItem(
                    value: TodoFilter.done,
                    child: Text('Done'),
                  ),
                  PopupMenuItem(
                    value: TodoFilter.undone,
                    child: Text('Undone'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Consumer<TodoProvider>(
          builder: (context, todoProvider, child) {
            final filteredTodos = todoProvider.filteredTodos;

            if (filteredTodos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      _getEmptyMessage(todoProvider.currentFilter),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the + button to add a new task',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                return _TodoItemWidget(
                  todo: todo,
                  onToggle: () => todoProvider.toggleTodoCompletion(todo.id),
                  onDelete: () => todoProvider.deleteTodo(todo.id),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Color(0xFF1E5A8A),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  String _getEmptyMessage(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.done:
        return 'No completed tasks';
      case TodoFilter.undone:
        return 'No pending tasks';
      case TodoFilter.all:
        return 'No tasks yet';
    }
  }
}

class _TodoItemWidget extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoItemWidget({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: todo.isCompleted 
                      ? Color(0xFF1E5A8A) 
                      : Colors.grey[400]!, 
                  width: 2
                ),
                shape: BoxShape.circle,
                color: todo.isCompleted 
                    ? Color(0xFF1E5A8A) 
                    : Colors.transparent,
              ),
              child: todo.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 16),
          
          // Task text
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 16,
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: todo.isCompleted
                    ? Colors.grey[600]
                    : Colors.black,
                fontWeight: todo.isCompleted 
                    ? FontWeight.normal 
                    : FontWeight.w500,
              ),
              child: Text(todo.text),
            ),
          ),
          
          // Delete button
          GestureDetector(
            onTap: () => _showDeleteConfirmation(context),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
              ),
              child: Icon(
                Icons.close,
                color: Colors.grey[600],
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
