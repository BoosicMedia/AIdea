import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/models/idea_item.dart';
import '../models/idea_repository.dart';
import 'package:helloworld/widgets/labeled_field.dart';
import 'package:helloworld/widgets/primary_button.dart';

class CreateIdeaScreen extends StatefulWidget {
  const CreateIdeaScreen({super.key});

  static const routeName = '/ideas/new';

  @override
  State<CreateIdeaScreen> createState() => _CreateIdeaScreenState();
}

class _CreateIdeaScreenState extends State<CreateIdeaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _platformController = TextEditingController();
  final _contentTypeController = TextEditingController();
  final _hookController = TextEditingController();
  final _scriptController = TextEditingController();
  final _ctaController = TextEditingController();
  final _tagsController = TextEditingController();
  final _repository = IdeaRepository();

  String _status = 'draft';
  IdeaItem? _editingIdea;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _platformController.dispose();
    _contentTypeController.dispose();
    _hookController.dispose();
    _scriptController.dispose();
    _ctaController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is IdeaItem) {
      _editingIdea = args;
      _titleController.text = args.title;
      _platformController.text = args.platform ?? '';
      _contentTypeController.text = args.contentType ?? '';
      _hookController.text = args.hook ?? '';
      _scriptController.text = args.script ?? '';
      _ctaController.text = args.cta ?? '';
      _tagsController.text = args.tags.join(', ');
      _status = args.status;
    }
    _initialized = true;
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> _saveIdea() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final idea = IdeaItem(
      id: _editingIdea?.id ?? '',
      ownerId: uid,
      title: _titleController.text.trim(),
      platform: _platformController.text.trim(),
      contentType: _contentTypeController.text.trim(),
      hook: _hookController.text.trim(),
      script: _scriptController.text.trim(),
      cta: _ctaController.text.trim(),
      tags: _parseTags(_tagsController.text),
      status: _status,
      createdAt: _editingIdea?.createdAt,
      updatedAt: _editingIdea?.updatedAt,
    );
    if (_editingIdea == null) {
      await _repository.addIdea(idea);
    } else {
      await _repository.updateIdea(idea);
    }
    if (!mounted) return;
    Navigator.pop(context);
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
                  'New Idea...',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                LabeledField(
                  label: 'Naziv ideje',
                  controller: _titleController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Unesi naziv ideje'
                      : null,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Platforma',
                  controller: _platformController,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Tip sadržaja',
                  controller: _contentTypeController,
                ),
                const SizedBox(height: 16),
                LabeledField(label: 'Hook', controller: _hookController),
                const SizedBox(height: 16),
                LabeledField(label: 'Script', controller: _scriptController),
                const SizedBox(height: 16),
                LabeledField(label: 'CTA', controller: _ctaController),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Tags (tag1, tag2)',
                  controller: _tagsController,
                ),
                const SizedBox(height: 16),
                _DropdownField(
                  label: 'Status',
                  value: _status,
                  items: const ['draft', 'ready'],
                  onChanged: (value) =>
                      setState(() => _status = value ?? 'draft'),
                ),
                const Spacer(),
                Center(
                  child: PrimaryButton(
                    label: 'Sačuvaj ideju',
                    onTap: _saveIdea,
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
