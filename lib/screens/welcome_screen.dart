import 'package:flutter/material.dart';

import '../widgets/gradient_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/outline_button.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.android,
                size: 56,
                color: Colors.white70,
              ),
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
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'login.',
                onTap: () => Navigator.pushNamed(
                  context,
                  LoginScreen.routeName,
                ),
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
  }
}
