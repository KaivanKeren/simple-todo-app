class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  bool isCompleted;

  Task({
    String? id,
    required this.title,
    this.description,
    this.dueDate,
    required this.isCompleted,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Toggle completion status
  void toggleCompletion() {
    isCompleted = !isCompleted;
  }

  // Check if task is overdue
  bool isOverdue() {
    if (dueDate == null) return false;
    
    final today = DateTime.now();
    final dueDateTime = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    
    return dueDateTime.isBefore(todayDate) && !isCompleted;
  }

  // Check if task is due today
  bool isDueToday() {
    if (dueDate == null) return false;
    
    final today = DateTime.now();
    return dueDate!.year == today.year && 
           dueDate!.month == today.month && 
           dueDate!.day == today.day;
  }

  // Create a copy of the task with some fields changed
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // For serialization to JSON (useful when implementing persistence)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
    };
  }

  // For deserialization from JSON (useful when implementing persistence)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['dueDate']) 
          : null,
      isCompleted: json['isCompleted'],
    );
  }
}