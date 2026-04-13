import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/neo_button.dart';
import '../../../domain/entities/prayer.dart';
import '../../bloc/prayer/prayer_bloc.dart';
import '../../bloc/prayer/prayer_event.dart';
import '../../bloc/history/history_bloc.dart';
import '../../bloc/history/history_state.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_state.dart';
import 'widgets/jamaat_toggle.dart';
import 'widgets/location_button.dart';
import 'widgets/status_button.dart';

/// Prayer Logger Bottom Sheet — matches prayer_logger.html Stitch mockup.
class PrayerLoggerSheet extends StatefulWidget {
  final Prayer prayer;

  const PrayerLoggerSheet({super.key, required this.prayer});

  @override
  State<PrayerLoggerSheet> createState() => _PrayerLoggerSheetState();
}

class _PrayerLoggerSheetState extends State<PrayerLoggerSheet> {
  late bool _inJamaat;
  late String _selectedLocation;
  late String _status;
  String? _selectedReason;

  @override
  void initState() {
    super.initState();
    _inJamaat = widget.prayer.isCompleted ? widget.prayer.inJamaat : true;
    _selectedLocation = widget.prayer.isCompleted ? widget.prayer.location : 'mosque';
    _status = widget.prayer.isCompleted ? widget.prayer.status : 'on_time';
    _selectedReason = widget.prayer.isCompleted ? widget.prayer.reason : null;
  }

  bool _canEdit(BuildContext context) {
    final historyState = context.read<HistoryBloc>().state;
    final selectedKey = historyState.selectedDateStr ?? HistoryState.todayKey;
    final selectedDate = DateTime.parse(selectedKey);
    final today = DateTime.parse(HistoryState.todayKey);
    return today.difference(selectedDate).inDays <= 2;
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _canEdit(context);
    final c = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: c.border, width: 2),
          left: BorderSide(color: c.border, width: 2),
          right: BorderSide(color: c.border, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle ──
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Container(
              height: 6,
              width: 48,
              decoration: BoxDecoration(
                color: c.textPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log ${widget.prayer.name}',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                if (!canEdit)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.textPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'View Only',
                      style: AppTextStyles.bodyMedium.copyWith(color: c.background),
                    ),
                  ),
              ],
            ),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AbsorbPointer(
              absorbing: !canEdit,
              child: Opacity(
                opacity: canEdit ? 1.0 : 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Jama'at Toggle
                    JamaatToggle(
                      isActive: _inJamaat,
                      onTap: () => setState(() => _inJamaat = !_inJamaat),
                    ),

                    const SizedBox(height: 24),

                    // Location Selector
                    Text(
                      'LOCATION',
                      style: AppTextStyles.sectionHeader.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        LocationButton(
                          icon: Icons.mosque,
                          label: 'Mosque',
                          isSelected: _selectedLocation == 'mosque',
                          onTap: () =>
                              setState(() => _selectedLocation = 'mosque'),
                        ),
                        const SizedBox(width: 12),
                        LocationButton(
                          icon: Icons.home,
                          label: 'Home',
                          isSelected: _selectedLocation == 'home',
                          onTap: () =>
                              setState(() => _selectedLocation = 'home'),
                        ),
                        const SizedBox(width: 12),
                        LocationButton(
                          icon: Icons.work,
                          label: 'Work',
                          isSelected: _selectedLocation == 'work',
                          onTap: () =>
                              setState(() => _selectedLocation = 'work'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),

                    // Prayer Status
                    Text(
                      'STATUS',
                      style: AppTextStyles.sectionHeader.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        StatusButton(
                          icon: Icons.schedule,
                          label: 'On Time',
                          color: c.streak,
                          isSelected: _status == 'on_time',
                          onTap: () => setState(() {
                            _status = 'on_time';
                          }),
                        ),
                        const SizedBox(width: 12),
                        StatusButton(
                          icon: Icons.history,
                          label: 'Late',
                          color: c.statusLate,
                          isSelected: _status == 'late',
                          onTap: () => setState(() {
                            _status = 'late';
                          }),
                        ),
                        const SizedBox(width: 12),
                        StatusButton(
                          icon: Icons.cancel,
                          label: 'Missed',
                          color: c.statusMissed,
                          isSelected: _status == 'missed',
                          onTap: () => setState(() {
                            _status = 'missed';
                            _inJamaat = false; // Cannot pray in jamaat if missed
                          }),
                        ),
                      ],
                    ),

                    // Reasons Section (Conditional)
                    if (!_inJamaat) ...[
                      const SizedBox(height: 24),
                      Text(
                        'REASON (OPTIONAL)',
                        style: AppTextStyles.sectionHeader.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, settingsState) {
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: settingsState.missedReasons.map((reason) {
                              final isSelected = _selectedReason == reason;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedReason = isSelected ? null : reason;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? c.textPrimary : c.surface,
                                    borderRadius: BorderRadius.circular(9999),
                                    border: Border.all(color: c.border, width: 2),
                                    boxShadow: isSelected ? [] : [
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
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Action Buttons ──
          if (canEdit)
            Padding(
              padding: const EdgeInsets.all(24),
              child: widget.prayer.isCompleted
                  ? Row(
                      children: [
                        Expanded(
                          child: NeoButton(
                            text: 'Delete',
                            icon: Icons.delete_outline,
                            color: c.error,
                            onPressed: () {
                              final nav = Navigator.of(context);
                              context.read<PrayerBloc>().add(LogPrayer(
                                    prayerName: widget.prayer.name,
                                    completed: false,
                                    inJamaat: false,
                                    location: 'home',
                                    status: 'on_time',
                                    reason: null,
                                  ));
                              nav.pop();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeoButton(
                            text: 'Save',
                            icon: Icons.save_outlined,
                            onPressed: () {
                              final nav = Navigator.of(context);
                              context.read<PrayerBloc>().add(LogPrayer(
                                    prayerName: widget.prayer.name,
                                    completed: true,
                                    inJamaat: _inJamaat,
                                    location: _selectedLocation,
                                    status: _status,
                                    reason: _selectedReason,
                                  ));
                              nav.pop();
                            },
                          ),
                        ),
                      ],
                    )
                  : NeoButton(
                      text: 'Complete',
                      icon: Icons.check_circle,
                      onPressed: () {
                        final nav = Navigator.of(context);
                        context.read<PrayerBloc>().add(LogPrayer(
                              prayerName: widget.prayer.name,
                              completed: true,
                              inJamaat: _inJamaat,
                              location: _selectedLocation,
                              status: _status,
                              reason: _selectedReason,
                            ));
                        nav.pop();
                      },
                    ),
            )
          else
            const SizedBox(height: 24),
        ],
      ),
    );
  }
}
