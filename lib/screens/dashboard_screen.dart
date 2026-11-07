import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_tile.dart';
import 'task_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 650;
    final today = DateTime.now();
    final upcoming = app.tasks.where((t) => !t.isCompleted).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(compact ? 18 : 34, 28, compact ? 18 : 34, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            eyebrow: DateFormat('EEEE, d MMMM yyyy').format(today),
            title: 'Your day, your pace.',
            subtitle: 'A little progress every day adds up.',
            trailing: compact ? null : FilledButton.icon(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TaskFormScreen())),
              icon: const Icon(Icons.add), label: const Text('Add a task'),
            ),
          ),
          _heroCard(context, app),
          const SizedBox(height: 22),
          LayoutBuilder(builder: (context, constraints) {
            final count = constraints.maxWidth > 900 ? 4 : 2;
            final stats = [
              _Metric('All tasks', app.total, Icons.layers_rounded, AppTheme.purpleSoft),
              _Metric('Completed', app.completed, Icons.check_circle_rounded, AppTheme.mint),
              _Metric('In progress', app.inProgress, Icons.timelapse_rounded, AppTheme.amber),
              _Metric('Overdue', app.overdue, Icons.alarm_rounded, AppTheme.coral),
            ];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 112,
              ),
              itemBuilder: (_, i) => _metricCard(context, stats[i]),
            );
          }),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text('Coming up next',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800)),
              ),
              Text('${upcoming.length} active',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          if (upcoming.isEmpty)
            EmptyState(
              title: app.total == 0 ? 'A clean slate.' : 'You’re all caught up!',
              message: app.total == 0
                  ? 'Add your first task and turn that blank space into a plan.'
                  : 'Nothing left on your active list. Enjoy the breathing room.',
              onAction: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TaskFormScreen())),
              actionLabel: 'Create your first task',
            )
          else
            ...upcoming.take(5).map((task) => TaskTile(task: task)),
          if (app.total > 0) ...[
            const SizedBox(height: 20),
            _progressPanel(context, app),
          ],
        ],
      ),
    );
  }

  Widget _heroCard(BuildContext context, AppProvider app) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? const [Color(0xFF39305F), Color(0xFF24223C), Color(0xFF1D2638)]
              : const [Color(0xFFE5DFFF), Color(0xFFF0EAFE), Color(0xFFE2F4F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.purple.withOpacity(.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR PERSONAL WORKSPACE',
                    style: TextStyle(
                      color: dark ? AppTheme.purpleSoft : AppTheme.purple,
                      fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(
                  app.total == 0 ? 'Make room for\nwhat matters.' : 'Keep your\nmomentum going.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900, height: 1.08, letterSpacing: -.8),
                ),
                const SizedBox(height: 10),
                Text(
                  app.total == 0
                      ? 'Start with one small task. You’ve got this.'
                      : '${app.completed} of ${app.total} tasks completed. Keep going!',
                  style: TextStyle(color: dark ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90, height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: app.completionRate,
                  strokeWidth: 8,
                  backgroundColor: (dark ? Colors.white : Colors.black).withOpacity(.10),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.mint),
                ),
                Text('${(app.completionRate * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(BuildContext context, _Metric metric) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: metric.color.withOpacity(.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(metric.icon, color: metric.color, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${metric.value}',
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                Text(metric.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressPanel(BuildContext context, AppProvider app) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your progress', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: app.completionRate,
              minHeight: 9,
              backgroundColor: AppTheme.purple.withOpacity(.13),
              color: AppTheme.mint,
            ),
          ),
          const SizedBox(height: 9),
          Text('${app.completed} completed · ${app.pending + app.inProgress} still in motion',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Metric {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _Metric(this.label, this.value, this.icon, this.color);
}
