import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class PlaceholderScreenScaffold extends StatelessWidget {
  const PlaceholderScreenScaffold({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MashiSpace.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: MashiSpace.compact),
              Text(message, style: Theme.of(context).textTheme.bodyLarge),
              if (actionLabel != null) ...[
                const Spacer(),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
