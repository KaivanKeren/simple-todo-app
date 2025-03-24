import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_project/models/save_task.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    // Rest of the build method remains unchanged
    return Scaffold(
      // AppBar, FloatingActionButton, and the rest remain the same
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-todo-screen');
        },
        elevation: 4,
        tooltip: 'Add new task',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Consumer<SaveTask>(
        builder: (context, task, child) {
          if (task.tasks.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: task.tasks.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (BuildContext context, index) {
              final currentTask = task.tasks[index];

              return Dismissible(
                key: Key(currentTask.id.toString()),
                background: Container(
                  color: Colors.red.shade400,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmation(context);
                },
                onDismissed: (direction) {
                  context.read<SaveTask>().removeTask(currentTask);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          context.read<SaveTask>().addTask(currentTask);
                        },
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                child: _buildTaskTile(context, currentTask, index),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, dynamic task, int index) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        _showTaskDetails(context, task, index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              shape: const CircleBorder(),
              activeColor: Colors.green,
              onChanged: (_) {
                // Store the current state before toggling
                final bool wasCompleted = task.isCompleted;

                // Toggle the task state
                context.read<SaveTask>().checkTask(index);

                // Show the appropriate message based on the previous state
                if (!wasCompleted) {
                  // Show completion message when task is being checked
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Great job!',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'You completed "${task.title}" 🎉',
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'UNDO',
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<SaveTask>().checkTask(index);
                        },
                      ),
                    ),
                  );
                } else {
                  // Show a different message when task is being unchecked
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.replay, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Task "${task.title}" marked as incomplete',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.orange.shade700,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'UNDO',
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<SaveTask>().checkTask(index);
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          task.isCompleted
                              ? FontWeight.normal
                              : FontWeight.w500,
                      decoration:
                          task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                      color:
                          task.isCompleted
                              ? theme.textTheme.bodyMedium?.color?.withOpacity(
                                0.6,
                              )
                              : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  if (task.description != null && task.description.isNotEmpty)
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  if (task.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: _getDueDateColor(task.dueDate),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDueDate(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDueDateColor(task.dueDate),
                            ),
                          ),
                          // Add time display if available (hour and minute are not 0)
                          if (_hasTimeComponent(task.dueDate)) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: _getDueDateColor(task.dueDate),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDueTime(task.dueDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getDueDateColor(task.dueDate),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final shouldDelete = await _showDeleteConfirmation(context);
                if (shouldDelete) {
                  context.read<SaveTask>().removeTask(task);
                }
              },
              splashRadius: 24,
              tooltip: 'Delete task',
            ),
          ],
        ),
      ),
    );
  }

  // Add a helper method to check if time is set (not midnight)
  bool _hasTimeComponent(DateTime date) {
    return date.hour != 0 || date.minute != 0;
  }

  // Add a method to format just the time portion
  String _formatDueTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // The rest of the methods remain unchanged
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new task by tapping the + button',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Task'),
              content: const Text('Are you sure you want to delete this task?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('DELETE'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showTaskDetails(BuildContext context, dynamic task, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to edit task screen with task data
                      // Implementation depends on your routing setup
                    },
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) {
                      context.read<SaveTask>().checkTask(index);
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                ],
              ),
              if (task.description != null && task.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(task.description),
              ],
              if (task.dueDate != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Due Date:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(_formatDueDate(task.dueDate, detailed: true)),
                    // Show time in task details if available
                    if (_hasTimeComponent(task.dueDate)) ...[
                      const SizedBox(width: 16),
                      const Text(
                        'Time:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(_formatDueTime(task.dueDate)),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Tasks',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('All Tasks'),
                onTap: () {
                  // Implement filter functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Completed'),
                onTap: () {
                  // Implement filter functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle_outlined),
                title: const Text('Active'),
                onTap: () {
                  // Implement filter functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Due Today'),
                onTap: () {
                  // Implement filter functionality
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDueDate(DateTime date, {bool detailed = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (detailed) {
      return '${date.day}/${date.month}/${date.year}';
    }

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else if (taskDate.isBefore(today)) {
      return 'Overdue';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  Color _getDueDateColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate.isBefore(today)) {
      return Colors.red;
    } else if (taskDate == today) {
      return Colors.orange;
    } else if (taskDate == tomorrow) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }
}