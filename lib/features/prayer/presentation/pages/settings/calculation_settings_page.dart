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
            title: Text('Salah Times Settings', style: AppTextStyles.headlineMedium),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Location Section
                  Text('Location',
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold, color: AppColors.muted)),
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
                          child: Text('Current Location',
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ),
                        NeoButton(
                          text: 'Update',
                          isFullWidth: false,
                          height: 36,
                          color: AppColors.backgroundLight,
                          textColor: AppColors.primary,
                          onPressed: () {
                            context.read<PrayerBloc>().add(const LoadDailyStatus()); // Forces GPS fetch & updates cached coordinates
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Juristic Method
                  Text('Juristic Method',
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<SettingsBloc>().add(const UpdateCalculationSettings(useHanafi: false));
                          },
                          child: NeoCard(
                            color: !state.useHanafi ? AppColors.primaryLight : AppColors.surface,
                            borderColor: !state.useHanafi ? AppColors.primary : AppColors.border,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            child: Column(
                              children: [
                                Text('Standard', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: !state.useHanafi ? AppColors.primaryDark : AppColors.textDark)),
                                const SizedBox(height: 4),
                                Text('Shafi, Maliki, Hanbali', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<SettingsBloc>().add(const UpdateCalculationSettings(useHanafi: true));
                          },
                          child: NeoCard(
                            color: state.useHanafi ? AppColors.primaryLight : AppColors.surface,
                            borderColor: state.useHanafi ? AppColors.primary : AppColors.border,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            child: Column(
                              children: [
                                Text('Hanafi', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: state.useHanafi ? AppColors.primaryDark : AppColors.textDark)),
                                const SizedBox(height: 4),
                                Text('Later Asr time', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Calculation Method
                  Text('Calculation Method',
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.calculationMethod,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more,
                            color: AppColors.textDark),
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark),
                        dropdownColor: AppColors.surface,
                        items: PrayerTimeService.calculationMethods.keys
                            .map((key) => DropdownMenuItem(
                                  value: key,
                                  child: Text(_methodLabels[key] ?? key,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsBloc>().add(
                                UpdateCalculationSettings(
                                    calculationMethod: value));
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
                              color: AppColors.border, offset: Offset(4, 4))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Prayer time adjustment',
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textDark),
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
    final List<String> prayers = [
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
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
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                      Text('Prayer time adjustment',
                          style: AppTextStyles.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: prayers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final prayerName = prayers[index];
                        final currentOffset = state.manualOffsets[prayerName] ?? 0;

                        return NeoCard(
                          color: AppColors.surface,
                          borderRadius: 16,
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(prayerName,
                                  style: AppTextStyles.bodyLarge
                                      .copyWith(fontWeight: FontWeight.bold)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${currentOffset > 0 ? '+' : ''}$currentOffset mins',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.expand_more,
                                      color: AppColors.muted),
                                ],
                              ),
                              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(top: 0),
                              children: [
                                _ManualOffsetUI(prayer: prayerName, offset: currentOffset),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ManualOffsetUI extends StatefulWidget {
  final String prayer;
  final int offset;

  const _ManualOffsetUI({
    required this.prayer,
    required this.offset,
  });

  @override
  State<_ManualOffsetUI> createState() => _ManualOffsetUIState();
}

class _ManualOffsetUIState extends State<_ManualOffsetUI> {
  late int _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.offset;
  }

  @override
  void didUpdateWidget(_ManualOffsetUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offset != widget.offset) {
      _offset = widget.offset;
    }
  }

  bool get _hasChanges => _offset != widget.offset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.textDark),
                onPressed: () {
                  if (_offset > -120) setState(() => _offset--);
                },
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Text('${_offset > 0 ? '+' : ''}$_offset mins',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.textDark),
                onPressed: () {
                  if (_offset < 120) setState(() => _offset++);
                },
              ),
              const SizedBox(width: 8),
              NeoButton(
                text: 'Save',
                isFullWidth: false,
                height: 36,
                disabled: !_hasChanges,
                onPressed: _hasChanges
                    ? () {
                        final currentOffsets = Map<String, int>.from(
                            context.read<SettingsBloc>().state.manualOffsets);
                        currentOffsets[widget.prayer] = _offset;
                        context
                            .read<SettingsBloc>()
                            .add(UpdateManualOffsets(offsets: currentOffsets));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Adjusted ${widget.prayer} by $_offset mins')),
                        );
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Positive values delay the prayer time, negative values advance it.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
