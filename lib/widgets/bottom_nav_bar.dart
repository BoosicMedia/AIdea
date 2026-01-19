import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF191521),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.work_outline, color: Colors.white54),
          Icon(Icons.calendar_today, color: Colors.white54),
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.checklist, color: Colors.white54),
          Icon(Icons.bar_chart, color: Colors.white54),
        ],
      ),
    );
  }
}
