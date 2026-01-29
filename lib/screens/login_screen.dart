import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/pages/home/home_page.dart';
import 'package:helloworld/widgets/gradient_scaffold.dart';
import 'package:helloworld/widgets/labeled_field.dart';
import 'package:helloworld/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomePage.routeName);
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'user-not-found' => 'Korisnik ne postoji.',
        'wrong-password' => 'Pogrešna šifra.',
        'invalid-email' => 'Email nije ispravan.',
        _ => 'Došlo je do greške. Pokušaj ponovo.',
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
                  'Upiši podatke i pristupi svom nalogu',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                LabeledField(
                  label: 'Email',
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
                const SizedBox(height: 24),
                Center(
                  child: PrimaryButton(label: 'login.', onTap: _handleLogin),
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
