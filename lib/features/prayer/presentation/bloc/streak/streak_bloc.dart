import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../domain/usecases/get_streak_usecase.dart';
import '../history/history_bloc.dart';
import '../history/history_state.dart';
import 'streak_event.dart';
import 'streak_state.dart';

/// StreakBloc — manages prayer streak state independently.
/// Listens to HistoryBloc for historical data changes to recalculate streak.
class StreakBloc extends HydratedBloc<StreakEvent, StreakState> {
  final GetStreakUseCase getStreakUseCase;
  final HistoryBloc historyBloc;

  late final StreamSubscription<HistoryState> _historySubscription;

  StreakBloc({
    required this.getStreakUseCase,
    required this.historyBloc,
  }) : super(const StreakState()) {
    on<LoadStreak>(_onLoadStreak);
    on<UpdateStreak>(_onUpdateStreak);
    on<RecalculateStreakFromHistory>(_onRecalculateStreakFromHistory);

    // Listen to HistoryBloc changes to recalculate streak
    _historySubscription = historyBloc.stream.listen((historyState) {
      add(RecalculateStreakFromHistory(historyState.historicalLog));
    });
  }

  @override
  Future<void> close() {
    _historySubscription.cancel();
    return super.close();
  }

  Future<void> _onLoadStreak(
    LoadStreak event,
    Emitter<StreakState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final streak = await getStreakUseCase();
      emit(state.copyWith(streak: streak, isLoading: false, syncStatus: SyncStatus.synced));
    } on NetworkException catch (e) {
      debugPrint('[StreakBloc] Network error: ${e.message}');
      emit(state.copyWith(isLoading: false, syncStatus: SyncStatus.error));
    } on ServerException catch (e) {
      debugPrint('[StreakBloc] Server error (${e.statusCode}): ${e.message}');
      emit(state.copyWith(isLoading: false, syncStatus: SyncStatus.error));
    } catch (e) {
      debugPrint('[StreakBloc] Unexpected error: $e');
      emit(state.copyWith(isLoading: false, syncStatus: SyncStatus.error));
    }
  }

  void _onUpdateStreak(
    UpdateStreak event,
    Emitter<StreakState> emit,
  ) {
    final newStreak = state.streak.copyWith(
      currentStreak: event.currentStreak,
      longestStreak: event.longestStreak > state.streak.longestStreak
          ? event.longestStreak
          : state.streak.longestStreak,
      displayStreak: event.displayStreak,
    );
    emit(state.copyWith(streak: newStreak));
  }

  void _onRecalculateStreakFromHistory(
    RecalculateStreakFromHistory event,
    Emitter<StreakState> emit,
  ) {
    final fmt = DateFormat('yyyy-MM-dd');
    final effectiveNow = DateTime.now();
    int count = 0;

    for (int i = 0; i < 365; i++) {
      final date = effectiveNow.subtract(Duration(days: i));
      final key = fmt.format(date);

      final dayPrayers = event.historicalLog[key];

      if (dayPrayers == null || dayPrayers.isEmpty) break;

      final completed = dayPrayers.where((p) => p.isCompleted).length;
      if (completed >= 5) {
        count++;
      } else {
        break;
      }
    }

    final newLongest = count > state.streak.longestStreak ? count : state.streak.longestStreak;

    final newStreak = state.streak.copyWith(
      currentStreak: count,
      longestStreak: newLongest,
    );

    if (newStreak != state.streak) {
      emit(state.copyWith(streak: newStreak));
    }
  }

  // ── HydratedBloc overrides ──

  @override
  StreakState? fromJson(Map<String, dynamic> json) {
    try {
      return StreakState.fromJson(json);
    } catch (e) {
      debugPrint('[StreakBloc] Failed to restore state from JSON: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(StreakState state) {
    try {
      return state.toJson();
    } catch (e) {
      debugPrint('[StreakBloc] Failed to serialize state to JSON: $e');
      return null;
    }
  }
}