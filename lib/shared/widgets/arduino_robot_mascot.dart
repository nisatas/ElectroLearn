import 'package:flutter/material.dart';

import '../../app/colors.dart';

/// 🤖 "Arduino Robotu" maskotu - ana sayfa ve derslerde gösterilir.
class ArduinoRobotMascot extends StatelessWidget {
  const ArduinoRobotMascot({
    super.key,
    this.message,
    this.size = 64,
  });

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '🤖',
              style: TextStyle(fontSize: size * 0.55),
            ),
          ),
        ),
        if (message != null && message!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
