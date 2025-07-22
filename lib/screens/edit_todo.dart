import 'package:android_project/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_project/models/save_task.dart';
import 'package:intl/intl.dart';

class EditTodo extends StatefulWidget {
  final Task? existingTask;
  
  const EditTodo({super.key, this.existingTask});

  @override
  State<EditTodo> createState() => _EditTodoState();
}

class _EditTodoState extends State<EditTodo> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  bool _isInitialized = false;
  Task? _taskToEdit;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize only once
    if (!_isInitialized) {
      // Get the task passed as argument
      final args = ModalRoute.of(context)?.settings.arguments;
      
      // Print debug info
      print('Route arguments: $args');
      print('Widget existingTask: ${widget.existingTask}');
      
      if (args != null) {
        if (args is Task) {
          _taskToEdit = args;
          print('Task set from route arguments');
        } else if (args is Map<String, dynamic>) {
          // Try to handle the case where a Map is passed instead of a Task
          try {
            _taskToEdit = Task.fromJson(args);
            print('Task created from Map arguments');
          } catch (e) {
            print('Error converting Map to Task: $e');
          }
        }
      } else if (widget.existingTask != null) {
        _taskToEdit = widget.existingTask;
        print('Task set from widget property');
      }
      
      _initializeFormValues();
      _isInitialized = true;
    }
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTask,
            tooltip: 'Save changes',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.task),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Due date selection
              const Text(
                'Due Date & Time (optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectedDate == null
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a date first'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _selectedTime == null
                              ? 'Select Time'
                              : _selectedTime!.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              if (_selectedDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear Date & Time'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDate = null;
                          _selectedTime = null;
                        });
                      },
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('SAVE CHANGES'),
                  onPressed: _saveTask,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('CANCEL'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initializeFormValues() {
    if (_taskToEdit != null) {
      _titleController.text = _taskToEdit!.title;
      
      if (_taskToEdit!.description != null) {
        _descriptionController.text = _taskToEdit!.description!;
      }
      
      if (_taskToEdit!.dueDate != null) {
        _selectedDate = _taskToEdit!.dueDate;
        
        // Set time if it's not midnight (default when no time is specified)
        if (_taskToEdit!.dueDate!.hour != 0 || _taskToEdit!.dueDate!.minute != 0) {
          _selectedTime = TimeOfDay(
            hour: _taskToEdit!.dueDate!.hour,
            minute: _taskToEdit!.dueDate!.minute,
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  DateTime? _combineDateTime() {
    if (_selectedDate == null) {
      return null;
    }

    if (_selectedTime == null) {
      // Return just the date with time set to midnight
      return DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );
    } else {
      // Combine date and time
      return DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate() && _taskToEdit != null) {
      final taskProvider = Provider.of<SaveTask>(context, listen: false);
      
      // Combine date and time if available
      final dueDateTime = _combineDateTime();
      
      // Create updated task using copyWith method
      final updatedTask = _taskToEdit!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        dueDate: dueDateTime,
      );
      
      // Update the task in the provider - adapt to your SaveTask implementation
      // Use the index-based method if that's what your SaveTask class implements
      final taskIndex = taskProvider.tasks.indexWhere((task) => task.id == _taskToEdit!.id);
      if (taskIndex != -1) {
        taskProvider.updateTask(taskIndex.toString(), updatedTask);
      } else {
        // Fallback if task not found by index
        taskProvider.updateTaskById(_taskToEdit!.id, updatedTask);
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to the task list
      Navigator.of(context).pop();
    } else {
      // Show error message if form is invalid or task is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save task. Please check all fields.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}