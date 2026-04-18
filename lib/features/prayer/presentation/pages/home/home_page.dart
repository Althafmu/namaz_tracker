import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';


import '../../../../../core/services/milestone_service.dart';
import '../../../../../core/services/time_service.dart';
import '../../bloc/prayer/prayer_bloc.dart';
import '../../bloc/prayer/prayer_event.dart';
import '../../bloc/prayer/prayer_state.dart';
import '../../bloc/history/history_bloc.dart';
import '../../bloc/history/history_state.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_state.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/streak/streak_bloc.dart';
import '../prayer_logger/prayer_logger_sheet.dart';
import 'widgets/streak_header.dart';
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
      }
    });
  }

  @override
  void dispose() {
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

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    // ── Optional Advanced Modules ──
                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settingsState) {
                        return Column(
                          children: [
                            if (settingsState.intentLevel != IntentLevel.foundation) ...[
                              const StreakHeader(),
                              const SizedBox(height: 16),
                            ],
                            const WeeklyCalendar(),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    // ── Prayer List ──
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: () {
                          final now = DateTime.now();
                          final effectiveNow = TimeService.effectiveNow();
                          final isLateNight = effectiveNow.day != now.day;
                          final items = <Widget>[];

                          if (isLateNight) {
                            items.add(
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
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
                                          "Late night? Prayers are still counted towards yesterday's streak until 3:00 AM.",
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
                            );
                          }

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
                          return items;
                        }(),
                      ),
                    ),
                  ],
                ),
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
