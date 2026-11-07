import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AppProvider>().completeSetup(_nameController.text);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your name. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF11101C), Color(0xFF211B38), Color(0xFF121923)]
                : const [Color(0xFFF8F6FF), Color(0xFFEAE4FF), Color(0xFFEAF7F3)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  padding: EdgeInsets.all(width < 420 ? 24 : 34),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(.94),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.purple.withOpacity(.2)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.purple.withOpacity(dark ? .12 : .10),
                        blurRadius: 45,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.purple, Color(0xFFB5A2FF)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 27),
                            ),
                            const SizedBox(width: 12),
                            const Text('taskflow', style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                          ],
                        ),
                        const SizedBox(height: 42),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppTheme.purple.withOpacity(.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text('YOUR PERSONAL SPACE', style: TextStyle(
                            color: AppTheme.purpleSoft, fontSize: 10,
                            letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 18),
                        Text('Let’s make this\nspace yours.',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900, height: 1.08, letterSpacing: -1.1)),
                        const SizedBox(height: 12),
                        Text('A fresh space for your goals, plans and everyday progress.',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            height: 1.55, fontSize: 14)),
                        const SizedBox(height: 30),
                        const Text('What should we call you?',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _nameController,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _continue(),
                          decoration: const InputDecoration(
                            hintText: 'Enter your name',
                            prefixIcon: Icon(Icons.person_outline_rounded)),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Please enter your name';
                            if (value.trim().length < 2) return 'Name must be at least 2 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _saving ? null : _continue,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: _saving
                                ? const SizedBox(width: 19, height: 19,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Let’s get started'),
                                      SizedBox(width: 9),
                                      Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text('No account needed · Your details stay on this device',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
