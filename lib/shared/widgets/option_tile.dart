import 'package:flutter/material.dart';

enum OptionState { idle, correct, wrong, disabled }

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? bg;
    IconData? icon;
    if (state == OptionState.correct) {
      bg = const Color(0xFF58CC02);
      icon = Icons.check_circle;
    } else if (state == OptionState.wrong) {
      bg = const Color(0xFFFF4B4B);
      icon = Icons.cancel;
    } else if (state == OptionState.disabled) {
      bg = theme.colorScheme.surfaceContainerHighest;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bg ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: state == OptionState.idle ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                if (icon != null)
                  Icon(icon, color: Colors.white, size: 24),
                if (icon != null) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: state == OptionState.idle
                          ? theme.colorScheme.onSurface
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
