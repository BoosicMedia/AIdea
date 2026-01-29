import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:helloworld/pages/home/home_page.dart';
import 'package:helloworld/screens/login_screen.dart';
import 'package:helloworld/screens/registration_screen.dart';
import 'package:helloworld/widgets/gradient_scaffold.dart';
import 'package:helloworld/widgets/outline_button.dart';
import 'package:helloworld/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return GradientScaffold(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Icon(Icons.android, size: 56, color: Colors.white70),
                  const SizedBox(height: 18),
                  const Text(
                    'DOBRO DOŠAO',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AIdea.',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'login.',
                    onTap: () =>
                        Navigator.pushNamed(context, LoginScreen.routeName),
                  ),
                  const SizedBox(height: 14),
                  OutlineButton(
                    label: 'registracija.',
                    onTap: () => Navigator.pushNamed(
                      context,
                      RegistrationScreen.routeName,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'created by bossicmedia',
                    style: TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
