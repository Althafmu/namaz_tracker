import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../bloc/prayer/prayer_bloc.dart';
import '../../../bloc/prayer/prayer_event.dart';
import '../../../bloc/prayer/prayer_state.dart';

class WeeklyCalendar extends StatefulWidget {
  const WeeklyCalendar({super.key});

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  late final ScrollController _scrollController;
  final int _daysToShow = 14;

  @override
  void initState() {
    super.initState();
    // Scroll to the end (today) by default
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        final effectiveNow = DateTime.now().subtract(const Duration(hours: 4));
        final todayKey = PrayerState.todayKey;
        final selectedKey = state.selectedDateStr ?? todayKey;

        // Generate the last 14 days
        final dates = List.generate(_daysToShow, (i) {
          return effectiveNow.subtract(Duration(days: _daysToShow - 1 - i));
        });

        return SizedBox(
          height: 80,

          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = dates[index];
              final dateKey = DateFormat('yyyy-MM-dd').format(date);
              final isSelected = dateKey == selectedKey;
              final isToday = dateKey == todayKey;

              return GestureDetector(
                onTap: () {
                  context.read<PrayerBloc>().add(SelectDate(dateKey));
                },
                child: NeoCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderWidth: isSelected ? 3 : 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.textDark
                              : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? AppColors.textDark
                              : AppColors.textDark,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.textDark
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
