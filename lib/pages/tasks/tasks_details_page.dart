import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:helloworld/constants/colors.dart';
import 'package:helloworld/constants/styles.dart';

class TaskDetailsPage extends StatelessWidget {
  const TaskDetailsPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    final taskRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskId);

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBottom,
        title: const Text('Task Details'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: taskRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final doc = snapshot.data;
          if (doc == null || !doc.exists) {
            return _NotFoundState(onBack: () => Navigator.pop(context));
          }
          final data = doc.data() ?? {};
          final title = (data['title'] as String?) ?? '';
          final description = (data['description'] as String?) ?? '';
          final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
          final startTime = data['startTime'] as String?;
          final endTime = data['endTime'] as String?;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headline),
                const SizedBox(height: 12),
                _MetaRow(
                  label: 'Due Date:',
                  value: dueDate == null
                      ? '—'
                      : DateFormat('dd.MM.yyyy').format(dueDate),
                ),
                if (startTime != null || endTime != null) ...[
                  const SizedBox(height: 8),
                  _MetaRow(
                    label: 'Time:',
                    value: _timeLabel(startTime, endTime),
                  ),
                ],
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Description:', style: AppTextStyles.muted),
                  const SizedBox(height: 6),
                  Text(description, style: AppTextStyles.body),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _timeLabel(String? start, String? end) {
    if (start != null && end != null) {
      return '$start - $end';
    }
    return start ?? end ?? '';
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.muted),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: AppTextStyles.body)),
      ],
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Task not found', style: AppTextStyles.muted),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onBack, child: const Text('Back')),
        ],
      ),
    );
  }
}
