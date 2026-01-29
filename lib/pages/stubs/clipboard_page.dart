import 'package:flutter/material.dart';

import 'package:helloworld/constants/colors.dart';

class ClipboardPage extends StatelessWidget {
  const ClipboardPage({super.key});

  static const routeName = '/stubs/clipboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(title: const Text('Clipboard')),
      body: const Center(child: Text('Clipboard stub')),
    );
  }
}
