import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/presentation/category_cubit.dart';
import 'package:todo_app/presentation/screens/main_screen.dart';
import 'package:todo_app/presentation/todo_cubit.dart';
import 'package:todo_app/presentation/theme_cubit.dart';
import 'package:todo_app/data/database/database_helper.dart';
import 'package:todo_app/data/settings/settings_helper.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize database and settings
  await DatabaseHelper.instance.database;
  await SettingsHelper.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit(SettingsHelper.instance)),
        BlocProvider(create: (context) => TodoCubit()),
        BlocProvider(create: (context) => CategoryCubit()),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDarkMode) {
          return MaterialApp(
            title: 'Todo App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
