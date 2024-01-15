import 'dart:convert';

class AssignAreaLocationModel{
  String teamLeaderName;
  String areaLocationName;

  AssignAreaLocationModel(this.teamLeaderName,this.areaLocationName);

  factory AssignAreaLocationModel.fromJson(Map<String,dynamic>json)=>
      AssignAreaLocationModel(
        json['teamLeaderName'],
        json['areaLocationName'],
      );
  Map<String, dynamic> toJson()=>{
    'teamLeaderName':teamLeaderName,
    'areaLocationName':areaLocationName
  };
}