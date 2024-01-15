class FetchTeamLeadersModel {
  final int id;
  final String teamLeaderName;

  FetchTeamLeadersModel({required this.id, required this.teamLeaderName});

  factory FetchTeamLeadersModel.fromJson(Map<String, dynamic> json) {
    return FetchTeamLeadersModel(
      id: int.parse(json['id'] ?? '0'), // Parse the value as an integer
      teamLeaderName: json['teamLeaderName'] ?? '',
    );
  }
}
