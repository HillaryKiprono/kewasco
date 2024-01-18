import 'dart:convert';

class AddWorkerModel{
  String workerName;

  AddWorkerModel(this.workerName);

  factory AddWorkerModel.fromJson(Map<String,dynamic> json)=>
      AddWorkerModel(json['workerName']);
  Map<String,dynamic> toJson()=>{
    'workerName':workerName
  };
}