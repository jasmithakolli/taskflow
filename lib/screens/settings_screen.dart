import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dark = app.themeMode == ThemeMode.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            eyebrow: 'MAKE IT YOURS',
            title: 'Settings',
            subtitle: 'Set up your workspace the way you like it.',
          ),
          _section(context, 'APPEARANCE', [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _icon(Icons.palette_outlined),
              title: const Text('Appearance'),
              subtitle: Text(dark ? 'Dark theme' : 'Light theme'),
              trailing: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, icon: Icon(Icons.dark_mode_outlined)),
                  ButtonSegment(value: false, icon: Icon(Icons.light_mode_outlined)),
                ],
                selected: {dark},
                onSelectionChanged: (selection) =>
                    app.toggleTheme(selection.first),
                showSelectedIcon: false,
              ),
            ),
          ]),
          const SizedBox(height: 18),
          _section(context, 'WORKSPACE', [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _icon(Icons.person_outline),
              title: const Text('Display name'),
              subtitle: Text(app.profileName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editName(context, app),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _icon(Icons.cleaning_services_outlined),
              title: const Text('Clear completed tasks'),
              subtitle: const Text('Remove tasks you have already finished'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _confirmClear(context, app),
            ),
          ]),
          const SizedBox(height: 18),
          _section(context, 'ABOUT', [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.bolt_rounded, color: AppTheme.purple),
              title: Text('TaskFlow'),
              subtitle: Text('Personal productivity, made calmer.'),
              trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
            ),
            const Divider(),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.storage_outlined, color: AppTheme.purple),
              title: Text('Your data stays on this device'),
              subtitle: Text('Tasks are saved locally in this browser.'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            color: AppTheme.purpleSoft, fontSize: 10,
            letterSpacing: 1.7, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _icon(IconData icon) => Container(
    width: 40, height: 40,
    decoration: BoxDecoration(
      color: AppTheme.purple.withOpacity(.13),
      borderRadius: BorderRadius.circular(12)),
    child: Icon(icon, color: AppTheme.purpleSoft),
  );

  Future<void> _editName(BuildContext context, AppProvider app) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialName: app.profileName),
    );
    if (name != null && name.trim().isNotEmpty) {
      await app.updateProfile(name);
    }
  }

  Future<void> _confirmClear(BuildContext context, AppProvider app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear completed tasks?'),
        content: const Text('This permanently removes all completed tasks from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear tasks')),
        ],
      ),
    );
    if (confirm == true) await app.clearCompleted();
  }
}


class _EditNameDialog extends StatefulWidget {
  final String initialName;

  const _EditNameDialog({required this.initialName});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Display name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) => _save(),
        decoration: const InputDecoration(hintText: 'Your name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
