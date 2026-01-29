import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.isDone,
    required this.createdAt,
  });

  final String id;
  final String title;
  final DateTime? dueDate;
  final bool isDone;
  final DateTime? createdAt;

  factory TaskItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TaskItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      isDone: data['isDone'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
