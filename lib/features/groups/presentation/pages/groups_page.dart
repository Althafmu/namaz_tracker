import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupsBloc, GroupsState>(
      listener: (context, state) {
        if (state is GroupsJoinSuccess) {
          context.push('/groups/${state.groupId}');
        }
        if (state is GroupsJoinFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is GroupsInviteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is GroupsCreateSuccess) {
          context.push('/groups/${state.groupId}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Group created! Invite code: ${state.inviteCode}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        if (state is GroupsCreateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: AppBar(
          backgroundColor: AppColors.of(context).background,
          title: Text(
            'GROUPS',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.of(context).textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'join') {
                  _showJoinGroupDialog(context);
                } else if (value == 'create') {
                  _showCreateGroupDialog(context);
                }
              },
              offset: const Offset(0, 40),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.of(context).primary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.of(context).border,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: AppColors.of(context).surface,
                  size: 22,
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'create',
                  child: Row(
                    children: [
                      Icon(Icons.group_add, color: AppColors.of(context).textPrimary),
                      const SizedBox(width: 12),
                      Text(
                        'Create Group',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.of(context).textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'join',
                  child: Row(
                    children: [
                      Icon(Icons.login, color: AppColors.of(context).textPrimary),
                      const SizedBox(width: 12),
                      Text(
                        'Join Group',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.of(context).textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<GroupsBloc, GroupsState>(
          builder: (context, state) {
            if (state is GroupsLoading || state is GroupsJoining || state is GroupsCreating) {
              return Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: AppColors.of(context).primary,
                    strokeWidth: 3,
                  ),
                ),
              );
            }
            if (state is GroupsError) {
              final c = AppColors.of(context);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: c.error),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load groups',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 140,
                        child: NeoButton(
                          text: 'RETRY',
                          onPressed: () => context.read<GroupsBloc>().add(LoadGroups()),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is GroupsLoaded) {
              if (state.groups.isEmpty) {
                return _buildEmptyState(context);
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<GroupsBloc>().add(RefreshGroups());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: state.groups.length,
                  itemBuilder: (context, index) {
                    final group = state.groups[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GroupListItem(
                        group: group,
                        onTap: () => context.push(
                          '/groups/${group.id}',
                          extra: group.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final c = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: c.textSecondary),
            const SizedBox(height: 24),
            Text(
              'No groups yet',
              style: AppTextStyles.headlineSmall.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                'Create a group and share your invite code with friends and family.\n\nOR\n\nJoin a group using an invite code.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'CREATE GROUP',
                      icon: Icons.add,
                      color: c.primary,
                      onPressed: () => _showCreateGroupDialog(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeoButton(
                      text: 'JOIN GROUP',
                      icon: Icons.group_add,
                      color: c.surface,
                      textColor: c.textPrimary,
                      onPressed: () => _showJoinGroupDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    final controller = TextEditingController();
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GroupsBloc>(),
        child: BlocListener<GroupsBloc, GroupsState>(
          listener: (context, state) {
            if (state is GroupsJoinSuccess) {
              Navigator.pop(dialogContext);
            }
            if (state is GroupsInviteError) {
              Navigator.pop(dialogContext);
            }
          },
          child: BlocBuilder<GroupsBloc, GroupsState>(
            builder: (context, state) {
              final isValidating = state is GroupsInviteValidating;
              final isConfirming = state is GroupsJoining;
              final confirmedGroup = state is GroupsInviteConfirmed ? state : null;
              final confirmedGroupName = confirmedGroup?.groupName ?? '';

              return Dialog(
                backgroundColor: c.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: c.border, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isValidating) ...[
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  color: c.primary,
                                  strokeWidth: 2.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Checking invite code...',
                                style: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ] else if (confirmedGroup != null) ...[
                        Row(
                          children: [
                            Icon(Icons.group, color: c.primary, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'JOIN $confirmedGroupName',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "You're about to join this group. Your streak will be visible to other members.",
                          style: AppTextStyles.bodySmall.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 100,
                              child: NeoButton(
                                text: 'CANCEL',
                                color: c.surface,
                                textColor: c.textPrimary,
                                height: 44,
                                onPressed: () {
                                  context.read<GroupsBloc>().add(CancelGroupJoin());
                                  Navigator.pop(dialogContext);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 140,
                              child: isConfirming
                                  ? SizedBox(
                                      height: 44,
                                      child: Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: c.primary,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    )
                                  : NeoButton(
                                      text: 'CONFIRM JOIN',
                                      color: c.primary,
                                      height: 44,
                                      onPressed: () {
                                        final code = controller.text.trim().toUpperCase();
                                        context.read<GroupsBloc>().add(ConfirmGroupJoin(code));
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'JOIN A GROUP',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: c.surface,
                            border: Border.all(color: c.border, width: 2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: c.border, offset: const Offset(4, 4)),
                            ],
                          ),
                          child: TextField(
                            controller: controller,
                            style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
                            textCapitalization: TextCapitalization.characters,
                            enabled: !isValidating,
                            decoration: InputDecoration(
                              hintText: 'Enter invite code',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 100,
                              child: NeoButton(
                                text: 'CANCEL',
                                color: c.surface,
                                textColor: c.textPrimary,
                                height: 44,
                                onPressed: () => Navigator.pop(dialogContext),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 100,
                              child: NeoButton(
                                text: 'JOIN',
                                color: c.primary,
                                height: 44,
                                onPressed: () {
                                  final code = controller.text.trim().toUpperCase();
                                  if (code.isNotEmpty) {
                                    HapticFeedback.lightImpact();
                                    context.read<GroupsBloc>().add(JoinGroup(code));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final controller = TextEditingController();
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GroupsBloc>(),
        child: BlocListener<GroupsBloc, GroupsState>(
          listener: (context, state) {
            if (state is GroupsCreateSuccess || state is GroupsCreateFailure) {
              Navigator.pop(dialogContext);
            }
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return BlocBuilder<GroupsBloc, GroupsState>(
                builder: (context, state) {
                  final isCreating = state is GroupsCreating;
                  return Dialog(
                    backgroundColor: c.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: c.border, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CREATE A GROUP',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: c.surface,
                              border: Border.all(color: c.border, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: c.border, offset: const Offset(4, 4)),
                              ],
                            ),
                            child: TextField(
                              controller: controller,
                              style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
                              textCapitalization: TextCapitalization.words,
                              enabled: !isCreating,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Group name',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 100,
                                child: NeoButton(
                                  text: 'CANCEL',
                                  color: c.surface,
                                  textColor: c.textPrimary,
                                  height: 44,
                                  onPressed: () => Navigator.pop(dialogContext),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 100,
                                child: isCreating
                                    ? SizedBox(
                                        height: 44,
                                        child: Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: c.primary,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      )
                                    : NeoButton(
                                        text: 'CREATE',
                                        color: c.primary,
                                        height: 44,
                                        onPressed: () {
                                          final name = controller.text.trim();
                                          if (name.isNotEmpty) {
                                            HapticFeedback.lightImpact();
                                            context.read<GroupsBloc>().add(CreateGroup(name));
                                          }
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GroupListItem extends StatelessWidget {
  final dynamic group;
  final VoidCallback onTap;

  const _GroupListItem({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return NeoCard(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                group.name.substring(0, 1).toUpperCase(),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: c.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${group.memberCount} members · ${group.userRole}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: c.textSecondary,
          ),
        ],
      ),
    );
  }
}