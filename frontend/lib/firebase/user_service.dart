import 'package:disco_party/models/user.dart';
import 'package:firebase_database/firebase_database.dart';

class UserService {
  static final UserService instance = UserService._internal();
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('disco_party/users');

  factory UserService() {
    return instance;
  }

  UserService._internal();

  Future<User> createUser(User user) async {
    try {
      await _dbRef.child(user.id).set(user.toJson());
      return user;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<User?> getUser(String userId) async {
    try {
      final DataSnapshot snapshot = await _dbRef.child(userId).get();

      if (snapshot.exists && snapshot.value != null) {
        return User.fromJson(snapshot.value as Map<dynamic, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<int> addCredits(String userId, int amount) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }
    try {
      final DataSnapshot snapshot =
          await _dbRef.child(userId).child('credits').get();

      if (snapshot.exists && snapshot.value != null) {
        final int currentCredits = snapshot.value as int;
        final int newCredits = currentCredits + amount;
        await _dbRef.child(userId).child('credits').set(newCredits);
        return newCredits;
      }
      throw Exception('User credits not found');
    } catch (e) {
      throw Exception('Failed to add credits: $e');
    }
  }

  Future<int> payCredits(String userId, int amount) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    try {
      final DataSnapshot snapshot =
          await _dbRef.child(userId).child('credits').get();

      if (snapshot.exists && snapshot.value != null) {
        final int currentCredits = snapshot.value as int;

        if (currentCredits < amount) {
          throw ('Not enough credits');
        }

        final int newCredits = currentCredits - amount;
        await _dbRef.child(userId).child('credits').set(newCredits);
        return newCredits;
      }

      throw Exception('User credits not found');
    } catch (e) {
      throw Exception('Failed to add credits: $e');
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final DataSnapshot snapshot = await _dbRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> values =
            snapshot.value as Map<dynamic, dynamic>;
        return values.entries
            .map((entry) => User.fromJson(entry.value as Map<dynamic, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  Future<bool> userExists(String userId) async {
    try {
      final DataSnapshot snapshot = await _dbRef.child(userId).get();
      return snapshot.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }
}
