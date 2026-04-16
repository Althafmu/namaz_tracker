import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_button.dart';
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

  final List<String> _reasons = [
    'Travel',
    'Sickness',
    'Period',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: c.border,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.statusAlone.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 48,
                color: c.statusAlone,
              ),
            ),

            const SizedBox(height: 20),

            // ── Title ──
            Text(
              'Mark Day as Excused',
              style: AppTextStyles.headlineMedium.copyWith(
                color: c.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // ── Date ──
            Text(
              widget.date,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // ── Description ──
            Text(
              'Your streak will be frozen for this day. Excused days are excluded from analytics.',
              style: AppTextStyles.bodySmall.copyWith(
                color: c.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // ── Reason Selection ──
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
              children: _reasons.map((reason) {
                final isSelected = _selectedReason == reason.toLowerCase();
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedReason = reason.toLowerCase();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? c.primary : c.surface,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: c.border, width: 2),
                      boxShadow: isSelected
                          ? []
                          : [
                              BoxShadow(color: c.border, offset: const Offset(2, 2)),
                            ],
                    ),
                    child: Text(
                      reason,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? c.background : c.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ──
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(false),
                      color: c.surface,
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
    );
  }

  Future<void> _markAsExcused(BuildContext context) async {
    if (_selectedReason == null) return;

    setState(() => _isLoading = true);

    final streakBloc = context.read<StreakBloc>();
    final navigator = Navigator.of(context);

    streakBloc.add(SetExcusedDay(
      date: widget.date,
      reason: _selectedReason,
    ));

    // Wait for the state to update
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      navigator.pop(true);
    }
  }

  /// Shows the excused day dialog and returns true if confirmed.
  static Future<bool?> show(BuildContext context, {required String date}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ExcusedDayDialog(date: date),
    );
  }
}