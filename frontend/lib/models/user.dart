class User {
  String id;
  String name;

  int credits;

  User({
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

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      id: json['id'],
      credits: json['credits'],
      name: json['name'],
    );
  }
}
