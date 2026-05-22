import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../features/prayer/presentation/bloc/settings/settings_bloc.dart';
import '../../features/prayer/presentation/bloc/settings/settings_event.dart';
import '../../features/prayer/presentation/bloc/settings/settings_state.dart';
import '../../features/prayer/presentation/pages/home/widgets/milestone_celebration_sheet.dart';
import 'spiritual_messages.dart';

class MilestoneService {
  static const List<int> _milestoneThresholds = [3, 7, 14, 21, 30];

  static String getMilestoneMessage(int milestone, IntentLevel intent) {
    final base = switch (milestone) {
      3 => 'Three days of return — Allah loves the one who keeps returning.',
      7 => 'A week of consistency — your record with Allah is being written.',
      14 => 'Two weeks of commitment — your consistency is noticed.',
      21 => 'Twenty-one days of showing up — this is how habits are built.',
      30 => 'One month of consistency — this is devotion made real.',
      _ => 'Milestone reached.',
    };

    final intentMsg = switch (intent) {
      IntentLevel.foundation => ' Keep going — Allah is the one who accepts the small steps.',
      IntentLevel.strengthening => ' Your momentum is building — maintain it.',
      IntentLevel.growth => ' You are fulfilling your covenant — guard it well.',
    };

    return '$base$intentMsg';
  }

  void checkAndShowMilestone(BuildContext context, int currentStreak) {
    final settingsBloc = GetIt.I<SettingsBloc>();
    final state = settingsBloc.state;

    for (final milestone in _milestoneThresholds) {
      if (currentStreak >= milestone && !state.milestones.isShown(milestone)) {
        settingsBloc.add(MarkMilestoneShown(milestone));
        _showMilestoneToast(context, milestone, state.intentLevel);
        break;
      }
    }
  }

  void _showMilestoneToast(BuildContext context, int milestone, IntentLevel intent) {
    final message = getMilestoneMessage(milestone, intent);
    MilestoneCelebrationBottomSheet.show(context, milestone, message);
  }

  void showQadaReinforcement(BuildContext context) {
    debugPrint('[MilestoneService] Qada success - You returned and prayed. That is what matters.');
  }

  static bool shouldShowUpgradePrompt(SettingsState state, int currentStreak) {
    if (!state.upgradePrompt.canShow) return false;

    if (state.intentLevel == IntentLevel.foundation && currentStreak >= 7) {
      return true;
    }
    if (state.intentLevel == IntentLevel.strengthening && currentStreak >= 21) {
      return true;
    }
    return false;
  }

  static String getUpgradePromptMessage(SettingsState state, int currentStreak) {
    return SpiritualMessages.buildUpgradeMessage(state.intentLevel, currentStreak);
  }
}