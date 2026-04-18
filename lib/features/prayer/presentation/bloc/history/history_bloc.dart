import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/time_service.dart';
import '../../../domain/entities/prayer.dart';
import '../../../domain/usecases/get_detailed_month_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

/// HistoryBloc — manages historical prayer data and calendar navigation.
/// Uses HydratedBloc for independent offline caching.
class HistoryBloc extends HydratedBloc<HistoryEvent, HistoryState> {
  final GetDetailedMonthHistoryUseCase getDetailedMonthHistoryUseCase;

  HistoryBloc({required this.getDetailedMonthHistoryUseCase})
      : super(HistoryState()) {
    on<LoadMonthHistory>(_onLoadMonthHistory);
    on<SelectDate>(_onSelectDate);
    on<ClearSelectedDate>(_onClearSelectedDate);
    on<UpdateDayLog>(_onUpdateDayLog);
    on<MergeMonthData>(_onMergeMonthData);
    on<ClearHistory>(_onClearHistory);
  }

  Future<void> _onLoadMonthHistory(
    LoadMonthHistory event,
    Emitter<HistoryState> emit,
  ) async {
    final monthKey =
        '${event.year}-${event.month.toString().padLeft(2, '0')}';
    final now = TimeService.effectiveNow();
    final isCurrentMonth =
        event.year == now.year && event.month == now.month;

    // Update calendar navigation immediately
    emit(state.copyWith(
      calendarYear: event.year,
      calendarMonth: event.month,
    ));

    // Skip if already fetched (and not current month — current month always refreshes)
    if (state.fetchedMonths.contains(monthKey) && !isCurrentMonth) {
      return;
    }

    try {
      final monthData = await getDetailedMonthHistoryUseCase(
        year: event.year,
        month: event.month,
      );

      add(MergeMonthData(
        monthData: monthData,
        preserveToday: isCurrentMonth,
      ));

      // Mark month as fetched
      final updatedFetched = Set<String>.from(state.fetchedMonths)..add(monthKey);
      emit(state.copyWith(fetchedMonths: updatedFetched));
    } on NetworkException catch (e) {
      // Offline - use cached HydratedBloc state, don't mark as fetched
      debugPrint('[HistoryBloc] Network error loading $monthKey: ${e.message}');
    } on ServerException catch (e) {
      // Server error - log but keep cached state
      debugPrint('[HistoryBloc] Server error loading $monthKey (${e.statusCode}): ${e.message}');
    } on NoDataException {
      // No data for this month - mark as fetched to avoid re-fetching
      final updatedFetched = Set<String>.from(state.fetchedMonths)..add(monthKey);
      emit(state.copyWith(fetchedMonths: updatedFetched));
    } catch (e) {
      debugPrint('[HistoryBloc] Unexpected error loading $monthKey: $e');
    }
  }

  void _onSelectDate(SelectDate event, Emitter<HistoryState> emit) {
    emit(state.copyWith(selectedDateStr: event.dateStr));
  }

  void _onClearSelectedDate(
    ClearSelectedDate event,
    Emitter<HistoryState> emit,
  ) {
    emit(state.copyWith(clearSelectedDate: true));
  }

  void _onUpdateDayLog(UpdateDayLog event, Emitter<HistoryState> emit) {
    final updatedLog = Map<String, List<Prayer>>.from(state.historicalLog);
    updatedLog[event.dateStr] = event.prayers;
    emit(state.copyWith(historicalLog: updatedLog));
  }

  void _onMergeMonthData(
    MergeMonthData event,
    Emitter<HistoryState> emit,
  ) {
    final updatedLog = Map<String, List<Prayer>>.from(state.historicalLog);
    event.monthData.forEach((dateStr, prayers) {
      if (event.preserveToday && dateStr == HistoryState.todayKey) {
        // Don't overwrite today's optimistic local state
        return;
      }
      updatedLog[dateStr] = prayers;
    });
    emit(state.copyWith(historicalLog: updatedLog));
  }

  void _onClearHistory(ClearHistory event, Emitter<HistoryState> emit) {
    emit(HistoryState());
  }

  // ── HydratedBloc overrides ──

  @override
  HistoryState? fromJson(Map<String, dynamic> json) {
    try {
      return HistoryState.fromJson(json);
    } catch (e) {
      debugPrint('[HistoryBloc] Failed to restore state from JSON: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(HistoryState state) {
    try {
      return state.toJson();
    } catch (e) {
      debugPrint('[HistoryBloc] Failed to serialize state to JSON: $e');
      return null;
    }
  }
}