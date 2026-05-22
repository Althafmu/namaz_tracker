import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/group_dashboard_bloc.dart';
import '../bloc/group_dashboard_event.dart';
import '../bloc/group_dashboard_state.dart';
import '../widgets/group_header_widget.dart';
import '../widgets/current_user_card_widget.dart';
import '../widgets/leaderboard_preview_widget.dart';
import '../widgets/today_completion_widget.dart';
import '../widgets/recent_activity_widget.dart';
import '../widgets/loading_view_widget.dart';
import '../widgets/error_view_widget.dart';
import '../../data/datasources/group_dashboard_cache.dart';
import '../../../../core/notifications/notification_coordinator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';

class GroupDashboardPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDashboardPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDashboardPage> createState() => _GroupDashboardPageState();
}

class _GroupDashboardPageState extends State<GroupDashboardPage> {
  late final NotificationCoordinator _notificationCoordinator;
  bool _pollingStarted = false;

  @override
  void initState() {
    super.initState();
    _notificationCoordinator = GetIt.instance<NotificationCoordinator>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupDashboardBloc>().add(LoadGroupDashboard(widget.groupId));
    });
  }

  @override
  void dispose() {
    _notificationCoordinator.stopPolling();
    super.dispose();
  }

  void _startPolling(String? currentUsername) {
    if (_pollingStarted) return;
    _pollingStarted = true;
    _notificationCoordinator.startPolling(
      groupId: widget.groupId,
      currentUsername: currentUsername,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return BlocListener<GroupDashboardBloc, GroupDashboardState>(
      listener: (context, state) {
        if (state is GroupDashboardLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Refresh failed: ${state.errorMessage}'),
              backgroundColor: c.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.background,
          title: Text(
            widget.groupName.toUpperCase(),
            style: AppTextStyles.headlineSmall.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          actions: [
            Builder(
              builder: (context) {
                return BlocBuilder<GroupDashboardBloc, GroupDashboardState>(
                  builder: (context, state) {
                    if (state is! GroupDashboardLoaded && state is! GroupDashboardRefreshing) {
                      return const SizedBox.shrink();
                    }
                    final dashboard = state is GroupDashboardLoaded
                        ? state.dashboard
                        : (state as GroupDashboardRefreshing).dashboard;
                    final inviteCode = dashboard.group.inviteCode;
                    return IconButton(
                      icon: Icon(Icons.share, color: c.textPrimary),
                      tooltip: 'Share Invite Code',
                      onPressed: inviteCode != null
                          ? () => _showInviteCodeDialog(context, inviteCode)
                          : null,
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<GroupDashboardBloc, GroupDashboardState>(
          builder: (context, state) {
            if (state is GroupDashboardLoading) {
              return const LoadingViewWidget();
            }
            if (state is GroupDashboardError) {
              final hasCachedData = GroupDashboardCache.getCachedDashboard(widget.groupId) != null;
              return ErrorViewWidget(
                message: state.message,
                onRetry: () {
                  context.read<GroupDashboardBloc>().add(LoadGroupDashboard(widget.groupId));
                },
                hasCachedData: hasCachedData,
              );
            }
            if (state is GroupDashboardLoaded || state is GroupDashboardRefreshing) {
              final dashboard = state is GroupDashboardLoaded
                  ? state.dashboard
                  : (state as GroupDashboardRefreshing).dashboard;
              final isRefreshing = state is GroupDashboardRefreshing;

              if (state is GroupDashboardLoaded && !state.isCached) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _startPolling(dashboard.currentUser?.username);
                });
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<GroupDashboardBloc>().add(RefreshGroupDashboard(widget.groupId));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GroupHeaderWidget(group: dashboard.group),
                      const SizedBox(height: 16),
                      if (dashboard.currentUser != null)
                        CurrentUserCardWidget(stats: dashboard.currentUser!),
                      const SizedBox(height: 16),
                      LeaderboardPreviewWidget(
                        streaks: dashboard.topStreaks,
                        currentUserName: dashboard.currentUser?.username,
                        currentUserRank: dashboard.currentUser?.rank,
                        currentUserStreak: dashboard.currentUser?.currentStreak,
                        memberCount: dashboard.group.memberCount,
                      ),
                      const SizedBox(height: 16),
                      TodayCompletionWidget(
                        stats: dashboard.todayCompletion,
                        memberCount: dashboard.group.memberCount,
                      ),
                      if (dashboard.recentActivity.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        RecentActivityWidget(activities: dashboard.recentActivity),
                      ],
                      if (isRefreshing)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(
                            backgroundColor: c.border.withValues(alpha: 0.3),
                            color: c.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
            return const LoadingViewWidget();
          },
        ),
      ),
    );
  }

  void _showInviteCodeDialog(BuildContext context, String inviteCode) {
    final c = AppColors.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 360,
                maxHeight: constraints.maxHeight,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.border, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: c.border,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.group_add, color: c.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'INVITE CODE',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: c.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Share this code to invite members:',
                        style: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      NeoCard(
                        borderColor: c.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              inviteCode,
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: c.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.copy, color: c.primary),
                              tooltip: 'Copy',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: inviteCode));
                                HapticFeedback.lightImpact();
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Invite code copied!',
                                      style: AppTextStyles.bodyMedium.copyWith(color: c.surface),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: NeoButton(
                          text: 'CLOSE',
                          color: c.surface,
                          textColor: c.textPrimary,
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}