import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/prayer_scheduler_service.dart';
import '../../../domain/entities/prayer.dart';
import '../../../domain/usecases/consume_protector_token_usecase.dart';
import '../../../domain/usecases/get_streak_usecase.dart';
import '../../../domain/usecases/set_excused_day_usecase.dart';
import '../history/history_bloc.dart';
import '../history/history_state.dart';
import '../settings/settings_bloc.dart';
import '../settings/settings_event.dart';
import 'streak_event.dart';
import 'streak_state.dart';

/// StreakBloc manages prayer streak state independently.
/// Listens to HistoryBloc for historical data changes to recalculate streak.
class StreakBloc extends HydratedBloc<StreakEvent, StreakState> {
  final GetStreakUseCase getStreakUseCase;
  final ConsumeProtectorTokenUseCase consumeProtectorTokenUseCase;
  final SetExcusedDayUseCase setExcusedDayUseCase;
  final HistoryBloc historyBloc;

  late final StreamSubscription<HistoryState> _historySubscription;

  StreakBloc({
    required this.getStreakUseCase,
    required this.consumeProtectorTokenUseCase,
    required this.setExcusedDayUseCase,
    required this.historyBloc,
  }) : super(const StreakState()) {
    on<LoadStreak>(_onLoadStreak);
    on<UpdateStreak>(_onUpdateStreak);
    on<RecalculateStreakFromHistory>(_onRecalculateStreakFromHistory);
    on<ConsumeProtectorToken>(_onConsumeProtectorToken);
    on<SetExcusedDay>(_onSetExcusedDay);

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
      emit(
        state.copyWith(
          streak: streak,
          isLoading: false,
          syncStatus: SyncStatus.synced,
        ),
      );
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

  void _onUpdateStreak(UpdateStreak event, Emitter<StreakState> emit) {
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
    final calculation = _calculateLocalStreak(event.historicalLog);
    if (calculation == null) {
      return;
    }

    final currentStreak = calculation.currentStreak;
    final newStreak = state.streak.copyWith(
      currentStreak: currentStreak,
      longestStreak: currentStreak > state.streak.longestStreak
          ? currentStreak
          : state.streak.longestStreak,
      displayStreak: currentStreak > 0
          ? currentStreak
          : state.streak.displayStreak,
    );

    if (newStreak != state.streak) {
      emit(state.copyWith(streak: newStreak));
    }
  }

  _LocalStreakCalculation? _calculateLocalStreak(
    Map<String, List<Prayer>> historicalLog,
  ) {
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    final todayKey = fmt.format(now);
    final yesterdayKey = fmt.format(now.subtract(const Duration(days: 1)));

    final hasRecentSignal =
        historicalLog.containsKey(todayKey) ||
        historicalLog.containsKey(yesterdayKey);
    if (!hasRecentSignal) {
      return null;
    }

    var currentStreak = 0;

    for (var dayOffset = 0; dayOffset < 365; dayOffset++) {
      final date = now.subtract(Duration(days: dayOffset));
      final key = fmt.format(date);
      final dayPrayers = historicalLog[key];

      if (dayPrayers == null || dayPrayers.isEmpty) {
        if (dayOffset == 0) {
          continue;
        }
        break;
      }

      final dayType = _classifyDay(dayPrayers);

      if (dayType == _StreakDayType.pending && dayOffset == 0) {
        continue;
      }
      if (dayType == _StreakDayType.excused) {
        continue;
      }
      if (dayType == _StreakDayType.counted) {
        currentStreak++;
        continue;
      }
      break;
    }

    return _LocalStreakCalculation(currentStreak);
  }

  _StreakDayType _classifyDay(List<Prayer> prayers) {
    if (prayers.length < 5) {
      return _StreakDayType.invalid;
    }

    if (prayers.every((prayer) => prayer.isExcused)) {
      return _StreakDayType.excused;
    }

    if (prayers.every((prayer) => prayer.isValidForStreak)) {
      return _StreakDayType.counted;
    }

    final hasOnlyPendingAndValidStates =
        prayers.any((prayer) => prayer.isPending) &&
        prayers.every((prayer) => prayer.isPending || prayer.isValidForStreak);
    if (hasOnlyPendingAndValidStates) {
      return _StreakDayType.pending;
    }

    return _StreakDayType.invalid;
  }

  Future<void> _onConsumeProtectorToken(
    ConsumeProtectorToken event,
    Emitter<StreakState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final updatedStreak = await consumeProtectorTokenUseCase(
        date: event.date,
      );
      emit(
        state.copyWith(
          streak: updatedStreak,
          isLoading: false,
          syncStatus: SyncStatus.synced,
        ),
      );
      debugPrint(
        '[StreakBloc] Protector token consumed. Tokens remaining: ${updatedStreak.protectorTokens}',
      );
    } on NetworkException catch (e) {
      debugPrint('[StreakBloc] Network error consuming token: ${e.message}');
      emit(state.copyWith(isLoading: false, syncStatus: SyncStatus.error));
    } on ServerException catch (e) {
      debugPrint('[StreakBloc] Server error (${e.statusCode}): ${e.message}');
      emit(state.copyWith(isLoading: false, syncStatus: SyncStatus.error));
    } catch (e) {
      debugPrint('[StreakBloc] Unexpected error: $e');
      emit(state.copyWith(isLoading: false, syncStatus: SyncStatus.error));
    }
  }

  Future<void> _onSetExcusedDay(
    SetExcusedDay event,
    Emitter<StreakState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await setExcusedDayUseCase(date: event.date, reason: event.reason);
      final updatedStreak = await getStreakUseCase();

      // Add the excused date to SettingsBloc and suppress notifications
      try {
        final settingsBloc = GetIt.instance<SettingsBloc>();
        settingsBloc.add(AddExcusedDay(event.date));

        final scheduler = GetIt.instance<PrayerSchedulerService>();
        await scheduler.cancelAllNotifications();
        await scheduler.scheduleNotifications(settingsBloc.state);
      } catch (e) {
        debugPrint('[StreakBloc] Failed to update notification schedule: $e');
      }

      emit(
        state.copyWith(
          streak: updatedStreak,
          isLoading: false,
          syncStatus: SyncStatus.synced,
        ),
      );
      debugPrint(
        '[StreakBloc] Day ${event.date} marked as excused: ${event.reason ?? "no reason"}',
      );
    } on NetworkException catch (e) {
      debugPrint(
        '[StreakBloc] Network error setting excused day: ${e.message}',
      );
      emit(state.copyWith(isLoading: false, syncStatus: SyncStatus.error));
    } on ServerException catch (e) {
      debugPrint('[StreakBloc] Server error (${e.statusCode}): ${e.message}');
      emit(state.copyWith(isLoading: false, syncStatus: SyncStatus.error));
    } catch (e) {
      debugPrint('[StreakBloc] Unexpected error: $e');
      emit(state.copyWith(isLoading: false, syncStatus: SyncStatus.error));
    }
  }

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

class _LocalStreakCalculation {
  final int currentStreak;

  const _LocalStreakCalculation(this.currentStreak);
}

enum _StreakDayType { counted, excused, pending, invalid }
