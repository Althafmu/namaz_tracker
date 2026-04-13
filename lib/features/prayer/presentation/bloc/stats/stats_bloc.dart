import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../domain/usecases/get_reason_summary_usecase.dart';
import 'stats_event.dart';
import 'stats_state.dart';

/// StatsBloc — manages aggregated prayer statistics.
/// Uses HydratedBloc for independent offline caching.
class StatsBloc extends HydratedBloc<StatsEvent, StatsState> {
  final GetReasonSummaryUseCase getReasonSummaryUseCase;

  StatsBloc({required this.getReasonSummaryUseCase}) : super(const StatsState()) {
    on<LoadAllReasons>(_onLoadAllReasons);
    on<UpdateReason>(_onUpdateReason);
    on<ClearStats>(_onClearStats);
  }

  Future<void> _onLoadAllReasons(
    LoadAllReasons event,
    Emitter<StatsState> emit,
  ) async {
    try {
      final reasons = await getReasonSummaryUseCase();
      emit(state.copyWith(reasonCounts: reasons));
    } on NetworkException catch (e) {
      // Offline - use cached HydratedBloc state
      debugPrint('[StatsBloc] Network error loading reasons: ${e.message}');
    } on ServerException catch (e) {
      // Server error - log but keep cached state
      debugPrint('[StatsBloc] Server error loading reasons (${e.statusCode}): ${e.message}');
    } on NoDataException {
      // No data - keep empty state
      debugPrint('[StatsBloc] No reason data available');
    } catch (e) {
      debugPrint('[StatsBloc] Unexpected error loading reasons: $e');
    }
  }

  void _onUpdateReason(UpdateReason event, Emitter<StatsState> emit) {
    final updatedCounts = Map<String, int>.from(state.reasonCounts);
    updatedCounts[event.reason] = (updatedCounts[event.reason] ?? 0) + event.delta;
    // Don't allow negative counts
    if (updatedCounts[event.reason]! < 0) {
      updatedCounts[event.reason] = 0;
    }
    emit(state.copyWith(reasonCounts: updatedCounts));
  }

  void _onClearStats(ClearStats event, Emitter<StatsState> emit) {
    emit(const StatsState());
  }

  // ── HydratedBloc overrides ──

  @override
  StatsState? fromJson(Map<String, dynamic> json) {
    try {
      return StatsState.fromJson(json);
    } catch (e) {
      debugPrint('[StatsBloc] Failed to restore state from JSON: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(StatsState state) {
    try {
      return state.toJson();
    } catch (e) {
      debugPrint('[StatsBloc] Failed to serialize state to JSON: $e');
      return null;
    }
  }
}