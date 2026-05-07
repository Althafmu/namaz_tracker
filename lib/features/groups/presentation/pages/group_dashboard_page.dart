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
    context.read<GroupDashboardBloc>().add(LoadGroupDashboard(widget.groupId));
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
            return const _LoadingView();
          }
          if (state is GroupDashboardError) {
            return _ErrorView(
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
                      currentUserId: dashboard.currentUser?.userId,
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
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(height: 24, width: 150),
          const SizedBox(height: 24),
          _SkeletonBox(height: 120),
          const SizedBox(height: 24),
          _SkeletonBox(height: 200),
          const SizedBox(height: 24),
          _SkeletonBox(height: 150),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double width;

  const _SkeletonBox({required this.height, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Couldn't load dashboard",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}