import 'dart:convert';

class FetchAreaLocationModel {
  final int id;
  final String areaLocationCode;
  final String areaLocationName;

  FetchAreaLocationModel({
    required this.id,
    required this.areaLocationCode,
    required this.areaLocationName,
  });

  // Named constructor for creating an instance from JSON data
  factory FetchAreaLocationModel.fromJson(Map<String, dynamic> json) {
    return FetchAreaLocationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString())  ?? 0,
      areaLocationCode: json['areaLocationCode'],
      areaLocationName: json['areaLocationName'],
    );
  }
}
