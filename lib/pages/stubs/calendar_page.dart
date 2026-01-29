import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:helloworld/constants/colors.dart';
import 'package:helloworld/constants/styles.dart';
import 'package:helloworld/pages/home/home_page.dart';
import 'package:helloworld/pages/ideas/idea_details_page.dart';
import 'package:helloworld/pages/stubs/analytics_page.dart';
import 'package:helloworld/pages/stubs/calendar_controller.dart';
import 'package:helloworld/pages/stubs/calendar_item.dart';
import 'package:helloworld/pages/stubs/clipboard_page.dart';
import 'package:helloworld/pages/stubs/grid_page.dart';
import 'package:helloworld/pages/tasks/tasks_details_page.dart';
import 'package:provider/provider.dart';
import 'package:helloworld/services/notifications_service.dart';
import 'package:helloworld/widgets/bottom_nav_bar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  static const routeName = '/stubs/calendar';

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationsService.requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return ChangeNotifierProvider(
      create: (_) => CalendarController(userId: user.uid),
      child: const _CalendarScaffold(),
    );
  }
}

class _CalendarScaffold extends StatelessWidget {
  const _CalendarScaffold();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalendarController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const CalendarHeader(),
              const SizedBox(height: 12),
              const CalendarTabs(),
              const SizedBox(height: 12),
              Expanded(child: CalendarBody(viewType: controller.viewType)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: BottomNavBar(
          currentIndex: 3,
          onTap: (index) => _handleNavTap(context, index),
        ),
      ),
    );
  }
}

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalendarController>();
    final label = DateFormat('MMMM yyyy').format(controller.selectedDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showDatePopup(context),
            icon: const Icon(Icons.calendar_month, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePopup(BuildContext context) async {
    final controller = context.read<CalendarController>();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1B1527),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM').format(controller.selectedDate),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('yyyy').format(controller.selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ArrowButton(
                      icon: Icons.chevron_left,
                      onTap: () => controller.addMonths(-1),
                    ),
                    const SizedBox(width: 12),
                    _ArrowButton(
                      icon: Icons.chevron_right,
                      onTap: () => controller.addMonths(1),
                    ),
                    const SizedBox(width: 24),
                    _ArrowButton(
                      icon: Icons.expand_less,
                      onTap: () => controller.addYears(1),
                    ),
                    const SizedBox(width: 12),
                    _ArrowButton(
                      icon: Icons.expand_more,
                      onTap: () => controller.addYears(-1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CalendarTabs extends StatelessWidget {
  const CalendarTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalendarController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TabButton(
            label: 'Today',
            isActive: controller.viewType == CalendarViewType.today,
            onTap: () => controller.setView(CalendarViewType.today),
          ),
          const SizedBox(width: 10),
          _TabButton(
            label: 'Week',
            isActive: controller.viewType == CalendarViewType.week,
            onTap: () => controller.setView(CalendarViewType.week),
          ),
          const SizedBox(width: 10),
          _TabButton(
            label: 'Month',
            isActive: controller.viewType == CalendarViewType.month,
            onTap: () => controller.setView(CalendarViewType.month),
          ),
        ],
      ),
    );
  }
}

class CalendarBody extends StatelessWidget {
  const CalendarBody({super.key, required this.viewType});

  final CalendarViewType viewType;

  @override
  Widget build(BuildContext context) {
    switch (viewType) {
      case CalendarViewType.today:
        return const TodayView();
      case CalendarViewType.week:
        return const WeekView();
      case CalendarViewType.month:
        return const MonthView();
    }
  }
}

class TodayView extends StatelessWidget {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalendarController>();
    final items =
        controller.rangeItemsByDay[DateTime(
          controller.selectedDate.year,
          controller.selectedDate.month,
          controller.selectedDate.day,
        )] ??
        [];
    if (controller.isLoadingRange) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return const _EmptyState(message: 'Nema zadataka za danas.');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return TaskCard(
          item: items[index],
          onTap: () => _openDetails(context, items[index]),
        );
      },
    );
  }
}

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalendarController>();
    if (controller.isLoadingRange) {
      return const Center(child: CircularProgressIndicator());
    }

    final start = DateTime(
      controller.selectedDate.year,
      controller.selectedDate.month,
      controller.selectedDate.day,
    );
    final entries = List.generate(7, (index) {
      final day = start.add(Duration(days: index));
      final items = controller.rangeItemsByDay[day] ?? [];
      return MapEntry(day, items);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final dateLabel = DateFormat('EEE, dd.MM').format(entry.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateLabel, style: AppTextStyles.section),
              const SizedBox(height: 8),
              if (entry.value.isEmpty)
                const Text('Nema stavki.', style: AppTextStyles.muted)
              else
                Column(
                  children: entry.value
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskCard(
                            item: item,
                            onTap: () => _openDetails(context, item),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class MonthView extends StatefulWidget {
  const MonthView({super.key});

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalendarController>();
    if (controller.isLoadingMonth) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedDate = controller.selectedDate;
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    final leadingEmpty = (firstDayOfMonth.weekday + 6) % 7;

    final cells = <DateTime?>[];
    for (var i = 0; i < leadingEmpty; i++) {
      cells.add(null);
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(selectedDate.year, selectedDate.month, day));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const _WeekdayHeader(),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final day = cells[index];
              if (day == null) {
                return const SizedBox.shrink();
              }
              final items = controller.monthItemsByDay[day] ?? [];
              final hasIdeas = items.any((item) => item.type == 'idea');
              final hasTasks = items.any((item) => item.type == 'task');
              final isSelected =
                  _selectedDay != null &&
                  day.year == _selectedDay!.year &&
                  day.month == _selectedDay!.month &&
                  day.day == _selectedDay!.day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withAlpha(64)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? Border.all(color: AppColors.accent, width: 1)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (items.isNotEmpty)
                        Row(
                          children: [
                            if (hasTasks)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: _taskColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasTasks && hasIdeas) const SizedBox(width: 4),
                            if (hasIdeas)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: _ideaColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_selectedDay != null) ...[
            const SizedBox(height: 16),
            _SelectedDayList(
              day: _selectedDay!,
              items: controller.monthItemsByDay[_selectedDay!] ?? [],
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectedDayList extends StatelessWidget {
  const _SelectedDayList({required this.day, required this.items});

  final DateTime day;
  final List<CalendarItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('dd.MM.yyyy').format(day),
          style: AppTextStyles.section,
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text('Nema stavki.', style: AppTextStyles.muted)
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCard(
                item: item,
                onTap: () => _openDetails(context, item),
              ),
            ),
          ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.item, required this.onTap});

  final CalendarItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.type == 'idea' ? _ideaColor : _taskColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(item.title, style: AppTextStyles.title)),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent.withAlpha(51) : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.accent : AppColors.cardMuted,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (label) => Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.muted,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message, style: AppTextStyles.muted));
  }
}

const _ideaColor = Color(0xFF4DA3FF);
const _taskColor = Color(0xFF7B4DFF);

void _handleNavTap(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.pushReplacementNamed(context, ClipboardPage.routeName);
      break;
    case 1:
      Navigator.pushReplacementNamed(context, GridPage.routeName);
      break;
    case 2:
      Navigator.pushReplacementNamed(context, HomePage.routeName);
      break;
    case 3:
      Navigator.pushReplacementNamed(context, CalendarPage.routeName);
      break;
    case 4:
      Navigator.pushReplacementNamed(context, AnalyticsPage.routeName);
      break;
  }
}

void _openDetails(BuildContext context, CalendarItem item) {
  if (item.type == 'idea') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IdeaDetailsPage(ideaId: item.id)),
    );
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => TaskDetailsPage(taskId: item.id)),
  );
}
