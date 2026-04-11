import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/prayer_time_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/neo_button.dart';
import '../../../../../core/widgets/neo_card.dart';
import '../../bloc/prayer_bloc.dart';
import '../../bloc/prayer_event.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';

class CalculationSettingsPage extends StatelessWidget {
  const CalculationSettingsPage({super.key});

  static const Map<String, String> _methodLabels = {
    'ISNA': 'ISNA (Islamic Society of NA)',
    'MWL': 'MWL (Muslim World League)',
    'Egyptian': 'Egyptian General Authority',
    'Umm Al-Qura': 'Umm Al-Qura (Makkah)',
    'Karachi': 'University of Islamic Sciences, Karachi',
    'Dubai': 'Dubai',
    'Kuwait': 'Kuwait',
    'Qatar': 'Qatar',
    'Singapore': 'Singapore',
    'Tehran': 'Tehran',
    'Turkey': 'Diyanet İşleri Başkanlığı (Turkey)',
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundLight,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Salah Times Settings',
              style: AppTextStyles.headlineMedium,
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Location Section
                  Text(
                    'Location',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  NeoCard(
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(16),
                    borderRadius: 16,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Current Location',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        NeoButton(
                          text: 'Update',
                          isFullWidth: false,
                          height: 36,
                          color: AppColors.backgroundLight,
                          textColor: AppColors.primary,
                          onPressed: () {
                            context.read<PrayerBloc>().add(
                              const LoadDailyStatus(),
                            ); // Forces GPS fetch & updates cached coordinates
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Juristic Method
                  Text(
                    'Juristic Method',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<SettingsBloc>().add(
                              const UpdateCalculationSettings(useHanafi: false),
                            );
                          },
                          child: NeoCard(
                            color: !state.useHanafi
                                ? AppColors.primaryLight
                                : AppColors.surface,
                            borderColor: !state.useHanafi
                                ? AppColors.primary
                                : AppColors.border,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Standard',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: !state.useHanafi
                                        ? AppColors.border
                                        : AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Shafi, Maliki, Hanbali',
                                  style: AppTextStyles.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<SettingsBloc>().add(
                              const UpdateCalculationSettings(useHanafi: true),
                            );
                          },
                          child: NeoCard(
                            color: state.useHanafi
                                ? AppColors.primaryLight
                                : AppColors.surface,
                            borderColor: state.useHanafi
                                ? AppColors.primary
                                : AppColors.border,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Hanafi',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: state.useHanafi
                                        ? AppColors.border
                                        : AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Later Asr time',
                                  style: AppTextStyles.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Calculation Method
                  Text(
                    'Calculation Method',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  NeoCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppColors.surface,
                    borderRadius: 16,
                    borderColor: AppColors.border,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.calculationMethod,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.expand_more,
                          color: AppColors.textDark,
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        dropdownColor: AppColors.surface,
                        items: PrayerTimeService.calculationMethods.keys
                            .map(
                              (key) => DropdownMenuItem(
                                value: key,
                                child: Text(
                                  _methodLabels[key] ?? key,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsBloc>().add(
                              UpdateCalculationSettings(
                                calculationMethod: value,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Prayer Time Adjustment Placeholder
                  GestureDetector(
                    onTap: () {
                      _showPrayerTimeAdjustmentSheet(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.border,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prayer time adjustment',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPrayerTimeAdjustmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return _PrayerTimeAdjustmentSheetContent(
              initialOffsets: state.manualOffsets,
            );
          },
        );
      },
    );
  }
}

class _PrayerTimeAdjustmentSheetContent extends StatefulWidget {
  final Map<String, int> initialOffsets;

  const _PrayerTimeAdjustmentSheetContent({required this.initialOffsets});

  @override
  State<_PrayerTimeAdjustmentSheetContent> createState() =>
      _PrayerTimeAdjustmentSheetContentState();
}

class _PrayerTimeAdjustmentSheetContentState
    extends State<_PrayerTimeAdjustmentSheetContent> {
  late Map<String, int> _localOffsets;
  bool _hasChanges = false;

  final List<String> prayers = [
    'Fajr',
    'Sunrise',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  @override
  void initState() {
    super.initState();
    _localOffsets = Map<String, int>.from(widget.initialOffsets);
  }

  void _updateOffset(String prayer, int newValue) {
    setState(() {
      _localOffsets[prayer] = newValue;
      _hasChanges = _checkChanges();
    });
  }

  bool _checkChanges() {
    for (final p in prayers) {
      final initial = widget.initialOffsets[p] ?? 0;
      final current = _localOffsets[p] ?? 0;
      if (initial != current) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 2),
          left: BorderSide(color: AppColors.border, width: 2),
          right: BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Prayer time adjustment',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: prayers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final prayerName = prayers[index];
                final currentOffset = _localOffsets[prayerName] ?? 0;

                return NeoCard(
                  color: AppColors.surface,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          prayerName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.textDark,
                            ),
                            onPressed: currentOffset > -120
                                ? () => _updateOffset(prayerName, currentOffset - 1)
                                : null,
                          ),
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '${currentOffset > 0 ? '+' : ''}$currentOffset m',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.textDark,
                            ),
                            onPressed: currentOffset < 120
                                ? () => _updateOffset(prayerName, currentOffset + 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Positive values delay the prayer time, negative values advance it.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          NeoButton(
            text: 'Save Adjustments',
            disabled: !_hasChanges,
            onPressed: _hasChanges
                ? () {
                    context.read<SettingsBloc>().add(
                          UpdateManualOffsets(manualOffsets: _localOffsets),
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prayer adjustments applied successfully'),
                      ),
                    );
                  }
                : null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
