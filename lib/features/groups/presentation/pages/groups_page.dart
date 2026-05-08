import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';

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
            SnackBar(content: Text('Join failed: ${state.message}')),
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
            SnackBar(content: Text('Create failed: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Groups'),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<GroupsBloc, GroupsState>(
          builder: (context, state) {
            if (state is GroupsLoading || state is GroupsJoining || state is GroupsCreating) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GroupsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load groups',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<GroupsBloc>().add(LoadGroups()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is GroupsLoaded) {
              if (state.groups.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No groups yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join a group to connect with others\nand stay motivated on your prayer journey',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<GroupsBloc>().add(RefreshGroups());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.groups.length,
                  itemBuilder: (context, index) {
                    final group = state.groups[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            group.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          '${group.memberCount} members • ${group.userRole}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push(
                            '/groups/${group.id}',
                            extra: group.name,
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'join') {
              _showJoinGroupDialog(context);
            } else if (value == 'create') {
              _showCreateGroupDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'create',
              child: ListTile(
                leading: Icon(Icons.group_add),
                title: Text('Create Group'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'join',
              child: ListTile(
                leading: Icon(Icons.login),
                title: Text('Join Group'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          child: const FloatingActionButton.extended(
            onPressed: null,
            icon: Icon(Icons.add),
            label: Text('Groups'),
          ),
        ),
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GroupsBloc>(),
        child: BlocBuilder<GroupsBloc, GroupsState>(
          builder: (context, state) {
            final isJoining = state is GroupsJoining;
            return AlertDialog(
              title: const Text('Join a Group'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter invite code',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                enabled: !isJoining,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isJoining
                      ? null
                      : () {
                          final code = controller.text.trim().toUpperCase();
                          if (code.isNotEmpty) {
                            context.read<GroupsBloc>().add(JoinGroup(code));
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: isJoining
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Join'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GroupsBloc>(),
        child: BlocBuilder<GroupsBloc, GroupsState>(
          builder: (context, state) {
            final isCreating = state is GroupsCreating;
            return AlertDialog(
              title: const Text('Create a Group'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Group name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                enabled: !isCreating,
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isCreating
                      ? null
                      : () {
                          final name = controller.text.trim();
                          if (name.isNotEmpty) {
                            context.read<GroupsBloc>().add(CreateGroup(name));
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}