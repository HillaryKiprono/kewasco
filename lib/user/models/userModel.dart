class User {
  String teamLeaderName;
  String userRole;
  String password;

  User({
    required this.teamLeaderName,
    required this.userRole,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      teamLeaderName: json['teamLeaderName'],
      userRole: json['userRole'],
      password: json['password'],
    );
  }
}
