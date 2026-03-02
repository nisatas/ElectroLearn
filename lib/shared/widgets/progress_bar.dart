import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
  });

  final double progress; // 0.0 .. 1.0
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
