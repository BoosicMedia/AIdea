import 'package:flutter/material.dart';

import '../constants/colors.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _icons = [
    Icons.assignment_outlined,
    Icons.grid_view,
    Icons.home,
    Icons.calendar_today,
    Icons.bar_chart,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardMuted,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_icons.length, (index) {
          if (index == 2) {
            return GestureDetector(
              onTap: currentIndex == index ? null : () => onTap(index),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.home, color: Colors.white),
              ),
            );
          }
          final isActive = currentIndex == index;
          return IconButton(
            icon: Icon(_icons[index]),
            color: isActive ? AppColors.accentSoft : AppColors.textMuted,
            onPressed: () => onTap(index),
          );
        }),
      ),
    );
  }
}
