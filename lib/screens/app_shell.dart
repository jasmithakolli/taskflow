
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'calendar_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';
import 'task_form_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    TasksScreen(),
    CalendarScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  final List<_NavItem> _destinations = const [
    _NavItem('Overview', Icons.grid_view_rounded),
    _NavItem('My tasks', Icons.checklist_rounded),
    _NavItem('Calendar', Icons.calendar_month_rounded),
    _NavItem('Insights', Icons.auto_graph_rounded),
    _NavItem('Settings', Icons.tune_rounded),
  ];

  void _addTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TaskFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 920;
    final app = context.watch<AppProvider>();

    if (!app.isReady) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          if (wide) _sidebar(context),
          Expanded(
            child: _pages[_selected],
          ),
        ],
      ),

      floatingActionButton: wide || _selected == 4
          ? null
          : FloatingActionButton.extended(
              onPressed: _addTask,
              backgroundColor: AppTheme.purple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add task'),
            ),

      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selected,
              onDestinationSelected: (index) {
                setState(() {
                  _selected = index;
                });
              },
              destinations: _destinations.map((item) {
                return NavigationDestination(
                  icon: Icon(item.icon),
                  label: item.label,
                );
              }).toList(),
            ),
    );
  }

  Widget _sidebar(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Container(
      width: 248,
      padding: const EdgeInsets.fromLTRB(20, 28, 16, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TaskFlow Logo
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.purple,
                      Color(0xFFB19BFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'taskflow',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 42),

          // Navigation Heading
          const Padding(
            padding: EdgeInsets.only(
              left: 12,
              bottom: 12,
            ),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.8,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Navigation Items
          ...List.generate(_destinations.length, (index) {
            final item = _destinations[index];
            final active = _selected == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                selected: active,
                selectedTileColor: AppTheme.purple.withOpacity(.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                leading: Icon(
                  item.icon,
                  color: active ? AppTheme.purpleSoft : null,
                  size: 21,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: active ? AppTheme.purpleSoft : null,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selected = index;
                  });
                },
                dense: true,
              ),
            );
          }),

          const Spacer(),

          // Profile Section
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.purple.withOpacity(.2),
              child: const Icon(
                Icons.person_outline,
                color: AppTheme.purpleSoft,
              ),
            ),
            title: Text(
              app.profileName,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text('Personal workspace'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem(this.label, this.icon);
}
