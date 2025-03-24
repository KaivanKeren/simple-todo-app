import 'package:android_project/models/task_model.dart';
import 'package:flutter/material.dart';

class SaveTask extends ChangeNotifier {
  // Initial task list with sample data
  final List<Task> _tasks = [];
  
  // Filtered tasks list
  List<Task> _filteredTasks = [];
  
  // Current filter type
  String _currentFilter = 'all';
  
  // Constructor that initializes filtered tasks
  SaveTask() {
    _filteredTasks = List.from(_tasks);
  }
  
  // Getter for tasks based on current filter
  List<Task> get tasks => _filteredTasks;
  
  // Getter for current filter
  String get currentFilter => _currentFilter;
  
  // Add a new task
  void addTask(Task task) {
    _tasks.add(task);
    _applyFilter(_currentFilter); // Re-apply current filter
    notifyListeners();
  }
  
  // Remove a task
  void removeTask(Task task) {
    _tasks.remove(task);
    _applyFilter(_currentFilter); // Re-apply current filter
    notifyListeners();
  }
  
  // Toggle task completion status
  void checkTask(int index) {
    // Find the task in the original list
    final taskId = _filteredTasks[index].id;
    final originalIndex = _tasks.indexWhere((task) => task.id == taskId);
    
    if (originalIndex != -1) {
      _tasks[originalIndex].toggleCompletion();
      _applyFilter(_currentFilter); // Re-apply current filter
      notifyListeners();
    }
  }
  
  // Update an existing task
  void updateTask(String taskId, Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _applyFilter(_currentFilter); // Re-apply current filter
      notifyListeners();
    }
  }
  
  // Apply filter to tasks
  void setFilter(String filter) {
    _currentFilter = filter;
    _applyFilter(filter);
    notifyListeners();
  }
  
  // Internal method to apply filter
  void _applyFilter(String filter) {
    switch (filter) {
      case 'completed':
        _filteredTasks = _tasks.where((task) => task.isCompleted).toList();
        break;
      case 'active':
        _filteredTasks = _tasks.where((task) => !task.isCompleted).toList();
        break;
      case 'today':
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        _filteredTasks = _tasks.where((task) {
          if (task.dueDate == null) return false;
          final taskDate = DateTime(
            task.dueDate!.year,
            task.dueDate!.month,
            task.dueDate!.day,
          );
          return taskDate.isAtSameMomentAs(todayDate);
        }).toList();
        break;
      case 'all':
      default:
        _filteredTasks = List.from(_tasks);
        break;
    }
  }
  
  // Find a task by ID
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get task statistics
  Map<String, dynamic> getStatistics() {
    final total = _tasks.length;
    final completed = _tasks.where((task) => task.isCompleted).length;
    final active = total - completed;
    
    // Calculate tasks due today
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueToday = _tasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return taskDate.isAtSameMomentAs(todayDate);
    }).length;
    
    // Calculate overdue tasks
    final overdue = _tasks.where((task) {
      if (task.dueDate == null || task.isCompleted) return false;
      return task.dueDate!.isBefore(today);
    }).length;
    
    return {
      'total': total,
      'completed': completed,
      'active': active,
      'dueToday': dueToday,
      'overdue': overdue,
      'completionRate': total > 0 ? (completed / total * 100).toStringAsFixed(1) : '0',
    };
  }
}