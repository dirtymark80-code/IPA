import 'package:flutter/material.dart';
import 'presentation/screens/profile_screen.dart';
// Note: Ensure your theme.dart is imported here if you kept it.

void main() {
  runApp(const MyFitnessApp());
}

class MyFitnessApp extends StatelessWidget {
  const MyFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Fitness', // Explicitly named My Fitness
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.red, foregroundColor: Colors.white),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.red, foregroundColor: Colors.white),
      ),
      home: const ProfileScreen(),
    );
  }
}
