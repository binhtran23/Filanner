import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Events
abstract class ProgressEvent extends Equatable {
  const ProgressEvent();
  @override
  List<Object?> get props => [];
}

class ProgressLoadRequested extends ProgressEvent {
  const ProgressLoadRequested();
}

class ProgressCheckIn extends ProgressEvent {
  const ProgressCheckIn();
}

class ProgressAddPoints extends ProgressEvent {
  final int points;
  final String reason;

  const ProgressAddPoints({required this.points, required this.reason});

  @override
  List<Object?> get props => [points, reason];
}

/// States
abstract class ProgressState extends Equatable {
  const ProgressState();
  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

class ProgressLoaded extends ProgressState {
  final int streakDays;
  final int rewardPoints;
  final int level;
  final double levelProgress;
  final List<AchievementData> achievements;
  final bool checkedInToday;

  const ProgressLoaded({
    required this.streakDays,
    required this.rewardPoints,
    required this.level,
    required this.levelProgress,
    required this.achievements,
    required this.checkedInToday,
  });

  @override
  List<Object?> get props => [
    streakDays,
    rewardPoints,
    level,
    levelProgress,
    achievements,
    checkedInToday,
  ];

  ProgressLoaded copyWith({
    int? streakDays,
    int? rewardPoints,
    int? level,
    double? levelProgress,
    List<AchievementData>? achievements,
    bool? checkedInToday,
  }) {
    return ProgressLoaded(
      streakDays: streakDays ?? this.streakDays,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      level: level ?? this.level,
      levelProgress: levelProgress ?? this.levelProgress,
      achievements: achievements ?? this.achievements,
      checkedInToday: checkedInToday ?? this.checkedInToday,
    );
  }
}

class ProgressError extends ProgressState {
  final String message;

  const ProgressError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProgressCheckInSuccess extends ProgressState {
  final int newStreak;
  final int pointsEarned;

  const ProgressCheckInSuccess({
    required this.newStreak,
    required this.pointsEarned,
  });

  @override
  List<Object?> get props => [newStreak, pointsEarned];
}

/// Achievement data placeholder
class AchievementData extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int points;
  final bool isUnlocked;

  const AchievementData({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.points,
    required this.isUnlocked,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    iconName,
    points,
    isUnlocked,
  ];
}

/// BLoC - Placeholder implementation (will connect to backend later)
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  ProgressBloc() : super(const ProgressInitial()) {
    on<ProgressLoadRequested>(_onLoadRequested);
    on<ProgressCheckIn>(_onCheckIn);
    on<ProgressAddPoints>(_onAddPoints);
  }

  Future<void> _onLoadRequested(
    ProgressLoadRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());

    // Placeholder data - sẽ được thay bằng API call thực tế
    await Future.delayed(const Duration(milliseconds: 500));

    emit(
      const ProgressLoaded(
        streakDays: 7,
        rewardPoints: 350,
        level: 3,
        levelProgress: 50.0,
        achievements: [
          AchievementData(
            id: '1',
            name: 'Khởi đầu',
            description: 'Hoàn thành đăng ký tài khoản',
            iconName: 'star',
            points: 10,
            isUnlocked: true,
          ),
          AchievementData(
            id: '2',
            name: 'Streak 7 ngày',
            description: 'Điểm danh 7 ngày liên tiếp',
            iconName: 'fire',
            points: 50,
            isUnlocked: true,
          ),
          AchievementData(
            id: '3',
            name: 'Tiết kiệm đầu tiên',
            description: 'Đạt mục tiêu tiết kiệm đầu tiên',
            iconName: 'piggy_bank',
            points: 100,
            isUnlocked: false,
          ),
        ],
        checkedInToday: false,
      ),
    );
  }

  Future<void> _onCheckIn(
    ProgressCheckIn event,
    Emitter<ProgressState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProgressLoaded) {
      // TODO: Call API to check in
      await Future.delayed(const Duration(milliseconds: 300));

      final newStreak = currentState.streakDays + 1;
      final pointsEarned = 10;

      emit(
        ProgressCheckInSuccess(
          newStreak: newStreak,
          pointsEarned: pointsEarned,
        ),
      );

      emit(
        currentState.copyWith(
          streakDays: newStreak,
          rewardPoints: currentState.rewardPoints + pointsEarned,
          checkedInToday: true,
        ),
      );
    }
  }

  Future<void> _onAddPoints(
    ProgressAddPoints event,
    Emitter<ProgressState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProgressLoaded) {
      // TODO: Call API to add points
      final newPoints = currentState.rewardPoints + event.points;
      final newLevel = (newPoints / 100).floor();

      emit(
        currentState.copyWith(
          rewardPoints: newPoints,
          level: newLevel,
          levelProgress: (newPoints % 100).toDouble(),
        ),
      );
    }
  }
}
