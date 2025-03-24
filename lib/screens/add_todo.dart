import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_project/models/save_task.dart';
import 'package:android_project/models/task_model.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({super.key, Object? existingTask});

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });

      // If date is selected but time isn't, prompt for time selection
      if (_selectedTime == null) {
        _selectTime();
      }
    }
  }

  void _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  DateTime? _getCombinedDateTime() {
    if (_selectedDate == null) return null;

    if (_selectedTime == null) return _selectedDate;

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Create a unique ID for the task (if using uuid package)
      // const uuid = Uuid();
      // final id = uuid.v4();

      // Fallback if not using uuid package
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      // Create and add the new task with combined date and time
      final newTask = Task(
        id: id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _getCombinedDateTime(),
        isCompleted: false,
      );

      context.read<SaveTask>().addTask(newTask);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Return to the previous screen
      Navigator.of(context).pop();
    }
  }

  void _clearDateTime() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed:
                _titleController.text.trim().isNotEmpty ? _saveTask : null,
            tooltip: 'Save task',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Task title',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a task title';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // Force rebuild to update save button state
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Add description (optional)',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          _selectedDate == null
                              ? 'Set due date'
                              : _formatDate(_selectedDate!),
                          style: TextStyle(
                            color:
                                _selectedDate == null
                                    ? theme.hintColor
                                    : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        trailing:
                            _selectedDate != null
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearDateTime,
                                )
                                : null,
                        onTap: _selectDate,
                      ),
                      if (_selectedDate != null)
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            _selectedTime == null
                                ? 'Set time'
                                : _formatTime(_selectedTime!),
                            style: TextStyle(
                              color:
                                  _selectedTime == null
                                      ? theme.hintColor
                                      : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          onTap: _selectTime,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      _titleController.text.trim().isNotEmpty
                          ? _isSubmitting
                              ? null
                              : _saveTask
                          : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Add Task',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}