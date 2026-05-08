
import 'package:aptasutra/aptasutra_screen.dart';
import 'package:aptasutra/constants.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(const AptasutraApp());
}

class AptasutraApp extends StatelessWidget {
  const AptasutraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(


    ).copyWith(
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Constants.fontColor),
      bodyMedium: TextStyle(color: Constants.fontColor),
      bodySmall: TextStyle(color: Constants.fontColor),
      titleLarge: TextStyle(color: Constants.fontColor),
      titleMedium: TextStyle(color: Constants.fontColor),
      titleSmall: TextStyle(color: Constants.fontColor),
    ),
  ), home: const AptasutraScreen());
  }
}

