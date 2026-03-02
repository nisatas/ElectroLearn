import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/badges_config.dart';
import '../../app/colors.dart';
import '../../app/providers.dart';
import '../../domain/models/course.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static int _levelFromXp(int xp) {
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    if (xp < 2500) return 6;
    if (xp < 4000) return 7;
    if (xp < 6000) return 8;
    if (xp < 10000) return 9;
    return 10 + (xp ~/ 5000);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressNotifierProvider);
    final courseAsync = ref.watch(courseProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (progress) {
          final level = _levelFromXp(progress.totalXp);
          final completedIds = progress.completedSkillIds;
          final skillTitles = courseAsync.valueOrNull != null
              ? _completedSkillTitles(courseAsync.valueOrNull!, completedIds)
              : <String>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileHeader(
                  email: user?.email ?? 'Misafir',
                  level: level,
                  totalXp: progress.totalXp,
                ),
                const SizedBox(height: 24),
                Text(
                  'İstatistikler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star,
                        label: 'Toplam XP',
                        value: '${progress.totalXp}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        label: 'Seri (gün)',
                        value: '${progress.streakDays}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        label: 'Tamamlanan',
                        value: '${completedIds.length} beceri',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.calendar_today,
                        label: 'Son aktivite',
                        value: progress.lastActiveDate != null
                            ? _formatDate(progress.lastActiveDate!)
                            : '-',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Rozetler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: unit1Badges.map((badge) {
                    final unlocked = completedIds.contains(badge.skillId);
                    return Tooltip(
                      message: unlocked ? badge.title : '${badge.title} (kilidi açılmadı)',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: unlocked
                                  ? AppColors.primary.withOpacity(0.12)
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: unlocked ? AppColors.accent : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                badge.emoji,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: unlocked ? null : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 72,
                            child: Text(
                              badge.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: unlocked ? AppColors.primary : Colors.grey,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (skillTitles.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Tamamlanan konular',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...skillTitles.map(
                    (title) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Hesap',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.auth.signOut();
                    } catch (_) {}
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Çıkış yap'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _completedSkillTitles(Course course, List<String> completedIds) {
    final titles = <String>[];
    for (final unit in course.units) {
      for (final skill in unit.skills) {
        if (completedIds.contains(skill.id)) {
          titles.add(skill.title);
        }
      }
    }
    return titles;
  }

  String _formatDate(String iso) {
    try {
      final parts = iso.split('-');
      if (parts.length >= 3) {
        return '${parts[2]}.${parts[1]}.${parts[0]}';
      }
    } catch (_) {}
    return iso;
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.email,
    required this.level,
    required this.totalXp,
  });

  final String email;
  final int level;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.accent.withOpacity(0.3),
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Seviye $level',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$totalXp XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: AppColors.accent),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary.withOpacity(0.8),
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
