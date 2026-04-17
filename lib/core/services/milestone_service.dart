import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../features/prayer/presentation/bloc/settings/settings_bloc.dart';
import '../../features/prayer/presentation/bloc/settings/settings_event.dart';
import '../../features/prayer/presentation/bloc/settings/settings_state.dart';

class MilestoneService {
  static const List<int> _milestoneThresholds = [3, 7, 14, 21, 30];

  static const Map<int, String> _milestoneMessages = {
    3: 'Good start! Keep the momentum going.',
    7: 'Strong consistency. You\'re building a habit.',
    14: 'Habit forming. You\'re doing great!',
    21: 'Three weeks strong. This is becoming second nature.',
    30: 'One month! Your dedication is inspiring.',
  };

  void checkAndShowMilestone(BuildContext context, int currentStreak) {
    final settingsBloc = GetIt.I<SettingsBloc>();
    final state = settingsBloc.state;

    for (final milestone in _milestoneThresholds) {
      if (currentStreak >= milestone && !state.milestones.isShown(milestone)) {
        settingsBloc.add(MarkMilestoneShown(milestone));
        _showMilestoneToast(context, milestone);
        break;
      }
    }
  }

  void _showMilestoneToast(BuildContext context, int milestone) {
    final message = _milestoneMessages[milestone];
    if (message == null) return;

    debugPrint('[MilestoneService] Milestone reached: $milestone days - $message');
  }

  void showQadaReinforcement(BuildContext context) {
    debugPrint('[MilestoneService] Qada success - You stayed consistent. Keep going.');
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
}