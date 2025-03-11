import 'package:disco_party/firebase/user_service.dart';

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

  static Future<User> create(
      {required String id, required String name, int credits = 3}) async {
    final user = User(id: id, name: name, credits: credits);
    return await UserService.instance.createUser(user);
  }

  static Future<User?> getById(String id) async {
    return await UserService.instance.getUser(id);
  }
}
