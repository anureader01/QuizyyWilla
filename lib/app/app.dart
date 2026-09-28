
import 'package:flutter/material.dart';
import 'package:quizbit_2/core/services/authgate_service.dart';
import 'package:quizbit_2/features/auth/screens/emailconfirm.dart';
import 'package:quizbit_2/features/auth/screens/login.dart';
import 'package:quizbit_2/features/auth/screens/signup.dart';
import 'package:quizbit_2/features/home/home_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen()
    );
  }
}

