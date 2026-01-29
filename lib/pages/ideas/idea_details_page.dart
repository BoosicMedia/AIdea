import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:helloworld/constants/colors.dart';
import 'package:helloworld/constants/styles.dart';

class IdeaDetailsPage extends StatefulWidget {
  const IdeaDetailsPage({super.key, required this.ideaId});

  static const routeName = '/ideas/details';

  final String ideaId;

  @override
  State<IdeaDetailsPage> createState() => _IdeaDetailsPageState();
}

class _IdeaDetailsPageState extends State<IdeaDetailsPage> {
  final _dateFormat = DateFormat('dd.MM.yyyy');

  User? get _user => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>> _ideaRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ideas')
        .doc(widget.ideaId);
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F12),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0E0F12),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _openEditSheet(context, user.uid),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _ideaRef(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final doc = snapshot.data;
          if (doc == null || !doc.exists) {
            return _NotFoundState(onBack: () => Navigator.pop(context));
          }
          final data = doc.data() ?? {};
          final title = (data['title'] as String?)?.trim().isNotEmpty == true
              ? data['title'] as String
              : 'Naziv ideje';
          final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
          final assignedTo =
              (data['assignedTo'] as String?) ??
              (data['assignedToName'] as String?) ??
              '';
          final process = normalizeProcess(data['process'] as String?);
          final description = (data['description'] as String?) ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _MetaRow(
                  label: 'Due Date:',
                  value: dueDate == null ? '—' : _dateFormat.format(dueDate),
                ),
                const SizedBox(height: 8),
                _MetaRow(
                  label: 'Assign:',
                  value: assignedTo.isEmpty ? '—' : assignedTo,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Process:', style: AppTextStyles.muted),
                    const SizedBox(width: 10),
                    ProcessBadge(process: process),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Description:', style: AppTextStyles.muted),
                const SizedBox(height: 8),
                Text(
                  description.isEmpty ? 'Opis ideje' : description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openEditSheet(BuildContext context, String uid) async {
    final doc = await _ideaRef(uid).get();
    if (!doc.exists) return;
    final data = doc.data() ?? {};
    final titleController = TextEditingController(
      text: data['title'] as String? ?? '',
    );
    final assignedController = TextEditingController(
      text: data['assignedTo'] as String? ?? '',
    );
    final descriptionController = TextEditingController(
      text: data['description'] as String? ?? '',
    );
    final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
    var selectedDate = dueDate;
    var process = normalizeProcess(data['process'] as String?);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0E0F12),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Idea', style: AppTextStyles.section),
                  const SizedBox(height: 12),
                  _SheetField(label: 'Title', controller: titleController),
                  const SizedBox(height: 12),
                  _SheetField(
                    label: 'Assigned to',
                    controller: assignedController,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? now,
                        firstDate: DateTime(now.year - 5),
                        lastDate: DateTime(now.year + 5),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.accent,
                                onPrimary: Colors.white,
                                surface: AppColors.card,
                                onSurface: Colors.white,
                              ),
                              dialogTheme: const DialogThemeData(
                                backgroundColor: AppColors.card,
                              ),
                            ),
                            child: child ?? const SizedBox.shrink(),
                          );
                        },
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Due date',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            selectedDate == null
                                ? '—'
                                : _dateFormat.format(selectedDate!),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: process,
                    items: const [
                      DropdownMenuItem(value: 'idea', child: Text('Idea')),
                      DropdownMenuItem(
                        value: 'in_review',
                        child: Text('In Review'),
                      ),
                      DropdownMenuItem(
                        value: 'approved',
                        child: Text('Approved'),
                      ),
                      DropdownMenuItem(
                        value: 'in_progress',
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem(value: 'done', child: Text('Done')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() => process = value);
                    },
                    dropdownColor: AppColors.card,
                    decoration: InputDecoration(
                      labelText: 'Process',
                      labelStyle: AppTextStyles.muted,
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: AppTextStyles.muted,
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Naslov je obavezan.'),
                            ),
                          );
                          return;
                        }
                        if (process == 'done') {
                          await _ideaRef(uid).delete();
                          if (!mounted) return;
                          Navigator.pop(context);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Idea marked Done and removed.'),
                            ),
                          );
                          return;
                        }

                        await _ideaRef(uid).update({
                          'title': titleController.text.trim(),
                          'dueDate': selectedDate == null
                              ? null
                              : Timestamp.fromDate(selectedDate!),
                          'assignedTo': assignedController.text.trim(),
                          'process': process,
                          'description': descriptionController.text.trim(),
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(
                          this.context,
                        ).showSnackBar(const SnackBar(content: Text('Saved')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class ProcessBadge extends StatelessWidget {
  const ProcessBadge({super.key, required this.process});

  final String process;

  @override
  Widget build(BuildContext context) {
    final data = _processData(process);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        data.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _ProcessData _processData(String process) {
    return _ProcessData(processLabel(process), processColor(process));
  }
}

String normalizeProcess(String? raw) {
  if (raw == null) return 'idea';
  final value = raw.trim().toLowerCase().replaceAll(' ', '_');
  switch (value) {
    case 'idea':
    case 'in_review':
    case 'approved':
    case 'in_progress':
    case 'done':
      return value;
    case 'inprogress':
      return 'in_progress';
    case 'inreview':
      return 'in_review';
    default:
      return 'idea';
  }
}

String processLabel(String process) {
  switch (process) {
    case 'idea':
      return 'Idea';
    case 'in_review':
      return 'In Review';
    case 'approved':
      return 'Approved';
    case 'in_progress':
      return 'In Progress';
    case 'done':
      return 'Done';
    default:
      return 'Idea';
  }
}

Color processColor(String process) {
  switch (process) {
    case 'idea':
      return const Color(0xFF7C3AED);
    case 'in_review':
      return const Color(0xFF64748B);
    case 'approved':
      return const Color(0xFF22C55E);
    case 'in_progress':
      return const Color(0xFF3B82F6);
    case 'done':
      return const Color(0xFF14B8A6);
    default:
      return const Color(0xFF7C3AED);
  }
}

class _ProcessData {
  const _ProcessData(this.label, this.color);

  final String label;
  final Color color;
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.muted),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.muted,
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Idea not found', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onBack, child: const Text('Back')),
        ],
      ),
    );
  }
}
