class UserInfos {
  int credits;
  String name;
  String? team;

  UserInfos({
    required this.credits,
    required this.name,
    this.team,
  });

  toJson() {
    return {
      'credits': credits,
      'name': name,
      'team': team,
    };
  }
}
