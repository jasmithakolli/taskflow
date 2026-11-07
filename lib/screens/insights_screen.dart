import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final categories = <String, int>{};
    for (final task in app.tasks) {
      categories[task.category] = (categories[task.category] ?? 0) + 1;
    }
    final maxValue = categories.values.isEmpty
        ? 1 : categories.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            eyebrow: 'YOUR MOMENTUM',
            title: 'Insights',
            subtitle: 'A clearer picture of how you spend your focus.',
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A315F), Color(0xFF24233B)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('COMPLETION RATE',
                        style: TextStyle(color: AppTheme.purpleSoft,
                          fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text('${(app.completionRate * 100).round()}%',
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900,
                          color: Colors.white)),
                      const Text('of your tasks are complete',
                        style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 94, height: 94,
                  child: CircularProgressIndicator(
                    value: app.completionRate, strokeWidth: 10,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.mint),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 600;
            final cards = [
              _InsightMetric('Total created', app.total, AppTheme.purpleSoft),
              _InsightMetric('Completed', app.completed, AppTheme.mint),
              _InsightMetric('In progress', app.inProgress, AppTheme.amber),
              _InsightMetric('Overdue', app.overdue, AppTheme.coral),
            ];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: wide ? 4 : 2,
                mainAxisExtent: 105, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemBuilder: (_, i) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Theme.of(context).dividerColor)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${cards[i].value}',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900,
                        color: cards[i].color)),
                    Text(cards[i].label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 28),
          Text('Tasks by category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          if (categories.isEmpty)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18)),
              child: const Text('Your category breakdown will appear once you add tasks.',
                style: TextStyle(color: Colors.grey)),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).dividerColor)),
              child: Column(
                children: categories.entries.map((entry) {
                  final fraction = entry.value / maxValue;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 17),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w600))),
                            Text('${entry.value}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: fraction, minHeight: 8,
                            backgroundColor: AppTheme.purple.withOpacity(.12),
                            color: AppTheme.purple),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _InsightMetric {
  final String label;
  final int value;
  final Color color;
  const _InsightMetric(this.label, this.value, this.color);
}
