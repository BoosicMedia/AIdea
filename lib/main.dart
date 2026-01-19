import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const AIdeaApp());
}

class AIdeaApp extends StatelessWidget {
  const AIdeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIdea',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF0E0B16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7B4DFF),
          secondary: Color(0xFFB48CFF),
        ),
      ),
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (context) => const WelcomeScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegistrationScreen.routeName: (context) =>
            const RegistrationScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
    );
  }
}
