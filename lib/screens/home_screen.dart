import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/models/idea_item.dart';
import 'package:helloworld/models/idea_repository.dart';
import 'package:helloworld/screens/create_idea_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final IdeaRepository _repository = IdeaRepository();

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _openNewIdea() async {
    await Navigator.pushNamed(context, CreateIdeaScreen.routeName);
  }

  Future<void> _openEditIdea(IdeaItem idea) async {
    await Navigator.pushNamed(
      context,
      CreateIdeaScreen.routeName,
      arguments: idea,
    );
  }

  Future<void> _deleteIdea(IdeaItem idea) async {
    await _repository.deleteIdea(idea.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('AIdea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
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
                const Text(
                  'Ćaoo,\n[ime korisnika!]',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text(
                      'Moje ideje',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _openNewIdea,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<List<IdeaItem>>(
                    stream: _repository.watchMyIdeas(_uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final ideas = snapshot.data ?? [];
                      if (ideas.isEmpty) {
                        return const Center(
                          child: Text('Još nema ideja. Dodaj novu!'),
                        );
                      }
                      return ListView.separated(
                        itemCount: ideas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final idea = ideas[index];
                          return ListTile(
                            tileColor: const Color(0xFF231F2E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(idea.title),
                            subtitle: Text(
                              [
                                idea.status,
                                if ((idea.platform ?? '').isNotEmpty)
                                  idea.platform!,
                              ].join(' • '),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteIdea(idea),
                            ),
                            onTap: () => _openEditIdea(idea),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
