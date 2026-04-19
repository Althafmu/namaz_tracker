import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';


import '../../../../../core/services/milestone_service.dart';
import '../../../../../core/services/time_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../bloc/prayer/prayer_bloc.dart';
import '../../bloc/prayer/prayer_event.dart';
import '../../bloc/prayer/prayer_state.dart';
import '../../bloc/history/history_bloc.dart';
import '../../bloc/history/history_state.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_state.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/streak/streak_bloc.dart';
import '../../bloc/streak/streak_state.dart';
import '../prayer_logger/prayer_logger_sheet.dart';
import 'widgets/prayer_card.dart';
import 'widgets/motivational_banner.dart';
import 'widgets/weekly_calendar.dart';

/// Dashboard / Home Page — matches dashboard.html Stitch mockup.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late String _lastKnownTodayKey;
  StreamSubscription<PrayerState>? _actionMessageSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastKnownTodayKey = HistoryState.todayKey;
    Future.microtask(() {
      if (mounted) {
        context.read<PrayerBloc>().add(const LoadDailyStatus());
        _checkMilestones();
        _checkUpgradePrompt();
        _listenForActionMessages();
      }
    });
  }

  void _listenForActionMessages() {
    _actionMessageSubscription = context.read<PrayerBloc>().stream.listen((state) {
      if (state.lastActionMessage != null && mounted) {
        final isError = state.undoStatus == UndoStatus.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.lastActionMessage!),
            backgroundColor: isError
                ? Colors.red.shade700
                : Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _actionMessageSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNewDayAndRefresh();
    }
  }

  void _checkNewDayAndRefresh() {
    final currentTodayKey = HistoryState.todayKey;
    if (currentTodayKey != _lastKnownTodayKey) {
      _lastKnownTodayKey = currentTodayKey;
      if (mounted) {
        context.read<PrayerBloc>().add(const LoadDailyStatus());
      }
    }
  }

  void _checkMilestones() {
    final settingsState = GetIt.I<SettingsBloc>().state;
    final streakState = context.read<PrayerBloc>().state;
    // Streak is accessed via streak bloc - check on next frame
    Future.microtask(() {
      final streakBloc = GetIt.I<StreakBloc>();
      MilestoneService().checkAndShowMilestone(context, streakBloc.state.streak.displayStreak);
    });
  }

  void _checkUpgradePrompt() {
    final settingsState = GetIt.I<SettingsBloc>().state;
    final streakState = context.read<PrayerBloc>().state;
    Future.microtask(() {
      final streakBloc = GetIt.I<StreakBloc>();
      if (MilestoneService.shouldShowUpgradePrompt(settingsState, streakBloc.state.streak.displayStreak)) {
        _showUpgradePromptBanner(context);
      }
    });
  }

  void _showUpgradePromptBanner(BuildContext context) {
    final settingsState = GetIt.I<SettingsBloc>().state;
    String message;
    if (settingsState.intentLevel == IntentLevel.foundation) {
      message = "You've been consistent. Want to take the next step?";
    } else {
      message = "You're growing strong. Ready to push further?";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: 'Upgrade',
          textColor: Colors.white,
          onPressed: () {
            GetIt.I<SettingsBloc>().add(const DismissUpgradePrompt());
            // Navigate to intent onboarding to upgrade
            GoRouter.of(context).go('/intent-setup');
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We only check for a day rollover here to handle cases where the app is
    // left open at midnight. didChangeAppLifecycleState handles the resume case.
    _checkNewDayAndRefresh();

    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, prayerState) {
        return BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, historyState) {
            // Determine which prayers to display
            final selectedDate = historyState.selectedDateStr;
            final isToday = selectedDate == null || selectedDate == HistoryState.todayKey;
            final displayPrayers = isToday
                ? prayerState.prayers
                : (historyState.historicalLog[selectedDate] ?? prayerState.prayers);
            final isHistorical = !isToday;

            final completedToday = prayerState.prayers
                .where((p) => p.isCompleted && !p.isExcused)
                .length;

            return SafeArea(
              child: Column(
                children: [
                  // ── Top App Bar ──
                  BlocBuilder<StreakBloc, StreakState>(
                    bloc: GetIt.I<StreakBloc>(),
                    builder: (context, streakState) {
                      final streak = streakState.streak.displayStreak;
                      return _HomeTopBar(
                        streak: streak,
                        completedToday: completedToday,
                        onStreakTap: () => context.push('/streak'),
                      );
                    },
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // ── Advanced Modules ──
                          BlocBuilder<SettingsBloc, SettingsState>(
                            builder: (context, settingsState) {
                              return Column(
                                children: [
                                  if (TimeService.isLateNight() && isToday)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.bedtime_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                "After midnight, prayers count toward yesterday until 3:00 AM",
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSurface,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  WeeklyCalendar(),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),

                          // ── Prayer List ──
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: () {
                                final items = <Widget>[];

                                for (int i = 0; i < displayPrayers.length; i++) {
                                  final prayer = displayPrayers[i];
                                  items.add(
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16, right: 6),
                                      child: PrayerCard(
                                        prayer: prayer,
                                        showTime: !isHistorical,
                                        onTap: () => _showPrayerLogger(context, prayer),
                                      ),
                                    ),
                                  );

                                  if (i == 3) {
                                    // Insert motivational quote after Maghrib
                                    items.add(
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 16, right: 6),
                                        child: MotivationalBanner(),
                                      ),
                                    );
                                  }
                                }

                                // Undo button (only for today, when there are completed prayers)
                                if (isToday &&
                                    displayPrayers.any((p) => p.isCompleted)) {
                                  items.add(
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 16, right: 6),
                                      child: Center(
                                        child: TextButton.icon(
                                          onPressed: prayerState.undoStatus ==
                                                  UndoStatus.loading
                                              ? null
                                              : () {
                                                  context.read<PrayerBloc>().add(
                                                      const UndoLastPrayerLog());
                                                },
                                          icon: prayerState.undoStatus ==
                                                  UndoStatus.loading
                                              ? SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                )
                                              : const Icon(Icons.undo, size: 18),
                                          label: Text(
                                            prayerState.undoStatus ==
                                                    UndoStatus.loading
                                                ? 'Undoing...'
                                                : 'Undo Last Log',
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return items;
                              }(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPrayerLogger(BuildContext context, prayer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<PrayerBloc>()),
          BlocProvider.value(value: context.read<HistoryBloc>()),
          BlocProvider.value(value: context.read<SettingsBloc>()),
        ],
        child: PrayerLoggerSheet(prayer: prayer),
      ),
    );
  }
}

/// Compact top app bar for the home page.
/// Shows app name on left and a streak badge (fire + count) on right.
class _HomeTopBar extends StatelessWidget {
  final int streak;
  final int completedToday;
  final VoidCallback onStreakTap;

  const _HomeTopBar({
    required this.streak,
    required this.completedToday,
    required this.onStreakTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(
          bottom: BorderSide(color: c.border.withValues(alpha: 0.15), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: App name + today's progress subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Falah',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: c.textPrimary,
                  fontSize: 22,
                ),
              ),
              Text(
                '$completedToday/5 prayers today',
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ],
          ),

          // Right: Streak badge pill
          GestureDetector(
            onTap: onStreakTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: c.streak,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: c.border,
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: c.onAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.onAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
