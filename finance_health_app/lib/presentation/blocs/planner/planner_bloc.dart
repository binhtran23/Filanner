import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/plan.dart';
import '../../../domain/repositories/planner_repository.dart';

/// Events
abstract class PlannerEvent extends Equatable {
  const PlannerEvent();
  @override
  List<Object?> get props => [];
}

class PlannerLoadRequested extends PlannerEvent {
  const PlannerLoadRequested();
}

class PlannerGenerateRequested extends PlannerEvent {
  const PlannerGenerateRequested();
}

class PlannerSelectPlan extends PlannerEvent {
  final String planId;

  const PlannerSelectPlan({required this.planId});

  @override
  List<Object?> get props => [planId];
}

class PlannerNodeComplete extends PlannerEvent {
  final String nodeId;

  const PlannerNodeComplete({required this.nodeId});

  @override
  List<Object?> get props => [nodeId];
}

class PlannerNodeUpdate extends PlannerEvent {
  final String nodeId;
  final double? currentAmount;
  final String? title;

  const PlannerNodeUpdate({
    required this.nodeId,
    this.currentAmount,
    this.title,
  });

  @override
  List<Object?> get props => [nodeId, currentAmount, title];
}

class PlannerDeletePlan extends PlannerEvent {
  final String planId;

  const PlannerDeletePlan({required this.planId});

  @override
  List<Object?> get props => [planId];
}

/// States
abstract class PlannerState extends Equatable {
  const PlannerState();
  @override
  List<Object?> get props => [];
}

class PlannerInitial extends PlannerState {
  const PlannerInitial();
}

class PlannerLoading extends PlannerState {
  const PlannerLoading();
}

class PlannerLoaded extends PlannerState {
  final List<Plan> plans;
  final Plan? activePlan;
  final Plan? selectedPlan;

  const PlannerLoaded({
    required this.plans,
    this.activePlan,
    this.selectedPlan,
  });

  @override
  List<Object?> get props => [plans, activePlan, selectedPlan];

  PlannerLoaded copyWith({
    List<Plan>? plans,
    Plan? activePlan,
    Plan? selectedPlan,
  }) {
    return PlannerLoaded(
      plans: plans ?? this.plans,
      activePlan: activePlan ?? this.activePlan,
      selectedPlan: selectedPlan ?? this.selectedPlan,
    );
  }
}

class PlannerGenerating extends PlannerState {
  const PlannerGenerating();
}

class PlannerGenerated extends PlannerState {
  final Plan plan;

  const PlannerGenerated({required this.plan});

  @override
  List<Object?> get props => [plan];
}

class PlannerError extends PlannerState {
  final String message;

  const PlannerError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// BLoC
class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final PlannerRepository plannerRepository;

  PlannerBloc({required this.plannerRepository})
    : super(const PlannerInitial()) {
    on<PlannerLoadRequested>(_onLoadRequested);
    on<PlannerGenerateRequested>(_onGenerateRequested);
    on<PlannerSelectPlan>(_onSelectPlan);
    on<PlannerNodeComplete>(_onNodeComplete);
    on<PlannerNodeUpdate>(_onNodeUpdate);
    on<PlannerDeletePlan>(_onDeletePlan);
  }

  Future<void> _onLoadRequested(
    PlannerLoadRequested event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading());

    final plansResult = await plannerRepository.getPlans();
    final activeResult = await plannerRepository.getActivePlan();

    plansResult.fold(
      (failure) => emit(PlannerError(message: failure.message)),
      (plans) {
        activeResult.fold(
          (failure) => emit(PlannerLoaded(plans: plans)),
          (activePlan) => emit(
            PlannerLoaded(
              plans: plans,
              activePlan: activePlan,
              selectedPlan: activePlan,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onGenerateRequested(
    PlannerGenerateRequested event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerGenerating());

    final result = await plannerRepository.generatePlan();

    result.fold((failure) => emit(PlannerError(message: failure.message)), (
      plan,
    ) {
      emit(PlannerGenerated(plan: plan));
      // Reload all plans
      add(const PlannerLoadRequested());
    });
  }

  Future<void> _onSelectPlan(
    PlannerSelectPlan event,
    Emitter<PlannerState> emit,
  ) async {
    final currentState = state;
    if (currentState is PlannerLoaded) {
      final result = await plannerRepository.getPlanById(event.planId);

      result.fold(
        (failure) => emit(PlannerError(message: failure.message)),
        (plan) => emit(currentState.copyWith(selectedPlan: plan)),
      );
    }
  }

  Future<void> _onNodeComplete(
    PlannerNodeComplete event,
    Emitter<PlannerState> emit,
  ) async {
    final result = await plannerRepository.completeNode(event.nodeId);

    result.fold(
      (failure) => emit(PlannerError(message: failure.message)),
      (_) => add(const PlannerLoadRequested()),
    );
  }

  Future<void> _onNodeUpdate(
    PlannerNodeUpdate event,
    Emitter<PlannerState> emit,
  ) async {
    final result = await plannerRepository.updatePlanNode(
      nodeId: event.nodeId,
      currentAmount: event.currentAmount,
      title: event.title,
    );

    result.fold(
      (failure) => emit(PlannerError(message: failure.message)),
      (_) => add(const PlannerLoadRequested()),
    );
  }

  Future<void> _onDeletePlan(
    PlannerDeletePlan event,
    Emitter<PlannerState> emit,
  ) async {
    final result = await plannerRepository.deletePlan(event.planId);

    result.fold(
      (failure) => emit(PlannerError(message: failure.message)),
      (_) => add(const PlannerLoadRequested()),
    );
  }
}
