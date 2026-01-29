import 'package:flutter/material.dart';

import 'package:helloworld/models/todo_entry.dart';
import 'package:helloworld/widgets/labeled_field.dart';
import 'package:helloworld/widgets/primary_button.dart';

class CreateTodoScreen extends StatefulWidget {
  const CreateTodoScreen({super.key});

  static const routeName = '/todos/new';

  @override
  State<CreateTodoScreen> createState() => _CreateTodoScreenState();
}

class _CreateTodoScreenState extends State<CreateTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  String _assignedTo = 'AIdea';
  String _status = 'U toku';

  final List<String> _statusOptions = ['U toku', 'Na čekanju', 'Završeno'];

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}.';
  }

  void _saveTodo() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final dueDate = _selectedDate ?? DateTime.now();
    final todo = TodoEntry(
      title: _titleController.text.trim(),
      time: _dateController.text.trim(),
      completed: _status == 'Završeno',
      dueDate: dueDate,
      assignedTo: _assignedTo,
      status: _status,
      description: _descriptionController.text.trim(),
    );
    Navigator.pop(context, todo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New To - Do',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                LabeledField(
                  label: 'Naziv zadatka',
                  controller: _titleController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Unesi naziv'
                      : null,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Due Date',
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Odaberi datum'
                      : null,
                ),
                const SizedBox(height: 16),
                _DropdownField(
                  label: 'Assign To',
                  value: _assignedTo,
                  items: const ['AIdea', 'Marketing', 'Content', 'Design'],
                  onChanged: (value) =>
                      setState(() => _assignedTo = value ?? 'AIdea'),
                ),
                const SizedBox(height: 16),
                _DropdownField(
                  label: 'Status',
                  value: _status,
                  items: _statusOptions,
                  onChanged: (value) =>
                      setState(() => _status = value ?? 'U toku'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Unesi opis'
                      : null,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF241833),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: PrimaryButton(
                    label: 'Sačuvaj zadatak',
                    onTap: _saveTodo,
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

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(value),
          initialValue: value,
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF241833),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
