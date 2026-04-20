import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_button.dart';
import '../../../bloc/prayer/prayer_bloc.dart';
import '../../../bloc/prayer/prayer_event.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/streak/streak_bloc.dart';
import '../../../bloc/streak/streak_event.dart';

/// Dialog for marking a day as excused (travel, sickness, women's period).
/// Excused days freeze the streak and are excluded from analytics.
///
/// Phase 2: Excused Mode
class ExcusedDayDialog extends StatefulWidget {
  final String date;

  const ExcusedDayDialog({super.key, required this.date});

  @override
  State<ExcusedDayDialog> createState() => _ExcusedDayDialogState();
}

class _ExcusedDayDialogState extends State<ExcusedDayDialog> {
  String? _selectedReason;
  bool _isLoading = false;

  final List<String> _reasons = ['Travel', 'Sickness', 'Period', 'Other'];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isActive = context.select<SettingsBloc, bool>(
      (bloc) => bloc.state.excusedDays.contains(widget.date),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 360,
              maxHeight: constraints.maxHeight,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: c.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border, width: 2),
                boxShadow: [
                  BoxShadow(color: c.border, offset: const Offset(4, 4)),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.statusAlone.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isActive ? Icons.event_available : Icons.event_busy,
                        size: 44,
                        color: c.statusAlone,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isActive ? 'Excused Mode Active' : 'Mark Day as Excused',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: c.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.date,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isActive
                          ? 'This day is currently frozen for streak purposes. Resume logging if your day changed and you want to track prayers normally again.'
                          : 'Your streak will be frozen for this day. Excused days are excluded from analytics and prayer reminders.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isActive) ...[
                      const SizedBox(height: 20),
                      Text(
                        'REASON',
                        style: AppTextStyles.sectionHeader.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: _reasons.map((reason) {
                          final isSelected =
                              _selectedReason == reason.toLowerCase();
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedReason = reason.toLowerCase();
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? c.primary : c.surface,
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(color: c.border, width: 2),
                                boxShadow: isSelected
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: c.border,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                              ),
                              child: Text(
                                reason,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isSelected
                                      ? c.background
                                      : c.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (isActive)
                      Row(
                        children: [
                          Expanded(
                            child: NeoButton(
                              text: 'Close',
                              onPressed: () => Navigator.of(context).pop(false),
                              color: c.surface,
                              textColor: c.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: NeoButton(
                              text: 'Resume',
                              icon: Icons.refresh,
                              onPressed: () => _resumeLogging(context),
                              color: c.primary,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: NeoButton(
                              text: 'Cancel',
                              onPressed: () => Navigator.of(context).pop(false),
                              color: c.surface,
                              textColor: c.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: NeoButton(
                              text: 'Confirm',
                              icon: Icons.check,
                              onPressed: _selectedReason != null
                                  ? () => _markAsExcused(context)
                                  : null,
                              color: c.statusAlone,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _markAsExcused(BuildContext context) async {
    if (_selectedReason == null) return;

    setState(() => _isLoading = true);

    final streakBloc = context.read<StreakBloc>();
    final prayerBloc = context.read<PrayerBloc>();
    final navigator = Navigator.of(context);

    streakBloc.add(SetExcusedDay(date: widget.date, reason: _selectedReason));

    await streakBloc.stream.firstWhere((state) => !state.isLoading);

    prayerBloc.add(const LoadDailyStatus());

    if (mounted) {
      navigator.pop(true);
    }
  }

  Future<void> _resumeLogging(BuildContext context) async {
    setState(() => _isLoading = true);
    final navigator = Navigator.of(context);

    context.read<PrayerBloc>().add(ResumeExcusedDay(dateKey: widget.date));

    await Future.delayed(const Duration(milliseconds: 250));

    if (mounted) {
      navigator.pop(true);
    }
  }
}
