import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/idea.dart';
import '../models/task_item.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _ideasRef(String uid) =>
      _userRef(uid).collection('ideas');

  CollectionReference<Map<String, dynamic>> _tasksRef(String uid) =>
      _userRef(uid).collection('tasks');

  Stream<AppUser> watchUser(String uid) {
    return _userRef(
      uid,
    ).snapshots().map((snapshot) => AppUser.fromMap(uid, snapshot.data()));
  }

  Stream<List<AppUser>> watchUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppUser.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Idea>> watchDueIdeas(String uid, DateTime now) {
    final startOfDay = DateTime(now.year, now.month, now.day);
    final limitDay = startOfDay.add(const Duration(days: 7));
    final endOfRange = DateTime(
      limitDay.year,
      limitDay.month,
      limitDay.day,
      23,
      59,
      59,
      999,
    );
    // Composite index may be required on users/{uid}/ideas: dueDate.
    return _ideasRef(uid)
        .where(
          'dueDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfRange))
        .orderBy('dueDate')
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => Idea.fromDoc(doc)).toList(),
        );
  }

  Stream<List<TaskItem>> watchUpcomingTasks(String uid) {
    // Composite index may be required on users/{uid}/tasks: isDone + dueDate + createdAt.
    return _tasksRef(uid)
        .where('isDone', isEqualTo: false)
        .orderBy('dueDate')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskItem.fromDoc(doc)).toList(),
        );
  }

  Future<void> createIdea({
    required String uid,
    required String title,
    required DateTime dueDate,
    required String? assignedToUid,
    required String? assignedToName,
    required String process,
    required String description,
  }) async {
    await _ideasRef(uid).add({
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'assignedToUid': assignedToUid,
      'assignedToName': assignedToName,
      'process': process,
      'description': description,
      'coverUrl': '',
      'createdByUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateIdea({
    required String uid,
    required String ideaId,
    required String title,
    required DateTime dueDate,
    required String? assignedToUid,
    required String? assignedToName,
    required String process,
    required String description,
  }) async {
    await _ideasRef(uid).doc(ideaId).update({
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'assignedToUid': assignedToUid,
      'assignedToName': assignedToName,
      'process': process,
      'description': description,
    });
  }

  Future<void> deleteIdea({required String uid, required String ideaId}) async {
    await _ideasRef(uid).doc(ideaId).delete();
  }

  Future<void> createTask({
    required String uid,
    required String title,
    DateTime? dueDate,
  }) async {
    await _tasksRef(uid).add({
      'title': title,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
      'isDone': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleTask({
    required String uid,
    required String taskId,
    required bool isDone,
  }) async {
    await _tasksRef(uid).doc(taskId).update({'isDone': isDone});
  }

  Future<void> resetNotifications(String uid) async {
    await _userRef(
      uid,
    ).set({'unreadNotificationsCount': 0}, SetOptions(merge: true));
  }
}
