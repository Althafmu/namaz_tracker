import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/settings/settings_event.dart';
import '../../../bloc/sunnah/sunnah_bloc.dart';
import '../../../bloc/sunnah/sunnah_event.dart';
import '../../../bloc/sunnah/sunnah_state.dart';

class SunnahTrackerCard extends StatefulWidget {
  final String dateKey;

  const SunnahTrackerCard({super.key, required this.dateKey});

  @override
  State<SunnahTrackerCard> createState() => _SunnahTrackerCardState();
}

class _SunnahTrackerCardState extends State<SunnahTrackerCard> {
  static const _extraPracticeItems = <({String prayerType, String label})>[
    (prayerType: 'witr', label: 'Witr'),
    (prayerType: 'dhuha', label: 'Dhuha'),
    (prayerType: 'tahajjud', label: 'Tahajjud'),
  ];

  late final SunnahBloc _sunnahBloc;

  @override
  void initState() {
    super.initState();
    _sunnahBloc = GetIt.I<SunnahBloc>();
    _sunnahBloc.add(LoadDailySunnah(widget.dateKey));
  }

  @override
  void didUpdateWidget(covariant SunnahTrackerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateKey != widget.dateKey) {
      _sunnahBloc.add(LoadDailySunnah(widget.dateKey));
    }
  }

  void _togglePrayer(String prayerType) {
    _sunnahBloc.add(
      ToggleSunnahPrayer(prayerType: prayerType, dateKey: widget.dateKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return BlocBuilder<SunnahBloc, SunnahState>(
      bloc: _sunnahBloc,
      buildWhen: (prev, curr) =>
          prev.dailyCache[widget.dateKey] != curr.dailyCache[widget.dateKey],
      builder: (context, state) {
        final summary = state.dailyCache[widget.dateKey];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border, width: 2),
            boxShadow: [BoxShadow(color: c.border, offset: const Offset(4, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.jamaatLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border, width: 2),
                ),
                child: Icon(Icons.auto_awesome, size: 18, color: c.jamaat),
              ),
              const SizedBox(width: 12),
              Text(
                'Extra',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: _extraPracticeItems.map((item) {
                    final completed =
                        summary?.isCompleted(item.prayerType) ?? false;

                    return GestureDetector(
                      onTap: () => _togglePrayer(item.prayerType),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: completed ? c.primary : c.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.border, width: 2),
                          boxShadow: completed
                              ? []
                              : [
                                  BoxShadow(
                                    color: c.border,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              completed
                                  ? Icons.check_circle
                                  : Icons.add_circle_outline,
                              size: 16,
                              color: completed ? c.background : c.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.label,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: completed ? c.background : c.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SunnahEnableCard extends StatelessWidget {
  const SunnahEnableCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border, width: 2),
        boxShadow: [BoxShadow(color: c.border, offset: const Offset(4, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.jamaatLight,
              shape: BoxShape.circle,
              border: Border.all(color: c.border, width: 2),
            ),
            child: Icon(Icons.auto_awesome, color: c.jamaat),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Sunnah to Home',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Turn on extra Growth-mode practice tracking for rawatib, Witr, Dhuha, and Tahajjud.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              context.read<SettingsBloc>().add(const UpdateSunnahEnabled(true));
            },
            child: Text(
              'Enable',
              style: AppTextStyles.bodySmall.copyWith(
                color: c.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
