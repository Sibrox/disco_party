import 'package:disco_party/models/user_infos.dart';
import 'package:disco_party/models/disco_party_song.dart';
import 'package:disco_party/spotify/spotify_api.dart';
import 'package:firebase_database/firebase_database.dart';

class DiscoPartyApi {
  static final DiscoPartyApi _instance = DiscoPartyApi._internal();

  factory DiscoPartyApi() {
    return _instance;
  }

  DiscoPartyApi._internal();

  final DatabaseReference _discoPartRef =
      FirebaseDatabase.instance.ref('disco_party/users');
  UserInfos? currentUser;

  Future<void> getOrCreateUserInfos(
      {required String username, required String id}) async {
    DataSnapshot snapshot = await _discoPartRef.get();
    Map datas = snapshot.value as Map;

    if (datas.isNotEmpty && datas.containsKey(id)) {
      await _getUserInfos(id);
    } else {
      currentUser = _initUser(username, id);
    }
  }

  Future<bool> addSongToQueue(Song song) async {
    if (currentUser == null || currentUser!.credits <= 0) {
      return false;
    }

    try {
      await SpotifyApi.addSongToQueue(song.info.uri);

      final DatabaseReference userSongsRef =
          _discoPartRef.child(currentUser!.id).child('songs');

      DataSnapshot snapshot = await userSongsRef.get();

      if (snapshot.value != null) {
        Map songs = snapshot.value as Map;
        if (songs.containsKey(song.id)) {
          return false;
        }
      }

      _addOrRemoveCredits(value: -1, id: currentUser!.id);
      userSongsRef.child(song.id).set(song.toJson());
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> voteSong(Song song, int value) async {
    if (currentUser == null || song.userID == currentUser!.id) {
      return false;
    }

    final DatabaseReference userSongsRef = FirebaseDatabase.instance
        .ref('disco_party/users/${song.userID}/songs/${song.id}/votes');

    try {
      DataSnapshot snapshot = await userSongsRef.get();

      if (snapshot.value != null) {
        Map votes = snapshot.value as Map;
        if (votes.containsKey(currentUser!.id)) {
          return false;
        }
      }

      await userSongsRef.child(currentUser!.id).set(value);

      if (value > 0) {
        _addOrRemoveCredits(value: 1, id: song.userID);
      }

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<void> _addOrRemoveCredits(
      {required int value, required String id}) async {
    try {
      if (currentUser != null && currentUser!.id == id) {
        currentUser!.credits += value;
      }

      final DatabaseReference userRef = _discoPartRef.child(id);
      DataSnapshot snapshot = await userRef.child('credits').get();

      if (snapshot.value != null) {
        int currentCredits = snapshot.value as int;
        await userRef.child('credits').set(currentCredits + value);
      } else {
        await userRef.child('credits').set(value);
      }
    } catch (error) {
      print('Error updating credits: $error');
      if (currentUser != null && currentUser!.id == id) {
        currentUser!.credits -= value;
      }
    }
  }

  Future<void> _getUserInfos(String id) async {
    try {
      DataSnapshot snapshot = await _discoPartRef.child(id).get();
      if (snapshot.value != null) {
        currentUser = UserInfos.fromJson(snapshot.value as Map);
      }
    } catch (error) {
      print('Error getting user info: $error');
    }
  }

  UserInfos _initUser(String name, String id) {
    UserInfos user = UserInfos(id: id, credits: 3, name: name);
    _discoPartRef.child(id).set(user.toJson());
    return user;
  }

  // Method to check if a user is initialized
  bool get isUserInitialized => currentUser != null;

  // Method to get current credits
  int get currentCredits => currentUser?.credits ?? 0;
}
