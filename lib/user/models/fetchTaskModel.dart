class Task {
  int? id;
  String taskName;

  Task({this.id, required this.taskName});

  Map<String, dynamic> toMap() {
    return {'id': id, 'taskName': taskName};
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(id: map['id'], taskName: map['taskName']);
  }

  @override
  String toString() {
    return 'Task{id: $id, taskName: $taskName}';
  }
}
