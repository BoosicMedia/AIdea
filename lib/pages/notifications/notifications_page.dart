import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:helloworld/constants/colors.dart';
import 'package:helloworld/services/firestore_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static const routeName = '/notifications';

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirestoreService _service = FirestoreService();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _service.resetNotifications(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Notifications stub')),
    );
  }
}
