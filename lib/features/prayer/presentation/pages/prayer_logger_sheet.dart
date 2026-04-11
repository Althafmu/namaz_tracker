import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../domain/entities/prayer.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 2),
          left: BorderSide(color: AppColors.border, width: 2),
          right: BorderSide(color: AppColors.border, width: 2),
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
                color: AppColors.textDark.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Log ${widget.prayer.name}',
                style: AppTextStyles.headlineLarge,
              ),
            ),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Jama'at Toggle
                _JamaatToggleButton(
                  isActive: _inJamaat,
                  onTap: () => setState(() => _inJamaat = !_inJamaat),
                ),

                const SizedBox(height: 24),

                // Location Selector
                Text(
                  'LOCATION',
                  style: AppTextStyles.sectionHeader,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _LocationButton(
                      icon: Icons.mosque,
                      label: 'Mosque',
                      isSelected: _selectedLocation == 'mosque',
                      onTap: () =>
                          setState(() => _selectedLocation = 'mosque'),
                    ),
                    const SizedBox(width: 12),
                    _LocationButton(
                      icon: Icons.home,
                      label: 'Home',
                      isSelected: _selectedLocation == 'home',
                      onTap: () =>
                          setState(() => _selectedLocation = 'home'),
                    ),
                    const SizedBox(width: 12),
                    _LocationButton(
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
                  style: AppTextStyles.sectionHeader,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatusButton(
                      icon: Icons.schedule,
                      label: 'On Time',
                      color: AppColors.streak,
                      isSelected: _status == 'on_time',
                      onTap: () => setState(() {
                        _status = 'on_time';
                      }),
                    ),
                    const SizedBox(width: 12),
                    _StatusButton(
                      icon: Icons.history,
                      label: 'Late',
                      color: AppColors.statusLate,
                      isSelected: _status == 'late',
                      onTap: () => setState(() {
                        _status = 'late';
                      }),
                    ),
                    const SizedBox(width: 12),
                    _StatusButton(
                      icon: Icons.cancel,
                      label: 'Missed',
                      color: AppColors.statusMissed,
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
                    style: AppTextStyles.sectionHeader,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Work', 'Travel', 'Sleep', 'Family', 'Other'
                    ].map((reason) {
                      final isSelected = _selectedReason == reason;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedReason = isSelected ? null : reason;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.textDark : AppColors.surface,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: AppColors.border, width: 2),
                            boxShadow: isSelected ? [] : const [
                              BoxShadow(color: AppColors.border, offset: Offset(2, 2)),
                            ],
                          ),
                          child: Text(
                            reason,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected ? Colors.white : AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // ── Action Buttons ──
          Padding(
            padding: const EdgeInsets.all(24),
            child: widget.prayer.isCompleted
                ? Row(
                    children: [
                      Expanded(
                        child: NeoButton(
                          text: 'Delete',
                          icon: Icons.delete_outline,
                          color: AppColors.error,
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
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(
            isSelected ? 2.0 : 0.0,
            isSelected ? 2.0 : 0.0,
            0.0,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.border,
                offset: Offset(isSelected ? 0.0 : 4.0, isSelected ? 0.0 : 4.0),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.textDark, size: 24),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Jama'at toggle button — rounded pill with teal background when active.
class _JamaatToggleButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;

  const _JamaatToggleButton({required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        color: isActive ? AppColors.jamaat : AppColors.surface,
        borderRadius: 9999,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.group, color: AppColors.textDark, size: 30),
                const SizedBox(width: 12),
                Text(
                  "Prayed in Jama'at",
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
            Row(
              children: [
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.streak,
                      borderRadius: BorderRadius.circular(9999),
                      border:
                          Border.all(color: AppColors.border, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.border,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text('+10XP', style: AppTextStyles.badge),
                  ),
                const SizedBox(width: 12),
                // Mini toggle
                Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.textDark : AppColors.muted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: isActive
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Location selector button.
class _LocationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LocationButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(
            isSelected ? 2.0 : 0.0,
            isSelected ? 2.0 : 0.0,
            0.0,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.streak : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.border,
                offset: Offset(isSelected ? 0.0 : 4.0, isSelected ? 0.0 : 4.0),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.textDark, size: 24),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
