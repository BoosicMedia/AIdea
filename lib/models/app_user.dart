class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.photoUrl,
    required this.unreadNotificationsCount,
  });

  final String uid;
  final String name;
  final String photoUrl;
  final int unreadNotificationsCount;

  factory AppUser.fromMap(String uid, Map<String, dynamic>? data) {
    final map = data ?? {};
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      unreadNotificationsCount:
          (map['unreadNotificationsCount'] as num?)?.toInt() ?? 0,
    );
  }
}
