import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/financial_profile.dart';
import '../../../domain/repositories/profile_repository.dart';

/// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileCreateRequested extends ProfileEvent {
  final int age;
  final String gender;
  final String occupation;
  final String educationLevel;
  final double monthlyIncome;
  final double? otherIncome;
  final List<FixedExpense> fixedExpenses;

  const ProfileCreateRequested({
    required this.age,
    required this.gender,
    required this.occupation,
    required this.educationLevel,
    required this.monthlyIncome,
    this.otherIncome,
    required this.fixedExpenses,
  });

  @override
  List<Object?> get props => [
    age,
    gender,
    occupation,
    educationLevel,
    monthlyIncome,
    otherIncome,
    fixedExpenses,
  ];
}

class ProfileUpdateRequested extends ProfileEvent {
  final int? age;
  final String? gender;
  final String? occupation;
  final String? educationLevel;
  final double? monthlyIncome;
  final double? otherIncome;

  const ProfileUpdateRequested({
    this.age,
    this.gender,
    this.occupation,
    this.educationLevel,
    this.monthlyIncome,
    this.otherIncome,
  });

  @override
  List<Object?> get props => [
    age,
    gender,
    occupation,
    educationLevel,
    monthlyIncome,
    otherIncome,
  ];
}

class FixedExpenseAddRequested extends ProfileEvent {
  final String name;
  final String category;
  final double amount;
  final String? description;

  const FixedExpenseAddRequested({
    required this.name,
    required this.category,
    required this.amount,
    this.description,
  });

  @override
  List<Object?> get props => [name, category, amount, description];
}

class FixedExpenseDeleteRequested extends ProfileEvent {
  final String id;

  const FixedExpenseDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event để submit profile từ form
class ProfileSubmitRequested extends ProfileEvent {
  final FinancialProfile profile;

  const ProfileSubmitRequested({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final FinancialProfile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileNotFound extends ProfileState {
  const ProfileNotFound();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileCreated extends ProfileState {
  final FinancialProfile profile;

  const ProfileCreated({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final FinancialProfile profile;

  const ProfileUpdated({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository})
    : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileCreateRequested>(_onCreateRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileSubmitRequested>(_onSubmitRequested);
    on<FixedExpenseAddRequested>(_onFixedExpenseAdd);
    on<FixedExpenseDeleteRequested>(_onFixedExpenseDelete);
  }

  Future<void> _onSubmitRequested(
    ProfileSubmitRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final profile = event.profile;
    final result = await profileRepository.createProfile(
      age: profile.age,
      gender: profile.gender,
      occupation: profile.occupation,
      educationLevel: profile.educationLevel ?? '',
      monthlyIncome: profile.monthlyIncome,
      otherIncome: profile.otherIncome,
      fixedExpenses: profile.fixedExpenses ?? [],
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (createdProfile) => emit(ProfileLoaded(profile: createdProfile)),
    );
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await profileRepository.getProfile();

    result.fold((failure) {
      // Check for various "no profile" messages
      if (failure.message.contains('404') ||
          failure.message.toLowerCase().contains('not found') ||
          failure.message.contains('Không tìm thấy dữ liệu') ||
          failure.message.contains('Chưa có hồ sơ')) {
        emit(const ProfileNotFound());
      } else {
        emit(ProfileError(message: failure.message));
      }
    }, (profile) => emit(ProfileLoaded(profile: profile)));
  }

  Future<void> _onCreateRequested(
    ProfileCreateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await profileRepository.createProfile(
      age: event.age,
      gender: event.gender,
      occupation: event.occupation,
      educationLevel: event.educationLevel,
      monthlyIncome: event.monthlyIncome,
      otherIncome: event.otherIncome,
      fixedExpenses: event.fixedExpenses,
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await profileRepository.updateProfile(
      age: event.age,
      gender: event.gender,
      occupation: event.occupation,
      educationLevel: event.educationLevel,
      monthlyIncome: event.monthlyIncome,
      otherIncome: event.otherIncome,
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileUpdated(profile: profile)),
    );
  }

  Future<void> _onFixedExpenseAdd(
    FixedExpenseAddRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await profileRepository.addFixedExpense(
      name: event.name,
      category: event.category,
      amount: event.amount,
      description: event.description,
    );

    // Reload profile
    add(const ProfileLoadRequested());
  }

  Future<void> _onFixedExpenseDelete(
    FixedExpenseDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await profileRepository.deleteFixedExpense(event.id);

    // Reload profile
    add(const ProfileLoadRequested());
  }
}
