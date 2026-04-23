import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../bloc/sunnah/sunnah_bloc.dart';
import '../../../bloc/sunnah/sunnah_event.dart';
import '../../../bloc/sunnah/sunnah_state.dart';

/// Small companion card shown below a fard prayer card to indicate
/// rawatib sunnah completion status. Tapping toggles the sunnah.
class SunnahCompanionCard extends StatefulWidget {
  /// The fard prayer name, e.g. "Fajr". Lowercased to match sunnah API types.
  final String prayerName;

  /// The date key in yyyy-MM-dd format.
  final String dateKey;

  const SunnahCompanionCard({
    super.key,
    required this.prayerName,
    required this.dateKey,
  });

  /// Prayers that have mu'akkadah rawatib sunnah.
  static const rawatibPrayers = {'Fajr', 'Dhuhr', 'Jum\'ah', 'Maghrib', 'Isha'};

  @override
  State<SunnahCompanionCard> createState() => _SunnahCompanionCardState();
}

class _SunnahCompanionCardState extends State<SunnahCompanionCard> {
  late final SunnahBloc _sunnahBloc;

  @override
  void initState() {
    super.initState();
    _sunnahBloc = GetIt.I<SunnahBloc>();
    _sunnahBloc.add(LoadDailySunnah(widget.dateKey));
  }

  @override
  void didUpdateWidget(covariant SunnahCompanionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateKey != widget.dateKey ||
        oldWidget.prayerName != widget.prayerName) {
      _sunnahBloc.add(LoadDailySunnah(widget.dateKey));
    }
  }

  void _toggle(String type) {
    HapticFeedback.lightImpact();
    _sunnahBloc.add(
      ToggleSunnahPrayer(
        prayerType: type,
        dateKey: widget.dateKey,
      ),
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

        if (widget.prayerName == 'Dhuhr' || widget.prayerName == 'Jum\'ah') {
          final isJumah = widget.prayerName == 'Jum\'ah';
          final prefix = isJumah ? 'Jum\'ah' : 'Dhuhr';
          final beforeCompleted = summary?.isCompleted('dhuhr_before') ?? false;
          final afterCompleted = summary?.isCompleted('dhuhr_after') ?? false;

          return Row(
            children: [
              Expanded(
                child: _buildToggle(
                  c: c,
                  completed: beforeCompleted,
                  label: '$prefix (2 Before)',
                  type: 'dhuhr_before',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildToggle(
                  c: c,
                  completed: afterCompleted,
                  label: '$prefix (2 After)',
                  type: 'dhuhr_after',
                ),
              ),
            ],
          );
        }

        final completed =
            summary?.isCompleted(widget.prayerName.toLowerCase()) ?? false;

        return _buildToggle(
          c: c,
          completed: completed,
          label: '${widget.prayerName} Sunnah',
          type: widget.prayerName.toLowerCase(),
        );
      },
    );
  }

  Widget _buildToggle({
    required AppColorPalette c,
    required bool completed,
    required String label,
    required String type,
  }) {
    return Material(
      color: completed ? c.jamaatLight : c.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _toggle(type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: completed ? c.jamaat : c.border,
              width: 2,
            ),
            boxShadow: completed
                ? []
                : [BoxShadow(color: c.border, offset: const Offset(2, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: completed ? c.jamaat : c.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border, width: 2),
                ),
                child: Icon(
                  completed ? Icons.check_circle : Icons.add_circle_outline,
                  size: 16,
                  color: completed ? c.background : c.jamaat,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: completed ? c.jamaat : c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.prayerName != 'Dhuhr')
                Text(
                  completed ? 'Done' : 'Tap to log',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: completed ? c.jamaat : c.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
