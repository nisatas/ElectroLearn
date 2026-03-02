import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/colors.dart';
import '../../app/providers.dart';
import '../../domain/models/course.dart';
import '../../shared/widgets/arduino_robot_mascot.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseProvider);
    final progressAsync = ref.watch(progressNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'ElectroLearn',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.primary),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (course) {
          if (course == null || course.units.isEmpty) {
            return const Center(child: Text('İçerik yüklenemedi.'));
          }
          final skills = course.units.expand((u) => u.skills).toList();
          final completedIds =
              progressAsync.valueOrNull?.completedSkillIds ?? const [];
          final projectSkills = skills.length >= 1
              ? skills.sublist(skills.length - 1)
              : <Skill>[]; // Son beceri = proje (Trafik Lambası)
          final topicSkills = projectSkills.isEmpty
              ? skills
              : skills.sublist(0, skills.length - 1);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const ArduinoRobotMascot(
                      size: 52,
                      message: 'Arduino Robotu',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // —— Konular ——
                _SectionHeader(
                  icon: Icons.menu_book,
                  title: 'Konular',
                ),
                const SizedBox(height: 12),
                ...topicSkills.asMap().entries.map((e) {
                  final i = e.key;
                  final skill = e.value;
                  final isUnlocked = i == 0 ||
                      (i > 0 && completedIds.contains(topicSkills[i - 1].id));
                  final isCompleted = completedIds.contains(skill.id);
                  return _TopicCard(
                    index: i + 1,
                    skill: skill,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    onTap: isUnlocked
                        ? () => context.push('/lesson/${skill.id}')
                        : null,
                  );
                }),
                const SizedBox(height: 28),

                // —— Testler ——
                _SectionHeader(
                  icon: Icons.quiz,
                  title: 'Testler',
                ),
                const SizedBox(height: 12),
                ...skills.asMap().entries.map((e) {
                  final i = e.key;
                  final skill = e.value;
                  final isUnlocked = i == 0 ||
                      (i > 0 && completedIds.contains(skills[i - 1].id));
                  final isCompleted = completedIds.contains(skill.id);
                  return _TestTile(
                    index: i + 1,
                    title: skill.title,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    onTap: isUnlocked
                        ? () => context.push('/quiz/${skill.id}')
                        : null,
                  );
                }),
                const SizedBox(height: 28),

                // —— Projeler ——
                _SectionHeader(
                  icon: Icons.lightbulb_outline,
                  title: 'Projeler',
                ),
                const SizedBox(height: 12),
                if (projectSkills.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Henüz proje yok.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                    ),
                  )
                else
                  ...projectSkills.map((skill) {
                    final isUnlocked = skills.length <= 1 ||
                        completedIds.contains(skills[skills.length - 2].id);
                    final isCompleted = completedIds.contains(skill.id);
                    return _ProjectCard(
                      title: skill.title,
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      onTap: isUnlocked
                          ? () => context.push('/lesson/${skill.id}')
                          : null,
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.index,
    required this.skill,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
  });

  final int index;
  final Skill skill;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cards = skill.lessonCards;
    final hasSubheadings = cards.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isUnlocked ? Colors.white : AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        elevation: isUnlocked ? 2 : 0,
        shadowColor: AppColors.primary.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isCompleted
                          ? AppColors.primary
                          : isUnlocked
                              ? AppColors.accent
                              : AppColors.primary.withOpacity(0.3),
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 22)
                          : Text(
                              '$index',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked
                                    ? Colors.white
                                    : AppColors.primary.withOpacity(0.6),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index}. Konu',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            skill.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isUnlocked
                                      ? AppColors.primary
                                      : AppColors.primary.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (!isUnlocked)
                      Icon(Icons.lock, size: 20, color: AppColors.primary.withOpacity(0.5))
                    else
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.accent),
                  ],
                ),
              ),
            ),
            if (hasSubheadings) ...[
              Divider(height: 1, color: AppColors.primary.withOpacity(0.15)),
              ...cards.asMap().entries.map((e) {
                final subIndex = e.key + 1;
                final card = e.value;
                return InkWell(
                  onTap: onTap != null ? () => context.push('/lesson/${skill.id}') : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '$subIndex.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            card.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary.withOpacity(0.9),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _TestTile extends StatelessWidget {
  const _TestTile({
    required this.index,
    required this.title,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
  });

  final int index;
  final String title;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isUnlocked ? Colors.white : AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        elevation: isUnlocked ? 1 : 0,
        child: ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: isCompleted
                ? AppColors.primary
                : isUnlocked
                    ? AppColors.accent
                    : AppColors.primary.withOpacity(0.3),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? Colors.white
                          : AppColors.primary.withOpacity(0.6),
                    ),
                  ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isUnlocked
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
          ),
          trailing: isUnlocked
              ? const Icon(Icons.quiz, size: 20, color: AppColors.accent)
              : Icon(Icons.lock, size: 18, color: AppColors.primary.withOpacity(0.5)),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.title,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
  });

  final String title;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isUnlocked ? Colors.white : AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        elevation: isUnlocked ? 2 : 0,
        shadowColor: AppColors.accent.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.accentLight.withOpacity(0.3)
                        : AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    size: 32,
                    color: isUnlocked ? AppColors.accent : AppColors.primary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bölüm sonu projesi',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isUnlocked
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: Color(0xFF58CC02), size: 28)
                else if (!isUnlocked)
                  Icon(Icons.lock, size: 22, color: AppColors.primary.withOpacity(0.5))
                else
                  const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
