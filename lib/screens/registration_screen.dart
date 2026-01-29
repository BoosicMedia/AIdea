import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/pages/home/home_page.dart';
import 'package:helloworld/widgets/gradient_scaffold.dart';
import 'package:helloworld/widgets/labeled_field.dart';
import 'package:helloworld/widgets/primary_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Šifre se ne podudaraju.')));
      return;
    }
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      await credential.user?.updateDisplayName(_nameController.text.trim());
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomePage.routeName);
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'weak-password' => 'Šifra je preslaba.',
        'email-already-in-use' => 'Email je već u upotrebi.',
        'invalid-email' => 'Email nije ispravan.',
        _ => error.message ?? 'Došlo je do greške. Pokušaj ponovo.',
      };
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.android, size: 36, color: Colors.white70),
                ),
                const SizedBox(height: 22),
                const Text(
                  'AIdea.',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unesi podatke i kreiraj svoj nalog',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                LabeledField(
                  label: 'Ime',
                  controller: _nameController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Unesi ime'
                      : null,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Unesi email'
                      : null,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Šifra',
                  obscure: true,
                  controller: _passwordController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Unesi šifru'
                      : null,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Potvrdi šifru',
                  obscure: true,
                  controller: _confirmPasswordController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Potvrdi šifru'
                      : null,
                ),
                const SizedBox(height: 24),
                Center(
                  child: PrimaryButton(
                    label: 'registracija.',
                    onTap: _handleRegistration,
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
      ),
    );
  }
}
