import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Explicit placeholder. No fake backend or unfinished feature UI is shipped.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.feature});
  final String feature;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TouRathi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_outlined, size: 64, color: colors.primary),
              const SizedBox(height: 20),
              Text(feature,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              const Text(
                'Coming soon — this feature has not been built yet.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Back to TouRathi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
