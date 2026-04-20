import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/datasources/sunnah_remote_data_source.dart';
import '../../../domain/entities/sunnah_day_summary.dart';
import 'sunnah_event.dart';
import 'sunnah_state.dart';

class SunnahBloc extends HydratedBloc<SunnahEvent, SunnahState> {
  final SunnahRemoteDataSource? _remoteDataSource;

  SunnahBloc({SunnahRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource,
      super(const SunnahState()) {
    on<LoadDailySunnah>(_onLoadDaily);
    on<ToggleSunnahPrayer>(_onToggle);
    on<SetSunnahPrayerCompletion>(_onSetCompletion);
    on<LoadWeeklySunnah>(_onLoadWeekly);
  }

  Future<void> _onLoadDaily(
    LoadDailySunnah event,
    Emitter<SunnahState> emit,
  ) async {
    // Emit cached data immediately (already in state from hydration).
    // Then try to refresh from remote.
    try {
      final remote = _remoteDataSource;
      if (remote == null) return;

      final summary = await remote.getDailySummary(dateKey: event.dateKey);
      final updated = Map<String, SunnahDaySummary>.from(state.dailyCache);
      updated[event.dateKey] = summary;
      emit(state.copyWith(dailyCache: updated));
    } catch (e) {
      debugPrint('[SunnahBloc] Remote daily fetch failed: $e');
      // Cached data remains — offline-first.
    }
  }

  Future<void> _onToggle(
    ToggleSunnahPrayer event,
    Emitter<SunnahState> emit,
  ) async {
    final current = state.dailyCache[event.dateKey];
    final wasCompleted = current?.isCompleted(event.prayerType) ?? false;
    await _setCompletion(
      dateKey: event.dateKey,
      prayerType: event.prayerType,
      completed: !wasCompleted,
      emit: emit,
      debugTag: 'toggle',
    );
  }

  Future<void> _onSetCompletion(
    SetSunnahPrayerCompletion event,
    Emitter<SunnahState> emit,
  ) async {
    await _setCompletion(
      dateKey: event.dateKey,
      prayerType: event.prayerType,
      completed: event.completed,
      emit: emit,
      debugTag: 'set',
    );
  }

  Future<void> _setCompletion({
    required String dateKey,
    required String prayerType,
    required bool completed,
    required Emitter<SunnahState> emit,
    required String debugTag,
  }) async {
    final current = state.dailyCache[dateKey];
    final updatedTypes = Set<String>.from(
      current?.completedPrayerTypes ?? <String>{},
    );

    if (completed) {
      updatedTypes.add(prayerType);
    } else {
      updatedTypes.remove(prayerType);
    }

    final optimistic = SunnahDaySummary(
      date: dateKey,
      completedCount: updatedTypes.length,
      totalOpportunities: current?.totalOpportunities ?? updatedTypes.length,
      completedPrayerTypes: updatedTypes,
    );
    final optimisticCache = Map<String, SunnahDaySummary>.from(
      state.dailyCache,
    );
    optimisticCache[dateKey] = optimistic;
    emit(state.copyWith(dailyCache: optimisticCache));

    try {
      final remote = _remoteDataSource;
      if (remote == null) return;

      final refreshed = await remote.logPrayer(
        prayerType: prayerType,
        completed: completed,
        dateKey: dateKey,
      );
      final serverCache = Map<String, SunnahDaySummary>.from(state.dailyCache);
      serverCache[dateKey] = refreshed;
      emit(state.copyWith(dailyCache: serverCache));
    } catch (e) {
      debugPrint('[SunnahBloc] Remote $debugTag failed: $e');
      // Keep optimistic state — user sees their action reflected.
    }
  }

  Future<void> _onLoadWeekly(
    LoadWeeklySunnah event,
    Emitter<SunnahState> emit,
  ) async {
    try {
      final remote = _remoteDataSource;
      if (remote == null) return;

      final week = await remote.getWeeklySummary(
        startDateKey: event.startDateKey,
      );
      emit(state.copyWith(weekSummary: week));

      // Also update daily cache from weekly response days.
      final updated = Map<String, SunnahDaySummary>.from(state.dailyCache);
      for (final day in week.days) {
        updated[day.date] = day;
      }
      emit(state.copyWith(dailyCache: updated));
    } catch (e) {
      debugPrint('[SunnahBloc] Remote weekly fetch failed: $e');
    }
  }

  @override
  SunnahState? fromJson(Map<String, dynamic> json) {
    try {
      return SunnahState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SunnahState state) {
    try {
      return state.toJson();
    } catch (_) {
      return null;
    }
  }
}
