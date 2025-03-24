import 'package:android_project/models/task_model.dart';
import 'package:android_project/screens/edit_todo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_project/models/save_task.dart';
import 'package:android_project/screens/add_todo.dart';
import 'package:android_project/screens/todo_list.dart';
import 'package:flutter/services.dart';

// Import the ThemeProvider
import 'theme_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run the app with error handling
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SaveTask()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      themeMode: themeProvider.themeMode, // Use theme from provider
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Define route generation with parameters
        if (settings.name == '/add-todo-screen') {
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => AddTodo(existingTask: args),
          );
        }
        if (settings.name == '/edit-todo-screen') {
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => EditTodo(existingTask: args as Task?),
          );
        }
        return null;
      },
      routes: {'/': (context) => const TodoList()},
      // Global error handling
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
          ),
          child: child!,
        );
      },
    );
  }
}