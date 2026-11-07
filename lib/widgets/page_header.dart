import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eyebrow.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF9A83F2),
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 8),
                Text(title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.8,
                        )),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
