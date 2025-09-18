import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIG333 TODO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1E5A8A)),
        useMaterial3: true,
        primaryColor: Color(0xFF1E5A8A),
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // Sample todo items
  List<Map<String, dynamic>> todoItems = [
    {'text': 'Write a book', 'isCompleted': false},
    {'text': 'Do homework', 'isCompleted': false},
    {'text': 'Tidy room', 'isCompleted': true},
    {'text': 'Watch TV', 'isCompleted': false},
    {'text': 'Nap', 'isCompleted': false},
    {'text': 'Shop groceries', 'isCompleted': false},
    {'text': 'Have fun', 'isCompleted': false},
    {'text': 'Meditate', 'isCompleted': false},
  ];

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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              print('Selected: $value');
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'All', child: Text('all')),
              PopupMenuItem(value: 'Done', child: Text('done')),
              PopupMenuItem(value: 'Undone', child: Text('undone')),
            ],
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: todoItems.length,
          itemBuilder: (context, index) {
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
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: todoItems[index]['isCompleted'] 
                            ? Color(0xFF1E5A8A) 
                            : Colors.grey[400]!, 
                        width: 2
                      ),
                      shape: BoxShape.circle,
                      color: todoItems[index]['isCompleted'] 
                          ? Color(0xFF1E5A8A) 
                          : Colors.transparent,
                    ),
                    child: todoItems[index]['isCompleted']
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  SizedBox(width: 16),
                  // Task text
                  Expanded(
                    child: Text(
                      todoItems[index]['text'],
                      style: TextStyle(
                        fontSize: 16,
                        decoration: todoItems[index]['isCompleted']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: todoItems[index]['isCompleted']
                            ? Colors.grey[600]
                            : Colors.black,
                      ),
                    ),
                  ),
                  // Delete button
                  GestureDetector(
                    onTap: () {
                      print('Delete item: ${todoItems[index]['text']}');
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ],
              ),
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
              MaterialPageRoute(builder: (context) => AddTaskScreen()),
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
}

class AddTaskScreen extends StatefulWidget {
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E5A8A),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'TIG333 TODO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Input field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'What are you going to do?',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('Add task: ${_textController.text}');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E5A8A),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '+ ADD',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
