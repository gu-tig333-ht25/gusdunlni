import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'todo_provider.dart';
import 'screens/todo_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: MaterialApp(
        title: 'TIG333 TODO',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1E5A8A)),
          useMaterial3: true,
          primaryColor: Color(0xFF1E5A8A),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1E5A8A),
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
        ),
        home: TodoListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
