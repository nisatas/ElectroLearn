import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/circuit_challenges_config.dart';
import '../../app/colors.dart';
import '../../app/providers.dart';
import '../../features/circuit/circuit_simulator_screen.dart';
import '../../shared/widgets/primary_button.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.xpEarned,
    this.skillId,
  });

  final int correct;
  final int total;
  final int xpEarned;
  final String? skillId;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _bonusCelebrationShown = false;

  @override
  Widget build(BuildContext context) {
    final pct = widget.total > 0 ? (widget.correct / widget.total * 100).round() : 0;
    final progressAsync = ref.watch(progressNotifierProvider);
    final contentRepo = ref.read(contentRepositoryProvider);
    final skill = widget.skillId != null ? contentRepo.getSkillById(widget.skillId!) : null;
    final miniTasks = skill?.miniTasks ?? [];
    final progress = progressAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.celebration, size: 72, color: Color(0xFF58CC02)),
              const SizedBox(height: 16),
              Text(
                'Tebrikler! Testi geçtin',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.correct} / ${widget.total} doğru ($pct%)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${widget.xpEarned} XP kazandın',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (miniTasks.isNotEmpty) ...[
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      'Şimdi bu görevleri yap!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Her birini yaptığında işaretle, hepsini bitirince bonus XP kazanırsın.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: miniTasks.length,
                    itemBuilder: (context, i) {
                      final key = '${widget.skillId}-$i';
                      final isDone = progress?.completedMiniTaskKeys.contains(key) ?? false;
                      final circuitChallenge = widget.skillId != null
                          ? getCircuitChallenge(widget.skillId!, i)
                          : null;
                      return _MiniTaskTile(
                        label: miniTasks[i],
                        isDone: isDone,
                        hasSimulation: circuitChallenge != null,
                        onTap: () => _toggleTask(i),
                        onSimulateTap: circuitChallenge != null
                            ? () => _openSimulator(context, circuitChallenge, i)
                            : null,
                      );
                    },
                  ),
                ),
                if (progress != null && _allTasksDone(progress))
                  _BonusBanner(onShown: _giveBonusAndCelebrate),
                const SizedBox(height: 12),
              ] else
                const Spacer(),
              PrimaryButton(
                label: 'Ana ekrana dön',
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  bool _allTasksDone(dynamic progress) {
    final skill = widget.skillId != null
        ? ref.read(contentRepositoryProvider).getSkillById(widget.skillId!)
        : null;
    final tasks = skill?.miniTasks ?? [];
    if (tasks.isEmpty) return false;
    for (int i = 0; i < tasks.length; i++) {
      if (!progress.completedMiniTaskKeys.contains('${widget.skillId}-$i')) return false;
    }
    return true;
  }

  Future<void> _toggleTask(int index) async {
    if (widget.skillId == null) return;
    await ref.read(progressNotifierProvider.notifier).toggleMiniTask(widget.skillId!, index);
    final progress = ref.read(progressNotifierProvider).valueOrNull;
    final skill = ref.read(contentRepositoryProvider).getSkillById(widget.skillId!);
    final taskCount = skill?.miniTasks.length ?? 0;
    if (progress != null && taskCount > 0) {
      int done = 0;
      for (int i = 0; i < taskCount; i++) {
        if (progress.completedMiniTaskKeys.contains('${widget.skillId}-$i')) done++;
      }
      if (done == taskCount && !_bonusCelebrationShown) {
        _giveBonusAndCelebrate();
      }
    }
  }

  Future<void> _giveBonusAndCelebrate() async {
    if (widget.skillId == null || _bonusCelebrationShown) return;
    final skill = ref.read(contentRepositoryProvider).getSkillById(widget.skillId!);
    final count = skill?.miniTasks.length ?? 0;
    final bonus = await ref.read(progressNotifierProvider.notifier).maybeGiveMiniTasksBonus(
          widget.skillId!,
          count,
        );
    if (mounted && bonus > 0) {
      setState(() => _bonusCelebrationShown = true);
    }
  }

  Future<void> _openSimulator(BuildContext context, dynamic challenge, int taskIndex) async {
    if (widget.skillId == null) return;
    final skillId = widget.skillId!;
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CircuitSimulatorScreen(
          challenge: challenge,
          onComplete: () async {
            await ref.read(progressNotifierProvider.notifier).completeMiniTask(skillId, taskIndex);
            final progress = ref.read(progressNotifierProvider).valueOrNull;
            final skill = ref.read(contentRepositoryProvider).getSkillById(skillId);
            final taskCount = skill?.miniTasks.length ?? 0;
            if (progress != null && taskCount > 0) {
              int done = 0;
              for (int i = 0; i < taskCount; i++) {
                if (progress.completedMiniTaskKeys.contains('$skillId-$i')) done++;
              }
              if (done == taskCount) await _giveBonusAndCelebrate();
            }
          },
        ),
      ),
    );
    if (completed == true && mounted) setState(() {});
  }
}

class _MiniTaskTile extends StatelessWidget {
  const _MiniTaskTile({
    required this.label,
    required this.isDone,
    required this.hasSimulation,
    required this.onTap,
    this.onSimulateTap,
  });

  final String label;
  final bool isDone;
  final bool hasSimulation;
  final VoidCallback onTap;
  final VoidCallback? onSimulateTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (!hasSimulation)
                    GestureDetector(
                      onTap: onTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDone ? const Color(0xFF58CC02) : AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone ? const Color(0xFF58CC02) : AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: isDone
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
                      ),
                    )
                  else
                    Icon(
                      isDone ? Icons.check_circle : Icons.cable,
                      color: isDone ? const Color(0xFF58CC02) : AppColors.accent,
                      size: 28,
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDone ? AppColors.primary.withOpacity(0.7) : AppColors.primary,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                    ),
                  ),
                ],
              ),
              if (hasSimulation && onSimulateTap != null && !isDone) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onSimulateTap,
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text('Devreyi kur (simülasyon)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ] else if (hasSimulation && isDone)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Simülasyonda tamamlandı',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF58CC02),
                        ),
                  ),
                )
              else if (!hasSimulation)
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BonusBanner extends StatefulWidget {
  const _BonusBanner({required this.onShown});

  final VoidCallback onShown;

  @override
  State<_BonusBanner> createState() => _BonusBannerState();
}

class _BonusBannerState extends State<_BonusBanner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onShown());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF58CC02).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF58CC02), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Color(0xFF58CC02), size: 28),
          const SizedBox(width: 10),
          Text(
            'Tüm görevleri tamamladın! +15 bonus XP',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
