import 'package:cloud_firestore/cloud_firestore.dart';

class Idea {
  const Idea({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.assignedToUid,
    required this.assignedToName,
    required this.process,
    required this.description,
    required this.createdAt,
    required this.createdByUid,
    required this.coverUrl,
  });

  final String id;
  final String title;
  final DateTime? dueDate;
  final String? assignedToUid;
  final String? assignedToName;
  final String process;
  final String description;
  final DateTime? createdAt;
  final String createdByUid;
  final String coverUrl;

  factory Idea.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Idea(
      id: doc.id,
      title: data['title'] as String? ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      assignedToUid: data['assignedToUid'] as String?,
      assignedToName: data['assignedToName'] as String?,
      process: data['process'] as String? ?? 'In Review',
      description: data['description'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      createdByUid: data['createdByUid'] as String? ?? '',
      coverUrl: data['coverUrl'] as String? ?? '',
    );
  }
}
