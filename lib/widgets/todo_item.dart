import 'package:flutter/material.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.title,
    required this.time,
    required this.completed,
    required this.onToggle,
  });

  final String title;
  final String time;
  final bool completed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1A26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: completed ? Colors.greenAccent : Colors.white54,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: completed ? Colors.white60 : Colors.white,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(
              completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completed ? Colors.greenAccent : Colors.white54,
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}
