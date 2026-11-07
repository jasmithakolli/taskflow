class Task {
  final String id;
  String title;
  String description;
  String category;
  String priority;
  String status;
  DateTime dueDate;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isCompleted => status == 'Completed';

  bool get isOverdue =>
      !isCompleted && dueDate.isBefore(DateTime.now()) &&
      !(dueDate.year == DateTime.now().year &&
        dueDate.month == DateTime.now().month &&
        dueDate.day == DateTime.now().day);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'status': status,
        'dueDate': dueDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: json['category'] as String,
        priority: json['priority'] as String,
        status: json['status'] as String,
        dueDate: DateTime.parse(json['dueDate'] as String),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
