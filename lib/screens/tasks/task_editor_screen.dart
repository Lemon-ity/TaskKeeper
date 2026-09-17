import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';

class TaskEditorScreen extends StatefulWidget {
  final Task? task;

  const TaskEditorScreen({super.key, this.task});

  bool get isEditing => task != null;

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title ?? '');
    _description = TextEditingController(text: widget.task?.description ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TaskProvider>();
    final success = widget.isEditing
        ? await provider.updateTask(
            widget.task!,
            _title.text,
            _description.text,
          )
        : await provider.createTask(
            _title.text,
            _description.text,
          );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Unable to save task.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _title,
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: !widget.isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. Complete Flutter assignment',
                        prefixIcon: Icon(Icons.title_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _description,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 6,
                      minLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Add details about this task (optional)',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: provider.loading ? null : _save,
                      icon: provider.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(widget.isEditing ? 'Update Task' : 'Save Task'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
