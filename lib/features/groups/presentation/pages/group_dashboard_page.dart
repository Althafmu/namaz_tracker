import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class GroupDashboardPage extends StatefulWidget {
  final int groupId;
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupDashboardBloc>().add(LoadGroupDashboard(widget.groupId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: BlocBuilder<GroupDashboardBloc, GroupDashboardState>(
        builder: (context, state) {
          if (state is GroupDashboardLoading) {
            return const LoadingViewWidget();
          }
          if (state is GroupDashboardError) {
            return ErrorViewWidget(
              message: state.message,
              onRetry: () {
                context.read<GroupDashboardBloc>().add(LoadGroupDashboard(widget.groupId));
              },
            );
          }
          if (state is GroupDashboardLoaded || state is GroupDashboardRefreshing) {
            final dashboard = state is GroupDashboardLoaded
                ? state.dashboard
                : (state as GroupDashboardRefreshing).dashboard;
            final isRefreshing = state is GroupDashboardRefreshing;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<GroupDashboardBloc>().add(RefreshGroupDashboard(widget.groupId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
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
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            );
          }
          return const LoadingViewWidget();
        },
      ),
    );
  }
}