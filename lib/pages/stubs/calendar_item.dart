import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CalendarItem {
  CalendarItem({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    this.description,
    this.startTime,
    this.endTime,
  });

  final String id;
  final String type;
  final String title;
  final String? description;
  final DateTime date;
  final String? startTime;
  final String? endTime;

  static final DateFormat _timeFormat = DateFormat('HH:mm');

  factory CalendarItem.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String type,
  }) {
    final data = doc.data() ?? {};
    final timestamp =
        (data['dueDate'] as Timestamp?) ?? (data['date'] as Timestamp?);
    final date = timestamp?.toDate() ?? DateTime.now();
    return CalendarItem(
      id: doc.id,
      type: type,
      title: (data['title'] as String?) ?? '',
      description: data['description'] as String?,
      date: DateTime(date.year, date.month, date.day),
      startTime: _parseTimeValue(data['startTime'], date),
      endTime: _parseTimeValue(data['endTime'], date),
    );
  }

  static String? _parseTimeValue(dynamic value, DateTime baseDate) {
    if (value == null) return null;
    if (value is Timestamp) {
      return _timeFormat.format(value.toDate());
    }
    if (value is String && value.trim().isNotEmpty) {
      final trimmed = value.trim();
      final parts = trimmed.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          final parsed = DateTime(
            baseDate.year,
            baseDate.month,
            baseDate.day,
            hour,
            minute,
          );
          return _timeFormat.format(parsed);
        }
      }
      return trimmed;
    }
    return null;
  }
}
