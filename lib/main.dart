import 'package:flutter/material.dart';
import 'package:hymnus/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hymnus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: MediaQuery.of(context).platformBrightness,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(
        title: 'Home',
      ),
    );
  }
}
