import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_project/models/save_task.dart';
import 'package:android_project/theme_provider.dart';

// Define filter types as an enum for better type safety
enum TaskFilter {
  all,
  completed,
  active,
  dueToday,
}

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  // Current active filter
  TaskFilter _currentFilter = TaskFilter.all;
  
  // Filter label for the app bar
  String get _filterLabel {
    switch (_currentFilter) {
      case TaskFilter.all:
        return 'All Tasks';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.active:
        return 'Active';
      case TaskFilter.dueToday:
        return 'Due Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My Tasks',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_currentFilter != TaskFilter.all)
              Text(
                'Filtered: $_filterLabel',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
            tooltip: 'Filter tasks',
          ),
          IconButton(
            icon: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Icon(
                  themeProvider.themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : themeProvider.themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.brightness_auto,
                );
              },
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle Theme',
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
        builder: (context, taskProvider, child) {
          final filteredTasks = _getFilteredTasks(taskProvider.tasks);
          
          if (filteredTasks.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filteredTasks.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (BuildContext context, index) {
              final currentTask = filteredTasks[index];
              // Find the original index in the full tasks list for proper handling
              final originalIndex = taskProvider.tasks.indexOf(currentTask);

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
                child: _buildTaskTile(context, currentTask, originalIndex),
              );
            },
          );
        },
      ),
    );
  }

  // Filter tasks based on current filter
  List<dynamic> _getFilteredTasks(List<dynamic> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (_currentFilter) {
      case TaskFilter.all:
        return allTasks;
      case TaskFilter.completed:
        return allTasks.where((task) => task.isCompleted).toList();
      case TaskFilter.active:
        return allTasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.dueToday:
        return allTasks.where((task) {
          if (task.dueDate == null) return false;
          final taskDate = DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
          );
          return taskDate == today;
        }).toList();
    }
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

  // Display the empty state with a message based on active filter
  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (_currentFilter) {
      case TaskFilter.all:
        message = 'No tasks yet';
        icon = Icons.check_circle_outline;
        break;
      case TaskFilter.completed:
        message = 'No completed tasks';
        icon = Icons.check_circle;
        break;
      case TaskFilter.active:
        message = 'No active tasks';
        icon = Icons.circle_outlined;
        break;
      case TaskFilter.dueToday:
        message = 'No tasks due today';
        icon = Icons.calendar_today;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentFilter == TaskFilter.all
                ? 'Add a new task by tapping the + button'
                : 'Try selecting a different filter',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if (_currentFilter != TaskFilter.all) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentFilter = TaskFilter.all;
                });
              },
              icon: const Icon(Icons.filter_list_off),
              label: const Text('Show All Tasks'),
            ),
          ],
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
                      Navigator.of(context).pushNamed(
                        '/edit-todo-screen',
                        arguments: task,
                      );
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
                selected: _currentFilter == TaskFilter.all,
                selectedTileColor: Colors.blue.withOpacity(0.1),
                onTap: () {
                  setState(() {
                    _currentFilter = TaskFilter.all;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Completed'),
                selected: _currentFilter == TaskFilter.completed,
                selectedTileColor: Colors.blue.withOpacity(0.1),
                onTap: () {
                  setState(() {
                    _currentFilter = TaskFilter.completed;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle_outlined),
                title: const Text('Active'),
                selected: _currentFilter == TaskFilter.active,
                selectedTileColor: Colors.blue.withOpacity(0.1),
                onTap: () {
                  setState(() {
                    _currentFilter = TaskFilter.active;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Due Today'),
                selected: _currentFilter == TaskFilter.dueToday,
                selectedTileColor: Colors.blue.withOpacity(0.1),
                onTap: () {
                  setState(() {
                    _currentFilter = TaskFilter.dueToday;
                  });
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