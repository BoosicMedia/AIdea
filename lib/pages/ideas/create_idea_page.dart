import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:helloworld/constants/colors.dart';
import 'package:helloworld/constants/styles.dart';
import 'package:helloworld/models/app_user.dart';
import 'package:helloworld/models/idea.dart';
import 'package:helloworld/services/firestore_service.dart';

class CreateIdeaPage extends StatefulWidget {
  const CreateIdeaPage({super.key});

  static const routeName = '/ideas/create';

  @override
  State<CreateIdeaPage> createState() => _CreateIdeaPageState();
}

class _CreateIdeaPageState extends State<CreateIdeaPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('MMM d, yyyy');
  final _service = FirestoreService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  AppUser? _assignedUser;
  String _process = 'idea';
  Idea? _editingIdea;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Idea) {
      _editingIdea = args;
      _titleController.text = args.title;
      _selectedDate = args.dueDate;
      _process = _normalizeProcess(args.process);
      _descriptionController.text = args.description;
      if (args.assignedToUid != null || args.assignedToName != null) {
        _assignedUser = AppUser(
          uid: args.assignedToUid ?? '',
          name: args.assignedToName ?? '',
          photoUrl: '',
          unreadNotificationsCount: 0,
        );
      }
    }
    _initialized = true;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: today,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.card,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: AppColors.card),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveIdea() async {
    if (_selectedDate == null) {
      _showError('Odaberi datum.');
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_selectedDate!.isBefore(today)) {
      _showError('Datum ne može biti u prošlosti.');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final dueDate = _selectedDate!;
    final title = _titleController.text.trim();
    if (_editingIdea == null) {
      await _service.createIdea(
        uid: user.uid,
        title: title,
        dueDate: dueDate,
        assignedToUid: _assignedUser?.uid,
        assignedToName: _assignedUser?.name,
        process: _process,
        description: _descriptionController.text.trim(),
      );
    } else {
      await _service.updateIdea(
        uid: user.uid,
        ideaId: _editingIdea!.id,
        title: title,
        dueDate: dueDate,
        assignedToUid: _assignedUser?.uid,
        assignedToName: _assignedUser?.name,
        process: _process,
        description: _descriptionController.text.trim(),
      );
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: _saveIdea),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                style: AppTextStyles.title,
                decoration: const InputDecoration(
                  hintText: 'New Idea...',
                  hintStyle: AppTextStyles.muted,
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Unesi naziv ideje.'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InlineField(
                      label: 'Due Date',
                      value: _selectedDate == null
                          ? 'Select'
                          : _dateFormat.format(_selectedDate!),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InlineField(
                      label: 'Assign To',
                      value: _assignedUser?.name ?? 'Assign',
                      onTap: _openAssignSheet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InlineField(
                      label: 'Process',
                      value: _process,
                      onTap: _openProcessPicker,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Description:', style: AppTextStyles.body),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Start writing about your idea...',
                  hintStyle: AppTextStyles.muted,
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.trim().length < 5
                    ? 'Unesi opis (min 5 karaktera).'
                    : null,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveIdea,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Sačuvaj'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAssignSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _AssignToSheet(
          service: _service,
          onSelected: (user) {
            setState(() => _assignedUser = user);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _openProcessPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _ProcessPicker(
          selected: _process,
          onSelected: (value) {
            setState(() => _process = value);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _InlineField extends StatelessWidget {
  const _InlineField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.muted),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.body,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignToSheet extends StatefulWidget {
  const _AssignToSheet({required this.service, required this.onSelected});

  final FirestoreService service;
  final ValueChanged<AppUser> onSelected;

  @override
  State<_AssignToSheet> createState() => _AssignToSheetState();
}

class _AssignToSheetState extends State<_AssignToSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Assign To', style: AppTextStyles.section),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: AppTextStyles.muted,
              filled: true,
              fillColor: AppColors.cardMuted,
              prefixIcon: const Icon(Icons.search, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<AppUser>>(
            stream: widget.service.watchUsers(),
            builder: (context, snapshot) {
              final users = snapshot.data ?? [];
              final filtered = users.where((user) {
                if (_query.isEmpty) return true;
                return user.name.toLowerCase().contains(_query.toLowerCase());
              }).toList();
              final list = filtered.isEmpty ? users : filtered;
              final currentUser = FirebaseAuth.instance.currentUser;
              final fallback = currentUser == null
                  ? <AppUser>[]
                  : [
                      AppUser(
                        uid: currentUser.uid,
                        name: currentUser.displayName ?? 'Korisnik',
                        photoUrl: '',
                        unreadNotificationsCount: 0,
                      ),
                    ];
              final displayUsers = list.isEmpty ? fallback : list;
              return ListView.separated(
                shrinkWrap: true,
                itemCount: displayUsers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = displayUsers[index];
                  return ListTile(
                    onTap: () => widget.onSelected(user),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.cardMuted,
                      child: Text(user.name.isEmpty ? '?' : user.name[0]),
                    ),
                    title: Text(user.name, style: AppTextStyles.body),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProcessPicker extends StatelessWidget {
  const _ProcessPicker({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  static const _options = <_ProcessOption>[
    _ProcessOption('idea', 'Idea', Color(0xFFE74C3C)),
    _ProcessOption('in_review', 'In Review', Color(0xFF6B7280)),
    _ProcessOption('approved', 'Approved', Color(0xFF22C55E)),
    _ProcessOption('in_progress', 'In Progress', Color(0xFF3B82F6)),
    _ProcessOption('done', 'Done', Color(0xFF14B8A6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _options.map((option) {
          final isSelected = option.value == selected;
          return GestureDetector(
            onTap: () => onSelected(option.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? option.color : AppColors.cardMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                option.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProcessOption {
  const _ProcessOption(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;
}

String _normalizeProcess(String raw) {
  final value = raw.trim().toLowerCase().replaceAll(' ', '_');
  switch (value) {
    case 'idea':
    case 'in_review':
    case 'approved':
    case 'in_progress':
    case 'done':
      return value;
    case 'inreview':
      return 'in_review';
    case 'inprogress':
      return 'in_progress';
    default:
      return 'idea';
  }
}
