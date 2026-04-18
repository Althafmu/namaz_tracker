import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../auth/presentation/bloc/auth_state.dart';

/// User info card — avatar, name, email, streak badge, and edit icon.
class UserInfoCard extends StatelessWidget {
  final int displayStreak;
  final VoidCallback onEditTap;
  final VoidCallback? onStreakTap;

  const UserInfoCard({
    super.key,
    required this.displayStreak,
    required this.onEditTap,
    this.onStreakTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // Dark border color works well on gold/amber streak background in both themes
    final onGoldText = c.border;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        final name = (user?.firstName != null &&
                user!.firstName.isNotEmpty)
            ? '${user.firstName} ${user.lastName}'
            : (user?.username ?? 'User');
        final email = user?.email ?? 'No email';
        final initials = (user?.firstName != null &&
                user!.firstName.isNotEmpty)
            ? '${user.firstName[0]}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
            : (user?.username.isNotEmpty == true
                ? user!.username[0].toUpperCase()
                : 'U');

        return NeoCard(
          color: c.streak,
          borderColor: c.border,
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: c.border, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: c.border,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style:
                            AppTextStyles.headlineMedium.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: onGoldText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: onGoldText.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Streak badge
                        GestureDetector(
                          onTap: onStreakTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius:
                                  BorderRadius.circular(9999),
                              border: Border.all(
                                  color: c.border, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: c.border,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                    Icons.local_fire_department,
                                    color: c.primary,
                                    size: 16),
                                const SizedBox(width: 4),
                                Text(
                                    '$displayStreak Day Streak!',
                                    style: AppTextStyles.badge.copyWith(
                                      color: c.textPrimary,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Edit Icon Button
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: c.border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: c.border,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.edit,
                        size: 18, color: c.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
