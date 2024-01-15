class FetchWorkerModel {
  final int? id;
  final String workerName;

  FetchWorkerModel({
     this.id,
    required this.workerName,
  });

  factory FetchWorkerModel.fromJson(Map<String, dynamic> json) {
    return FetchWorkerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      workerName: json['workerName'] as String,
    );
  }

}
