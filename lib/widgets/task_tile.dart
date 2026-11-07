import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../screens/task_form_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  Color get priorityColor {
    switch (task.priority) {
      case 'High': return AppTheme.coral;
      case 'Medium': return AppTheme.amber;
      default: return AppTheme.mint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: AppTheme.purple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            onChanged: (value) => app.setStatus(
                task, value == true ? 'Completed' : 'Pending'),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? muted : null,
                      )),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(task.category,
                          style: TextStyle(fontSize: 11, color: muted)),
                      _dot(priorityColor),
                      Text('${task.priority} priority',
                          style: TextStyle(fontSize: 11, color: priorityColor)),
                      Text(DateFormat('d MMM').format(task.dueDate),
                          style: TextStyle(fontSize: 11, color: muted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)));
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete task?'),
                    content: Text('“${task.title}” will be removed.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) await app.deleteTask(task.id);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 5, height: 5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
