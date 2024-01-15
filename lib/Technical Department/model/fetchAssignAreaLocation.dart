import 'dart:convert';

class FetchAssignAreaLocationModel {
  final int id;
  final String teamLeaderName;
  final String areaLocationName;

  FetchAssignAreaLocationModel({
    required this.id,
    required this.teamLeaderName,
    required this.areaLocationName,
  });

  // Named constructor for creating an instance from JSON data
  factory FetchAssignAreaLocationModel.fromJson(Map<String, dynamic> json) {
    return FetchAssignAreaLocationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString())  ?? 0,
      teamLeaderName: json['teamLeaderName'],
      areaLocationName: json['areaLocationName'],
    );
  }
}
