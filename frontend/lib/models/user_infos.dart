class UserInfos {
  String id;
  String name;

  int credits;

  UserInfos({
    required this.id,
    required this.credits,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'credits': credits,
      'name': name,
    };
  }

  factory UserInfos.fromJson(Map<dynamic, dynamic> json) {
    return UserInfos(
      id: json['id'],
      credits: json['credits'],
      name: json['name'],
    );
  }
}
