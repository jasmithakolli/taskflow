import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import 'task_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = DateTime.now();

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Task> _tasksForDate(List<Task> tasks, DateTime date) {
    final result = tasks.where((task) => _sameDate(task.dueDate, date)).toList();
    result.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      const order = {'High': 0, 'Medium': 1, 'Low': 2};
      return (order[a.priority] ?? 3).compareTo(order[b.priority] ?? 3);
    });
    return result;
  }

  Color _eventColor(Task task, bool dark) {
    if (task.isCompleted) return const Color(0xFF4B9B73);
    switch (task.priority) {
      case 'High': return const Color(0xFFE17C68);
      case 'Medium': return const Color(0xFFC18A35);
      default: return AppTheme.purple;
    }
  }

  void _openTask(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final cells = ((firstWeekday + days + 6) ~/ 7) * 7;
    final selectedTasks = _tasksForDate(app.tasks, _selected);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 600;
    final cellHeight = compact ? 83.0 : width < 1000 ? 94.0 : 112.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 26, 24, compact ? 14 : 26, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            eyebrow: 'PLAN AHEAD',
            title: 'Calendar',
            subtitle: 'Your deadlines and plans, right where they belong.',
          ),
          Container(
            padding: EdgeInsets.all(compact ? 10 : 18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Previous month',
                      onPressed: () => setState(() =>
                          _month = DateTime(_month.year, _month.month - 1)),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Text(DateFormat('MMMM yyyy').format(_month),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                    ),
                    IconButton(
                      tooltip: 'Next month',
                      onPressed: () => setState(() =>
                          _month = DateTime(_month.year, _month.month + 1)),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                    if (!_sameDate(_month, DateTime.now()))
                      TextButton(
                        onPressed: () => setState(() {
                          _month = DateTime(DateTime.now().year, DateTime.now().month);
                          _selected = DateTime.now();
                        }),
                        child: const Text('Today'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                      .map((day) => Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(day,
                                  style: TextStyle(color: Theme.of(context).hintColor,
                                    fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          )).toList(),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final gap = compact ? 3.0 : 6.0;
                    final cellWidth = (constraints.maxWidth - gap * 6) / 7;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cells,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: gap,
                        crossAxisSpacing: gap,
                        mainAxisExtent: cellHeight,
                      ),
                      itemBuilder: (context, index) {
                        final day = index - firstWeekday + 1;
                        if (day < 1 || day > days) return const SizedBox();
                        final date = DateTime(_month.year, _month.month, day);
                        final dateTasks = _tasksForDate(app.tasks, date);
                        final selected = _sameDate(date, _selected);
                        final today = _sameDate(date, DateTime.now());
                        final visibleCount = compact ? 2 : 3;
                        final shownTasks = dateTasks.take(visibleCount).toList();
                        final extra = dateTasks.length - shownTasks.length;

                        return Material(
                          color: selected
                              ? AppTheme.purple.withOpacity(dark ? .24 : .10)
                              : today
                                  ? AppTheme.purple.withOpacity(.07)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(11),
                            onTap: () => setState(() => _selected = date),
                            child: Container(
                              width: cellWidth,
                              padding: EdgeInsets.all(compact ? 4 : 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.purple
                                      : today
                                          ? AppTheme.purple.withOpacity(.35)
                                          : Theme.of(context).dividerColor,
                                  width: selected ? 1.5 : 0.7,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: compact ? 21 : 24,
                                      height: compact ? 21 : 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: selected ? AppTheme.purple : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text('$day',
                                        style: TextStyle(
                                          fontSize: compact ? 10 : 12,
                                          fontWeight: selected || today
                                              ? FontWeight.w800 : FontWeight.w500,
                                          color: selected ? Colors.white : null,
                                        )),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  ...shownTasks.map((task) => Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: _EventLabel(
                                      title: task.title,
                                      color: _eventColor(task, dark),
                                      compact: compact,
                                      completed: task.isCompleted,
                                      onTap: () => _openTask(task),
                                    ),
                                  )),
                                  if (extra > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: Text('+$extra more',
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: compact ? 8 : 9,
                                          color: Theme.of(context).hintColor,
                                          fontWeight: FontWeight.w700,
                                        )),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: const [
                    _CalendarLegend(color: AppTheme.purple, label: 'Low'),
                    _CalendarLegend(color: Color(0xFFC18A35), label: 'Medium'),
                    _CalendarLegend(color: Color(0xFFE17C68), label: 'High'),
                    _CalendarLegend(color: Color(0xFF4B9B73), label: 'Completed'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('EEEE').format(_selected).toUpperCase(),
                      style: TextStyle(fontSize: 10, letterSpacing: 1.5,
                        fontWeight: FontWeight.w800, color: Theme.of(context).hintColor)),
                    const SizedBox(height: 3),
                    Text(DateFormat('d MMMM yyyy').format(_selected),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Text('${selectedTasks.length} ${selectedTasks.length == 1 ? 'task' : 'tasks'}',
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 13),
          if (selectedTasks.isEmpty)
            const EmptyState(
              title: 'Nothing planned here',
              message: 'This day is open. Add a task whenever you need to.',
            )
          else
            ...selectedTasks.map((task) => _AgendaTask(
              task: task,
              color: _eventColor(task, dark),
              onTap: () => _openTask(task),
            )),
        ],
      ),
    );
  }
}

class _EventLabel extends StatelessWidget {
  final String title;
  final Color color;
  final bool compact;
  final bool completed;
  final VoidCallback onTap;

  const _EventLabel({
    required this.title,
    required this.color,
    required this.compact,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 5, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(.17),
          borderRadius: BorderRadius.circular(4),
          border: Border(left: BorderSide(color: color, width: 2)),
        ),
        child: Text(title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 7.5 : 9,
            height: 1.1,
            color: color,
            fontWeight: FontWeight.w700,
            decoration: completed ? TextDecoration.lineThrough : null,
          )),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _CalendarLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 7, height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
    ],
  );
}

class _AgendaTask extends StatelessWidget {
  final Task task;
  final Color color;
  final VoidCallback onTap;

  const _AgendaTask({required this.task, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).hintColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(width: 4, height: 43,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(task.title,
                    style: TextStyle(fontWeight: FontWeight.w700,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                  const SizedBox(height: 5),
                  Text('${task.category}  ·  ${task.priority} priority  ·  ${task.status}',
                    style: TextStyle(fontSize: 11, color: muted)),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
