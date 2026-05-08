import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<GroupsBloc>()..add(LoadGroups()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Groups'),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<GroupsBloc, GroupsState>(
          builder: (context, state) {
            if (state is GroupsLoading) {
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showJoinGroupDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Join Group'),
        ),
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Join a Group'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter invite code',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Joining group: ${controller.text}')),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}