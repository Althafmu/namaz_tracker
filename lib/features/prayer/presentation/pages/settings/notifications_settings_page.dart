import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart' as fp;

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/neo_button.dart';
import '../../../../../core/widgets/neo_card.dart';
import '../../../../../core/widgets/neo_toggle.dart';
import '../../../domain/entities/prayer_notification_config.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

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
            title: Text('Notifications', style: AppTextStyles.headlineMedium),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Global Sound Setting
                  Text('Global Alarm Sound',
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.muted)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _showSoundPicker(context, state.alarmSound),
                    borderRadius: BorderRadius.circular(16),
                    child: NeoCard(
                      color: AppColors.surface,
                      padding: const EdgeInsets.all(16),
                      borderRadius: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.music_note,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Alarm Sound',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold)),
                                Text(_getAlarmSoundDisplayName(state.alarmSound),
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.muted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Per-Prayer Settings
                  Text('Per-Prayer Notifications',
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.muted)),
                  const SizedBox(height: 8),
                  ..._buildPrayerCards(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getAlarmSoundDisplayName(String sound) {
    if (sound == 'system') return 'System Default Alarm';
    if (sound == 'hayya_ala_salat') return 'Soft Adhan (Hayya Ala Salat)';
    if (sound == 'namaz_reminder') return 'Smooth Reminder';
    return 'Custom Audio File';
  }

  void _showSoundPicker(BuildContext context, String currentSound) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.border, width: 2),
      ),
      builder: (sheetContext) {
        return SoundPickerBottomSheet(
          initialSound: currentSound,
          onSoundSelected: (String newSound) {
            context.read<SettingsBloc>().add(
                  UpdateGlobalNotificationSettings(alarmSound: newSound),
                );
          },
        );
      },
    );
  }

  List<Widget> _buildPrayerCards(BuildContext context, SettingsState state) {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return prayers.map((prayer) {
      final config =
          state.prayerConfigs[prayer] ?? const PrayerNotificationConfig();
      return _PrayerNotificationCard(prayer: prayer, config: config);
    }).toList();
  }
}

class _PrayerNotificationCard extends StatelessWidget {
  final String prayer;
  final PrayerNotificationConfig config;

  const _PrayerNotificationCard({
    required this.prayer,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeoCard(
        color: AppColors.surface,
        borderRadius: 24,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(prayer,
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildToggleRow(
                context,
                title: 'Adhan Alerts',
                subtitle: 'Push notifications at prayer time',
                icon: Icons.notifications_active,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryLight,
                value: config.adhanAlerts,
                onChanged: (val) {
                  context.read<SettingsBloc>().add(
                        UpdatePrayerNotificationConfig(
                          prayerName: prayer,
                          config: config.copyWith(adhanAlerts: val),
                        ),
                      );
                },
              ),
              const Divider(color: AppColors.border, thickness: 2),
              _buildToggleRow(
                context,
                title: 'Prayer Reminder',
                subtitle: 'Customizable alert for this prayer',
                icon: Icons.timer,
                iconColor: AppColors.jamaat,
                iconBg: AppColors.jamaatLight,
                value: config.reminderAlerts,
                onChanged: (val) {
                  context.read<SettingsBloc>().add(
                        UpdatePrayerNotificationConfig(
                          prayerName: prayer,
                          config: config.copyWith(reminderAlerts: val),
                        ),
                      );
                },
              ),
              if (config.reminderAlerts)
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: _ReminderSettingsUI(prayer: prayer, config: config),
                ),
              const Divider(color: AppColors.border, thickness: 2),
              _buildToggleRow(
                context,
                title: 'Streak Protection',
                subtitle: 'Alert if missing last prayer',
                icon: Icons.shield,
                iconColor: AppColors.streak,
                iconBg: AppColors.streakLight,
                value: config.streakProtection,
                onChanged: (val) {
                  context.read<SettingsBloc>().add(
                        UpdatePrayerNotificationConfig(
                          prayerName: prayer,
                          config: config.copyWith(streakProtection: val),
                        ),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          NeoToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ReminderSettingsUI extends StatefulWidget {
  final String prayer;
  final PrayerNotificationConfig config;

  const _ReminderSettingsUI({
    required this.prayer,
    required this.config,
  });

  @override
  State<_ReminderSettingsUI> createState() => _ReminderSettingsUIState();
}

class _ReminderSettingsUIState extends State<_ReminderSettingsUI> {
  late int _minutes;
  late bool _isBefore;

  @override
  void initState() {
    super.initState();
    _minutes = widget.config.reminderMinutes;
    _isBefore = widget.config.reminderIsBefore;
  }

  @override
  void didUpdateWidget(_ReminderSettingsUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.reminderMinutes != widget.config.reminderMinutes ||
        oldWidget.config.reminderIsBefore != widget.config.reminderIsBefore) {
      _minutes = widget.config.reminderMinutes;
      _isBefore = widget.config.reminderIsBefore;
    }
  }

  bool get _hasChanges =>
      _minutes != widget.config.reminderMinutes ||
      _isBefore != widget.config.reminderIsBefore;

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
                  if (_minutes > 1) setState(() => _minutes--);
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Text('$_minutes mins',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.textDark),
                onPressed: () {
                  if (_minutes < 120) setState(() => _minutes++);
                },
              ),
              const Spacer(),
              NeoButton(
                text: _isBefore ? 'Before' : 'After',
                isFullWidth: false,
                height: 40,
                color: _isBefore ? AppColors.jamaat : AppColors.primary,
                onPressed: () => setState(() => _isBefore = !_isBefore),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NeoButton(
            text: _hasChanges ? 'Save Reminder' : '✓ Saved',
            color: _hasChanges ? AppColors.primary : AppColors.success,
            icon: _hasChanges ? Icons.save : Icons.check_circle,
            onPressed: () {
              context.read<SettingsBloc>().add(
                    UpdatePrayerNotificationConfig(
                      prayerName: widget.prayer,
                      config: widget.config.copyWith(
                        reminderMinutes: _minutes,
                        reminderIsBefore: _isBefore,
                      ),
                    ),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '✅ ${widget.prayer} reminder set: $_minutes mins ${_isBefore ? "before" : "after"}'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Global Sound Picker (Copied and modified from settings_sheets.dart)
class SoundPickerBottomSheet extends StatefulWidget {
  final String initialSound;
  final ValueChanged<String> onSoundSelected;

  const SoundPickerBottomSheet({
    super.key,
    required this.initialSound,
    required this.onSoundSelected,
  });

  @override
  State<SoundPickerBottomSheet> createState() => _SoundPickerBottomSheetState();
}

class _SoundPickerBottomSheetState extends State<SoundPickerBottomSheet> {
  late AudioPlayer _audioPlayer;
  String? _currentlyPlaying;

  final List<Map<String, String>> _availableSounds = [
    {'id': 'system', 'name': 'System Default Alarm'},
    {'id': 'hayya_ala_salat', 'name': 'Hayya Ala Salat'},
    {'id': 'namaz_reminder', 'name': 'Hayya Ala Salat-1'},
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String soundId) async {
    if (_currentlyPlaying == soundId) {
      await _audioPlayer.stop();
      setState(() => _currentlyPlaying = null);
      return;
    }

    try {
      if (soundId == 'system') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Cannot preview system default audio here.'),
              duration: Duration(seconds: 1)),
        );
        return;
      }

      if (soundId.startsWith('/')) {
        await _audioPlayer.setSourceDeviceFile(soundId);
      } else {
        await _audioPlayer.setSourceAsset('$soundId.mp3');
      }

      await _audioPlayer.resume();
      if (!mounted) return;
      setState(() => _currentlyPlaying = soundId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')));
    }
  }

  Future<void> _pickCustomAudio() async {
    try {
      fp.FilePickerResult? result =
          await fp.FilePicker.pickFiles(type: fp.FileType.audio);
      if (result != null && result.files.single.path != null) {
        widget.onSoundSelected(result.files.single.path!);
        if (mounted) {
            Navigator.pop(context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Select Reminder Sound', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),
          ..._availableSounds.map((s) => _buildSoundRow(s['id']!, s['name']!)),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, thickness: 2),
          const SizedBox(height: 8),
          if (widget.initialSound.startsWith('/'))
            _buildSoundRow(widget.initialSound, 'Selected Custom Audio File'),
          ListTile(
            leading: const Icon(Icons.file_upload, color: AppColors.primary),
            title: Text('Pick Custom Audio File...',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
            onTap: _pickCustomAudio,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundRow(String id, String name) {
    final isSelected = widget.initialSound == id;
    final isPlaying = _currentlyPlaying == id;
    String displayName = id.startsWith('/') ? id.split('/').last : name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: () {
          widget.onSoundSelected(id);
          Navigator.pop(context);
        },
        leading: IconButton(
          icon: Icon(
            isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
            color: isPlaying ? AppColors.error : AppColors.primary,
            size: 32,
          ),
          onPressed: () => _playSound(id),
        ),
        title: Text(displayName,
            style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : null,
      ),
    );
  }
}
