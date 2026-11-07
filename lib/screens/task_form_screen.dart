import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  String _category = 'Personal';
  String _priority = 'Medium';
  String _status = 'Pending';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;

  final _categories = const ['Personal', 'Academics', 'Work', 'Health', 'Finance', 'Other'];
  final _priorities = const ['Low', 'Medium', 'High'];
  final _statuses = const ['Pending', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    if (task != null) {
      _category = task.category;
      _priority = task.priority;
      _status = task.status;
      _dueDate = task.dueDate;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(DateTime.now()) ? DateTime.now() : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<AppProvider>();
    final task = Task(
      id: widget.task?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category,
      priority: _priority,
      status: _status,
      dueDate: _dueDate,
      createdAt: widget.task?.createdAt,
    );
    if (widget.task == null) {
      await provider.addTask(task);
    } else {
      await provider.updateTask(task);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit task' : 'Create a task'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.purple.withOpacity(.22),
                        Theme.of(context).cardColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.purple.withOpacity(.2)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.edit_note_rounded,
                          color: AppTheme.purpleSoft, size: 30),
                      SizedBox(height: 12),
                      Text('Make it happen.',
                          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                      SizedBox(height: 5),
                      Text('Give your next step a name, a place and a deadline.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _label('TASK TITLE'),
                TextFormField(
                  controller: _title,
                  autofocus: !editing,
                  decoration: const InputDecoration(hintText: 'e.g. Finish project proposal'),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Enter a title with at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _label('DESCRIPTION'),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Add a few details (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 18),
                _label('CATEGORY'),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(),
                  items: _categories.map((e) =>
                    DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 18),
                _label('PRIORITY'),
                Wrap(
                  spacing: 9,
                  children: _priorities.map((p) => ChoiceChip(
                    label: Text(p),
                    selected: _priority == p,
                    onSelected: (_) => setState(() => _priority = p),
                  )).toList(),
                ),
                const SizedBox(height: 18),
                _label('STATUS'),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(),
                  items: _statuses.map((e) =>
                    DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 18),
                _label('DUE DATE'),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(
                    '${_dueDate.day.toString().padLeft(2, '0')}/'
                    '${_dueDate.month.toString().padLeft(2, '0')}/'
                    '${_dueDate.year}',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(17),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(_saving ? 'Saving...' : editing ? 'Save changes' : 'Add to my tasks'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(text, style: const TextStyle(
      fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800,
      color: AppTheme.purpleSoft)),
  );
}
