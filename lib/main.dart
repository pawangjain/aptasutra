
import 'package:aptasutra/aptasutra_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(const AptasutraApp());
}

class AptasutraApp extends StatelessWidget {
  const AptasutraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const AptasutraScreen());
  }
}

