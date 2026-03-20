import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/task_tile.dart';
import 'add_edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<TaskProvider>().loadTasks(),
    );
  }

  void _openAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    );
  }

  void _openEditTask(context, task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task)),
    );
  }

  void _confirmDelete(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TaskProvider>().deleteTask(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton(TaskProvider provider) {
    final status = provider.syncStatus;

    if (status == SyncStatus.syncing) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    if (status == SyncStatus.success) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.cloud_done, color: Colors.greenAccent),
      );
    }

    if (status == SyncStatus.failed) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.cloud_off, color: Colors.redAccent),
      );
    }

    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.sync, color: Colors.white),
          if (provider.hasUnsyncedTasks)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      tooltip: 'Sync Tasks',
      onPressed: provider.tasks.isEmpty ? null : provider.syncTasks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<TaskProvider>(
            builder: (_, provider, __) => _buildSyncButton(provider),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          // Error
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadTasks();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          if (provider.tasks.isEmpty) {
            return const EmptyStateWidget();
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.indigo.shade50,
                child: Row(
                  children: [
                    Text(
                      '${provider.tasks.length} tasks',
                      style: TextStyle(
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (provider.hasUnsyncedTasks)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sync_problem,
                                size: 14, color: Colors.orange),
                            SizedBox(width: 4),
                            Text('Unsynced changes',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.orange)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: provider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = provider.tasks[index];
                    return TaskTile(
                      task: task,
                      onTap: () => _openEditTask(context, task),
                      onToggleStatus: () =>
                          provider.toggleStatus(task.id),
                      onDelete: () =>
                          _confirmDelete(context, task.id, task.title),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}