import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:helloworld/constants/colors.dart';
import 'package:helloworld/constants/styles.dart';
import 'package:helloworld/models/app_user.dart';
import 'package:helloworld/models/idea.dart';
import 'package:helloworld/models/task_item.dart';
import 'package:helloworld/services/firestore_service.dart';
import 'package:helloworld/pages/ideas/create_idea_page.dart';
import 'package:helloworld/pages/ideas/idea_details_page.dart';
import 'package:helloworld/pages/notifications/notifications_page.dart';
import 'package:helloworld/pages/recommendations/recommendations_page.dart';
import 'package:helloworld/pages/stubs/analytics_page.dart';
import 'package:helloworld/pages/stubs/calendar_page.dart';
import 'package:helloworld/pages/stubs/clipboard_page.dart';
import 'package:helloworld/pages/stubs/grid_page.dart';
import 'package:helloworld/pages/tasks/create_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _service = FirestoreService();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: StreamBuilder<AppUser>(
              stream: _service.watchUser(user.uid),
              builder: (context, snapshot) {
                final appUser = snapshot.data;
                final displayName = user.displayName?.trim().isNotEmpty == true
                    ? user.displayName!
                    : (appUser?.name ?? 'korisnik');
                final unreadCount = appUser?.unreadNotificationsCount ?? 0;
                final photoUrl = appUser?.photoUrl ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderRow(
                      unreadCount: unreadCount,
                      photoUrl: photoUrl,
                      onNotificationsTap: () async {
                        await Navigator.pushNamed(
                          context,
                          NotificationsPage.routeName,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ćaoo,\n$displayName!',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      title: 'Due',
                      actionIcon: Icons.edit,
                      onActionTap: () async {
                        final created = await Navigator.pushNamed(
                          context,
                          CreateIdeaPage.routeName,
                        );
                        if (created == true && mounted) {
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    Container(height: 1, color: AppColors.divider),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 190,
                      child: StreamBuilder<List<Idea>>(
                        stream: _service.watchDueIdeas(
                          user.uid,
                          DateTime.now(),
                        ),
                        builder: (context, ideasSnapshot) {
                          final ideas = ideasSnapshot.data ?? [];
                          if (ideas.isEmpty) {
                            return _EmptyState(text: 'Nema due ideja.');
                          }
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: ideas.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final idea = ideas[index];
                              return _IdeaCard(
                                idea: idea,
                                dateFormat: _dateFormat,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        IdeaDetailsPage(ideaId: idea.id),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      title: 'To - do',
                      actionIcon: Icons.add,
                      onActionTap: () async {
                        final created = await Navigator.pushNamed(
                          context,
                          CreateTaskPage.routeName,
                        );
                        if (created == true && mounted) {
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    Container(height: 1, color: AppColors.divider),
                    const SizedBox(height: 10),
                    StreamBuilder<List<TaskItem>>(
                      stream: _service.watchUpcomingTasks(user.uid),
                      builder: (context, tasksSnapshot) {
                        final tasks = tasksSnapshot.data ?? [];
                        final now = DateTime.now();
                        final limit = now.add(const Duration(days: 7));
                        final filtered = tasks.where((task) {
                          if (task.dueDate == null) {
                            return true;
                          }
                          return task.dueDate!.isBefore(limit) ||
                              task.dueDate!.isAtSameMomentAs(limit);
                        }).toList();
                        if (filtered.isEmpty) {
                          return _EmptyState(text: 'Nema taskova.');
                        }
                        return Column(
                          children: filtered
                              .map(
                                (task) => _TaskRow(
                                  task: task,
                                  dateFormat: _dateFormat,
                                  onToggle: () => _service.toggleTask(
                                    uid: user.uid,
                                    taskId: task.id,
                                    isDone: true,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AI preporuke za danas',
                      style: AppTextStyles.section,
                    ),
                    const SizedBox(height: 6),
                    Container(height: 1, color: AppColors.divider),
                    const SizedBox(height: 10),
                    _RecommendationTile(
                      icon: Icons.local_fire_department,
                      label: '3 [x] STVARI KOJE MORAŠ ZNATI',
                      onTap: () => Navigator.pushNamed(
                        context,
                        RecommendationPage.routeName,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RecommendationTile(
                      icon: Icons.brightness_1,
                      label: '3 [x] STVARI KOJE MORAŠ ZNATI',
                      onTap: () => Navigator.pushNamed(
                        context,
                        RecommendationPage.routeName,
                      ),
                    ),
                    const Spacer(),
                    _BottomNavBar(
                      onClipboardTap: () =>
                          Navigator.pushNamed(context, ClipboardPage.routeName),
                      onGridTap: () =>
                          Navigator.pushNamed(context, GridPage.routeName),
                      onCalendarTap: () =>
                          Navigator.pushNamed(context, CalendarPage.routeName),
                      onAnalyticsTap: () =>
                          Navigator.pushNamed(context, AnalyticsPage.routeName),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.unreadCount,
    required this.photoUrl,
    required this.onNotificationsTap,
  });

  final int unreadCount;
  final String photoUrl;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Dashboard', style: AppTextStyles.muted),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: onNotificationsTap,
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.badge,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 6),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.card,
          backgroundImage: photoUrl.isNotEmpty
              ? CachedNetworkImageProvider(photoUrl)
              : null,
          child: photoUrl.isEmpty ? const Icon(Icons.person, size: 18) : null,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionIcon,
    required this.onActionTap,
  });

  final String title;
  final IconData actionIcon;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.section),
        const Spacer(),
        IconButton(
          icon: Icon(actionIcon, color: AppColors.accentSoft),
          onPressed: onActionTap,
        ),
      ],
    );
  }
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({
    required this.idea,
    required this.dateFormat,
    required this.onTap,
  });

  final Idea idea;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dueText = idea.dueDate == null
        ? 'Due: -'
        : 'Due: ${dateFormat.format(idea.dueDate!)}';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: idea.coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: idea.coverUrl,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/idea_placeholder.png',
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              idea.title.isEmpty ? 'Naziv ideje' : idea.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Lorem ipsum dolor sit amet.',
              style: AppTextStyles.muted,
            ),
            const Spacer(),
            Text(dueText, style: AppTextStyles.muted),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                idea.process,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.dateFormat,
    required this.onToggle,
  });

  final TaskItem task;
  final DateFormat dateFormat;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final dueText = task.dueDate == null
        ? 'Due: No date'
        : 'Due: ${dateFormat.format(task.dueDate!)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textMuted, width: 1.5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(dueText, style: AppTextStyles.muted),
              ],
            ),
          ),
          const Icon(Icons.more_horiz, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.cardMuted,
              child: Icon(icon, size: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: AppTextStyles.muted));
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.onClipboardTap,
    required this.onGridTap,
    required this.onCalendarTap,
    required this.onAnalyticsTap,
  });

  final VoidCallback onClipboardTap;
  final VoidCallback onGridTap;
  final VoidCallback onCalendarTap;
  final VoidCallback onAnalyticsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardMuted,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            color: AppColors.textMuted,
            onPressed: onClipboardTap,
          ),
          IconButton(
            icon: const Icon(Icons.grid_view),
            color: AppColors.textMuted,
            onPressed: onGridTap,
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.home, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            color: AppColors.textMuted,
            onPressed: onCalendarTap,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            color: AppColors.textMuted,
            onPressed: onAnalyticsTap,
          ),
        ],
      ),
    );
  }
}
