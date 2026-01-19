import 'package:flutter/material.dart';

import '../widgets/gradient_scaffold.dart';
import '../widgets/labeled_field.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  static const routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.topCenter,
                child: Icon(
                  Icons.android,
                  size: 36,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'AIdea.',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unesi podatke i kreiraj svoj nalog',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              const LabeledField(label: 'Ime'),
              const SizedBox(height: 16),
              const LabeledField(label: 'Mail'),
              const SizedBox(height: 16),
              const LabeledField(label: 'Šifra', obscure: true),
              const SizedBox(height: 24),
              Center(
                child: PrimaryButton(
                  label: 'login.',
                  onTap: () => Navigator.pushNamed(
                    context,
                    HomeScreen.routeName,
                  ),
                ),
              ),
              const Spacer(),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'created by bossicmedia',
                  style: TextStyle(fontSize: 10, color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
