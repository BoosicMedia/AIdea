import 'package:cloud_firestore/cloud_firestore.dart';

class IdeaItem {
  IdeaItem({
    required this.id,
    required this.ownerId,
    required this.title,
    this.platform,
    this.contentType,
    this.hook,
    this.script,
    this.cta,
    required this.tags,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.subtitle,
    this.tag,
    this.progress,
    this.dueDate,
    this.assignedTo,
    this.description,
  });

  final String id;
  final String ownerId;
  final String title;
  final String? platform;
  final String? contentType;
  final String? hook;
  final String? script;
  final String? cta;
  final List<String> tags;
  final String status;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  final String? subtitle;
  final String? tag;
  final double? progress;
  final DateTime? dueDate;
  final String? assignedTo;
  final String? description;

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'platform': platform,
      'contentType': contentType,
      'hook': hook,
      'script': script,
      'cta': cta,
      'tags': tags,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory IdeaItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return IdeaItem(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      platform: data['platform'] as String?,
      contentType: data['contentType'] as String?,
      hook: data['hook'] as String?,
      script: data['script'] as String?,
      cta: data['cta'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      status: data['status'] as String? ?? 'draft',
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  IdeaItem copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? platform,
    String? contentType,
    String? hook,
    String? script,
    String? cta,
    List<String>? tags,
    String? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return IdeaItem(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      contentType: contentType ?? this.contentType,
      hook: hook ?? this.hook,
      script: script ?? this.script,
      cta: cta ?? this.cta,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subtitle: subtitle,
      tag: tag,
      progress: progress,
      dueDate: dueDate,
      assignedTo: assignedTo,
      description: description,
    );
  }
}
