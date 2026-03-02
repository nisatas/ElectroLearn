class UserProgress {
  const UserProgress({
    this.totalXp = 0,
    this.streakDays = 0,
    this.lastActiveDate,
    this.completedSkillIds = const [],
    this.completedMiniTaskKeys = const [],
    this.miniTaskBonusGivenForSkillIds = const [],
  });

  final int totalXp;
  final int streakDays;
  final String? lastActiveDate; // ISO date "2025-02-25"
  final List<String> completedSkillIds;
  /// Mini görev tamamlama anahtarları: "skillId-index" (örn. "skill-led-0")
  final List<String> completedMiniTaskKeys;
  /// Bu beceriler için "tüm mini görevler" bonusu zaten verildi
  final List<String> miniTaskBonusGivenForSkillIds;

  UserProgress copyWith({
    int? totalXp,
    int? streakDays,
    String? lastActiveDate,
    List<String>? completedSkillIds,
    List<String>? completedMiniTaskKeys,
    List<String>? miniTaskBonusGivenForSkillIds,
  }) {
    return UserProgress(
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      completedSkillIds: completedSkillIds ?? this.completedSkillIds,
      completedMiniTaskKeys: completedMiniTaskKeys ?? this.completedMiniTaskKeys,
      miniTaskBonusGivenForSkillIds: miniTaskBonusGivenForSkillIds ?? this.miniTaskBonusGivenForSkillIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'streakDays': streakDays,
        'lastActiveDate': lastActiveDate,
        'completedSkillIds': completedSkillIds,
        'completedMiniTaskKeys': completedMiniTaskKeys,
        'miniTaskBonusGivenForSkillIds': miniTaskBonusGivenForSkillIds,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalXp: json['totalXp'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
      completedSkillIds:
          (json['completedSkillIds'] as List<dynamic>?)?.cast<String>() ?? [],
      completedMiniTaskKeys:
          (json['completedMiniTaskKeys'] as List<dynamic>?)?.cast<String>() ?? [],
      miniTaskBonusGivenForSkillIds:
          (json['miniTaskBonusGivenForSkillIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
