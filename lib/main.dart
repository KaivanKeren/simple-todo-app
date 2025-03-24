import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_project/models/save_task.dart';
import 'package:android_project/screens/add_todo.dart';
import 'package:android_project/screens/todo_list.dart';
import 'package:flutter/services.dart';

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
      providers: [ChangeNotifierProvider(create: (_) => SaveTask())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      themeMode: ThemeMode.system, // Respect system theme settings
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Define route generation with parameters
        if (settings.name == '/add-todo-screen') {
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => AddTodo(existingTask: args),
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
