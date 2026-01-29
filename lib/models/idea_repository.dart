import 'package:cloud_firestore/cloud_firestore.dart';

import 'idea_item.dart';

class IdeaRepository {
  IdeaRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ideas =>
      _firestore.collection('ideas');

  Stream<List<IdeaItem>> watchMyIdeas(String uid) {
    return _ideas
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => IdeaItem.fromDoc(doc)).toList(),
        );
  }

  Future<void> addIdea(IdeaItem idea) async {
    await _ideas.add({
      ...idea.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateIdea(IdeaItem idea) async {
    await _ideas.doc(idea.id).update({
      ...idea.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteIdea(String ideaId) async {
    await _ideas.doc(ideaId).delete();
  }
}
