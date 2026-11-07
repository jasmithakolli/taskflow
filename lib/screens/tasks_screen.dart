import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_tile.dart';
import 'task_form_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _search = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final query = _search.text.toLowerCase();
    final List<Task> filtered = app.tasks.where((task) {
      final matchesText = task.title.toLowerCase().contains(query) ||
          task.category.toLowerCase().contains(query);
      final matchesFilter = _filter == 'All' ||
          (_filter == 'Active' && !task.isCompleted) ||
          (_filter == 'Completed' && task.isCompleted) ||
          task.priority == _filter;
      return matchesText && matchesFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            eyebrow: 'YOUR WORKSPACE',
            title: 'My tasks',
            subtitle: 'Keep every little thing moving forward.',
            trailing: IconButton.filledTonal(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TaskFormScreen())),
              icon: const Icon(Icons.add),
            ),
          ),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search tasks or categories',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Active', 'Completed', 'High', 'Medium', 'Low']
                  .map((filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  )).toList(),
            ),
          ),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            EmptyState(
              title: app.total == 0 ? 'Nothing on the list yet' : 'No matching tasks',
              message: app.total == 0
                  ? 'Create a task to start building your personal workflow.'
                  : 'Try another search or switch your filter.',
              onAction: app.total == 0
                  ? () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TaskFormScreen()))
                  : null,
            )
          else ...[
            Text('${filtered.length} TASK${filtered.length == 1 ? '' : 'S'}',
                style: const TextStyle(
                  color: Colors.grey, fontSize: 10,
                  letterSpacing: 1.7, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...filtered.map((task) => TaskTile(task: task)),
          ],
        ],
      ),
    );
  }
}
