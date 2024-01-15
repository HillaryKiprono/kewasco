 import 'dart:convert';

class AreaLocationModel{
  String areaLocationCode;
  String areaLocationName;

  AreaLocationModel(this.areaLocationCode,this.areaLocationName);

  factory AreaLocationModel.fromJson(Map<String,dynamic>json)=>
      AreaLocationModel(
          json['areaLocationCode'],
          json['areaLocationName'],
      );
  Map<String, dynamic> toJson()=>{
    'areaLocationCode':areaLocationCode,
    'areaLocationName':areaLocationName
  };
 }