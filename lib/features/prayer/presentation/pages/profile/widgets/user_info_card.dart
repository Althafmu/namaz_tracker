import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../auth/presentation/bloc/auth_state.dart';

/// User info card — avatar, name, email, streak badge, and edit icon.
class UserInfoCard extends StatelessWidget {
  final int currentStreak;
  final VoidCallback onEditTap;

  const UserInfoCard({
    super.key,
    required this.currentStreak,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
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
          color: AppColors.streak,
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
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.border, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style:
                            AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
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
                            style: AppTextStyles.headlineMedium),
                        Text(
                          email,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textDark
                                .withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Streak badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(9999),
                            border: Border.all(
                                color: AppColors.border, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.border,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                  Icons.local_fire_department,
                                  color: AppColors.primary,
                                  size: 16),
                              const SizedBox(width: 4),
                              Text(
                                  '$currentStreak Day Streak!',
                                  style: AppTextStyles.badge),
                            ],
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
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.border, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.border,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit,
                        size: 18, color: AppColors.textDark),
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
