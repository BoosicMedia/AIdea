import 'package:flutter/material.dart';

import 'package:helloworld/constants/colors.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static const routeName = '/stubs/analytics';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(child: Text('Analytics stub')),
    );
  }
}
