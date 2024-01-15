
class FetchTaskModel{
  final int? id;
  final String taskName;

  FetchTaskModel({
    this.id,
    required this.taskName,
  });

  factory FetchTaskModel.fromJson(Map<String, dynamic> json) {
    return FetchTaskModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      taskName: json['taskName'] as String,
    );
  }

}