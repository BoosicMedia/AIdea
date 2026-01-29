import 'package:flutter/material.dart';

import 'package:helloworld/constants/colors.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  static const routeName = '/recommendations';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(title: const Text('Recommendation')),
      body: const Center(child: Text('Recommendation stub')),
    );
  }
}
