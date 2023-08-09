
class WorkerModel{

  String workerName;


  WorkerModel(

      this.workerName,

      );

  factory WorkerModel.fromJson(Map<String,dynamic>json)=>WorkerModel(

    json["workerName"]


  );

  Map<String, dynamic> toJson()=>
      {
        "workerName":workerName,

      };

}
