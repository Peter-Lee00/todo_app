import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/data/models/hive_todo.dart';
import 'package:todo_app/data/models/repository/hive_todo_repo.dart';
import 'package:todo_app/domain/repository/todo_repo.dart';
import 'package:todo_app/presentation/category_cubit.dart';
import 'package:todo_app/presentation/screens/main_screen.dart';
import 'package:todo_app/presentation/todo_cubit.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  // This sets up the necessary directory structure for Hive to store data
  await Hive.initFlutter();

  // Register the TodoHive adapter with Hive
  // This allows Hive to serialize/deserialize TodoHive objects
  // The type ID (0) must be unique for each adapter in your app
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TodoHiveAdapter());
  }

  // Open the Hive box that will store our todos
  // A box is like a persistent map that stores data even after app restart
  final todoBox = await Hive.openBox<TodoHive>(
    'todos',
    compactionStrategy: (entries, deletedEntries) {
      // Automatically compact (clean up) the box when:
      // 1. There are more than 20 deleted entries, or
      // 2. Deleted entries take up more than 20% of total entries
      return deletedEntries > 20 || deletedEntries > entries * 0.2;
    },
  );

  // Create our todo repository using the Hive box
  // This repository will handle all data operations
  final hiveTodoRepo = HiveTodoRepo(todoBox);

  // Start the app with the repository
  runApp(MyApp(todoRepo: hiveTodoRepo));
}

class MyApp extends StatelessWidget {
  // Repository instance that will be used throughout the app
  final TodoRepo todoRepo;

  const MyApp({super.key, required this.todoRepo});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider allows us to provide multiple BLoC instances
    // to the widget tree
    return MultiBlocProvider(
      providers: [
        // TodoCubit manages the state of todos
        BlocProvider(create: (context) => TodoCubit(todoRepo)),
        // CategoryCubit manages the state of categories
        BlocProvider(create: (context) => CategoryCubit()),
      ],
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        // Define the app-wide theme
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[200],
          // AppBar theme configuration
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[200],
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Bottom navigation bar theme configuration
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey[600],
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
        ),
        // MainScreen is the root screen of our app
        home: const MainScreen(),
      ),
    );
  }
}
