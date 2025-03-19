import 'package:disco_party/firebase/user_service.dart';

class User {
  String id;
  String name;
  int positveVotes;
  int negativeVotes;
  int credits;

  User({
    required this.id,
    required this.credits,
    this.positveVotes = 0,
    this.negativeVotes = 0,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'credits': credits,
      'name': name,
      'positveVotes': positveVotes,
      'negativeVotes': negativeVotes,
    };
  }

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      id: json['id'],
      credits: json['credits'],
      positveVotes: json['positveVotes'],
      negativeVotes: json['negativeVotes'],
      name: json['name'],
    );
  }

  static Future<User> create(
      {required String id, required String name, int credits = 15}) async {
    final user = User(id: id, name: name, credits: credits);
    return await UserService.instance.createUser(user);
  }

  static Future<User?> getById(String id) async {
    return await UserService.instance.getUser(id);
  }
}
