class TeamLeaderModel {
  String teamLeaderName;
  String password;

  TeamLeaderModel(this.teamLeaderName,this.password);

  factory TeamLeaderModel.fromJson(Map<String, dynamic> json) =>
      TeamLeaderModel(
          json['teamLeaderName'],
          json['password']
      );

  Map<String, dynamic> toJson() => {
    'teamLeaderName': teamLeaderName,
    'password': password
  };
}
