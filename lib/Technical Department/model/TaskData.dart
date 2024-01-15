class TaskModel{
  String taskName;
  TaskModel(this.taskName);
  factory TaskModel.fromJson(Map<String,dynamic>json)=>TaskModel(
    json['taskName'],
  );
  Map<String,dynamic> toJson()=>
      {
        "taskName":taskName
      };
}