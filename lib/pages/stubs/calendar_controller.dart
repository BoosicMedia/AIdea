import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'calendar_item.dart';
import '../../services/notifications_service.dart';

enum CalendarViewType { today, week, month }

class CalendarController extends ChangeNotifier {
  CalendarController({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _subscribeMonth();
    _subscribeRange();
  }

  final String userId;
  final FirebaseFirestore _firestore;

  DateTime _selectedDate = DateTime.now();
  CalendarViewType _viewType = CalendarViewType.today;
  DateTime? _loadedMonth;

  bool _isLoadingMonth = true;
  bool _isLoadingRange = true;

  List<CalendarItem> _monthTasks = [];
  List<CalendarItem> _monthIdeas = [];
  List<CalendarItem> _rangeTasks = [];
  List<CalendarItem> _rangeIdeas = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _monthTasksSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _monthIdeasSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _rangeTasksSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _rangeIdeasSub;

  DateTime get selectedDate => _selectedDate;
  CalendarViewType get viewType => _viewType;
  bool get isLoadingMonth => _isLoadingMonth;
  bool get isLoadingRange => _isLoadingRange;

  Map<DateTime, List<CalendarItem>> get monthItemsByDay =>
      _groupItemsByDay([..._monthTasks, ..._monthIdeas]);

  Map<DateTime, List<CalendarItem>> get rangeItemsByDay =>
      _groupItemsByDay([..._rangeTasks, ..._rangeIdeas]);

  void setView(CalendarViewType view) {
    if (_viewType == view) return;
    _viewType = view;
    _subscribeRange();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = _normalizeDay(date);
    _subscribeMonth();
    _subscribeRange();
    notifyListeners();
  }

  void addMonths(int offset) {
    final newMonth = DateTime(_selectedDate.year, _selectedDate.month + offset);
    setSelectedDate(_clampDay(newMonth, _selectedDate.day));
  }

  void addYears(int offset) {
    final newYear = DateTime(_selectedDate.year + offset, _selectedDate.month);
    setSelectedDate(_clampDay(newYear, _selectedDate.day));
  }

  DateTime _clampDay(DateTime date, int day) {
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    return DateTime(date.year, date.month, day.clamp(1, lastDay));
  }

  void _subscribeMonth() {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month);
    if (_loadedMonth != null &&
        _loadedMonth!.year == firstDay.year &&
        _loadedMonth!.month == firstDay.month) {
      return;
    }
    _loadedMonth = firstDay;
    _isLoadingMonth = true;
    _monthTasksSub?.cancel();
    _monthIdeasSub?.cancel();

    final start = Timestamp.fromDate(firstDay);
    final end = Timestamp.fromDate(DateTime(firstDay.year, firstDay.month + 1));
    _monthTasksSub = _tasksRef()
        .where('isDone', isEqualTo: false)
        .where('dueDate', isGreaterThanOrEqualTo: start)
        .where('dueDate', isLessThan: end)
        .snapshots()
        .listen((snapshot) {
          _monthTasks = snapshot.docs
              .map((doc) => CalendarItem.fromDoc(doc, type: 'task'))
              .toList();
          _isLoadingMonth = false;
          _scheduleNotifications();
          notifyListeners();
        });
    _monthIdeasSub = _ideasRef()
        .where('dueDate', isGreaterThanOrEqualTo: start)
        .where('dueDate', isLessThan: end)
        .snapshots()
        .listen((snapshot) {
          _monthIdeas = snapshot.docs
              .where((doc) => !_isIdeaDone(doc.data()))
              .map((doc) => CalendarItem.fromDoc(doc, type: 'idea'))
              .toList();
          _isLoadingMonth = false;
          _scheduleNotifications();
          notifyListeners();
        });
  }

  void _subscribeRange() {
    if (_viewType == CalendarViewType.month) {
      _rangeTasks = [];
      _rangeIdeas = [];
      _isLoadingRange = false;
      _rangeTasksSub?.cancel();
      _rangeIdeasSub?.cancel();
      return;
    }
    _isLoadingRange = true;
    _rangeTasksSub?.cancel();
    _rangeIdeasSub?.cancel();

    final startDay = _normalizeDay(_selectedDate);
    final endDay = _viewType == CalendarViewType.today
        ? startDay.add(const Duration(days: 1))
        : startDay.add(const Duration(days: 7));

    final start = Timestamp.fromDate(startDay);
    final end = Timestamp.fromDate(endDay);

    _rangeTasksSub = _tasksRef()
        .where('isDone', isEqualTo: false)
        .where('dueDate', isGreaterThanOrEqualTo: start)
        .where('dueDate', isLessThan: end)
        .snapshots()
        .listen((snapshot) {
          _rangeTasks = snapshot.docs
              .map((doc) => CalendarItem.fromDoc(doc, type: 'task'))
              .toList();
          _isLoadingRange = false;
          notifyListeners();
        });

    _rangeIdeasSub = _ideasRef()
        .where('dueDate', isGreaterThanOrEqualTo: start)
        .where('dueDate', isLessThan: end)
        .snapshots()
        .listen((snapshot) {
          _rangeIdeas = snapshot.docs
              .where((doc) => !_isIdeaDone(doc.data()))
              .map((doc) => CalendarItem.fromDoc(doc, type: 'idea'))
              .toList();
          _isLoadingRange = false;
          notifyListeners();
        });
  }

  CollectionReference<Map<String, dynamic>> _tasksRef() =>
      _firestore.collection('users').doc(userId).collection('tasks');

  CollectionReference<Map<String, dynamic>> _ideasRef() =>
      _firestore.collection('users').doc(userId).collection('ideas');

  Map<DateTime, List<CalendarItem>> _groupItemsByDay(List<CalendarItem> items) {
    final grouped = <DateTime, List<CalendarItem>>{};
    for (final item in items) {
      final key = _normalizeDay(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => _compareByTime(a, b));
    }
    return grouped;
  }

  int _compareByTime(CalendarItem a, CalendarItem b) {
    if (a.startTime == null && b.startTime == null) return 0;
    if (a.startTime == null) return 1;
    if (b.startTime == null) return -1;
    return a.startTime!.compareTo(b.startTime!);
  }

  DateTime _normalizeDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isIdeaDone(Map<String, dynamic>? data) {
    final raw = (data?['process'] as String?)?.toLowerCase();
    return raw == 'done';
  }

  void _scheduleNotifications() {
    final today = _normalizeDay(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final itemsByDay = monthItemsByDay;

    final todayTasks =
        itemsByDay[today]?.where((item) => item.type == 'task').length ?? 0;
    final tomorrowIdeas =
        itemsByDay[tomorrow]?.where((item) => item.type == 'idea').length ?? 0;

    NotificationsService.scheduleDailySummary(
      todayTasksCount: todayTasks,
      tomorrowIdeasCount: tomorrowIdeas,
    );
  }

  @override
  void dispose() {
    _monthTasksSub?.cancel();
    _monthIdeasSub?.cancel();
    _rangeTasksSub?.cancel();
    _rangeIdeasSub?.cancel();
    super.dispose();
  }
}
