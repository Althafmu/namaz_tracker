import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/neo_button.dart';
import '../../../../../core/widgets/neo_card.dart';
import '../../../../../core/widgets/neo_text_field.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';

class ReasonsSettingsPage extends StatefulWidget {
  const ReasonsSettingsPage({super.key});

  @override
  State<ReasonsSettingsPage> createState() => _ReasonsSettingsPageState();
}

class _ReasonsSettingsPageState extends State<ReasonsSettingsPage> {
  final TextEditingController _reasonController = TextEditingController();

  void _addReason(BuildContext context, List<String> currentReasons) {
    final reason = _reasonController.text.trim();
    if (reason.isNotEmpty &&
        !currentReasons
            .map((e) => e.toLowerCase())
            .contains(reason.toLowerCase())) {
      final updated = List<String>.from(currentReasons)..add(reason);
      context.read<SettingsBloc>().add(
        UpdateMissedReasons(missedReasons: updated),
      );
      _reasonController.clear();
    }
  }

  void _removeReason(
    BuildContext context,
    List<String> currentReasons,
    String reason,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Reason'),
        content: Text('Remove "$reason" from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final updated = List<String>.from(currentReasons)..remove(reason);
      context.read<SettingsBloc>().add(
        UpdateMissedReasons(missedReasons: updated),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Reasons',
          style: AppTextStyles.headlineMedium.copyWith(color: c.textPrimary),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final reasons = state.missedReasons;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Reasons',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add or remove reasons for why you missed a prayer or prayed late.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: NeoTextField(
                        label: 'New Reason',
                        hint: 'e.g., Traffic, Sick...',
                        controller: _reasonController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: NeoButton(
                        text: 'Add',
                        isFullWidth: false,
                        icon: Icons.add,
                        onPressed: () => _addReason(context, reasons),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.separated(
                    itemCount: reasons.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final reason = reasons[index];
                      return NeoCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: c.surface,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              reason,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: c.error),
                              onPressed: () =>
                                  _removeReason(context, reasons, reason),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
