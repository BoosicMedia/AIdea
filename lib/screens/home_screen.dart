import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';
import '../widgets/content_card.dart';
import '../widgets/recommendation_tile.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D1155), Color(0xFF0B0A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none),
                    ),
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF2E2A3B),
                      child: Icon(Icons.person, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ćaoo,\n[ime korisnika!]',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Due',
                  style: TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(
                      child: ContentCard(
                        title: 'Naziv ideje',
                        subtitle: 'AIdea',
                        tag: '20 min',
                        progress: 0.6,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ContentCard(
                        title: 'Naziv ideje',
                        subtitle: 'AIdea',
                        tag: '10 min',
                        progress: 0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text(
                      'To - do',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const TodoItem(
                  title: 'To do 2',
                  time: '14:25',
                  completed: true,
                ),
                const TodoItem(
                  title: 'To do 2',
                  time: '15:30',
                  completed: false,
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI preporuke za danas',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const RecommendationTile(
                  label: '3 [x] STVARI KOJE MORAŠ ZNATI',
                  icon: Icons.lightbulb_outline,
                ),
                const SizedBox(height: 10),
                const RecommendationTile(
                  label: '3 [x] STVARI KOJE MORAŠ ZNATI',
                  icon: Icons.lightbulb_outline,
                ),
                const Spacer(),
                const BottomNavBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
