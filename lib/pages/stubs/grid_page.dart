import 'package:flutter/material.dart';

import 'package:helloworld/constants/colors.dart';

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  static const routeName = '/stubs/grid';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(title: const Text('Grid')),
      body: const Center(child: Text('Grid stub')),
    );
  }
}
