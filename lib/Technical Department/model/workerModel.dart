import 'dart:convert';

class FetchWorkerModel{
  String workerName;

  FetchWorkerModel(this.workerName);

  factory FetchWorkerModel.fromJson(Map<String,dynamic> json)=>
  FetchWorkerModel(json['workerName']);
  Map<String,dynamic> tojson()=>{
    'workerName':workerName
  };
}