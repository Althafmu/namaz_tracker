import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/prayer/prayer_bloc.dart';
import '../../bloc/prayer/prayer_state.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../prayer_logger/prayer_logger_sheet.dart';
import 'widgets/streak_header.dart';
import 'widgets/prayer_card.dart';
import 'widgets/motivational_banner.dart';
import 'widgets/weekly_calendar.dart';

/// Dashboard / Home Page — matches dashboard.html Stitch mockup.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                // ── Streak Header ──
                StreakHeader(streak: state.streak.currentStreak),

                const SizedBox(height: 16),

                // ── Weekly Calendar ──
                const WeeklyCalendar(),

                const SizedBox(height: 24),

                // ── Prayer List ──
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: state.displayPrayers.length + 1, // +1 for quote
                    itemBuilder: (context, index) {
                      // Insert motivational quote after Maghrib (index 3)
                      if (index == 4) {
                        return const MotivationalBanner();
                      }
                      final prayerIndex = index > 4 ? index - 1 : index;
                      if (prayerIndex >= state.displayPrayers.length) return null;
                      final prayer = state.displayPrayers[prayerIndex];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16, right: 6),
                        child: PrayerCard(
                          prayer: prayer,
                          onTap: () => _showPrayerLogger(context, prayer),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
          BlocProvider.value(value: context.read<SettingsBloc>()),
        ],
        child: PrayerLoggerSheet(prayer: prayer),
      ),
    );
  }
}
