import 'package:equatable/equatable.dart';

/// Entity đại diện cho tiến độ và phần thưởng của người dùng
class UserProgress extends Equatable {
  final String id;
  final String userId;
  final int streakDays;
  final int rewardPoints;
  final int level;
  final List<Achievement> achievements;
  final DateTime lastActivityDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProgress({
    required this.id,
    required this.userId,
    required this.streakDays,
    required this.rewardPoints,
    required this.level,
    required this.achievements,
    required this.lastActivityDate,
    required this.createdAt,
    this.updatedAt,
  });

  /// Điểm cần để lên level tiếp theo
  int get pointsToNextLevel => (level + 1) * 100 - rewardPoints;

  /// Tiến độ đến level tiếp theo (%)
  double get levelProgress {
    final currentLevelPoints = level * 100;
    final nextLevelPoints = (level + 1) * 100;
    final pointsInCurrentLevel = rewardPoints - currentLevelPoints;
    final pointsNeeded = nextLevelPoints - currentLevelPoints;
    return (pointsInCurrentLevel / pointsNeeded) * 100;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    streakDays,
    rewardPoints,
    level,
    achievements,
    lastActivityDate,
    createdAt,
    updatedAt,
  ];
}

/// Entity đại diện cho thành tựu
class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int points;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.points,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    iconUrl,
    points,
    unlockedAt,
  ];
}
