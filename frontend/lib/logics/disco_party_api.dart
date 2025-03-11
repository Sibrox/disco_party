import 'package:disco_party/models/user_infos.dart';
import 'package:disco_party/models/disco_party_song.dart';
import 'package:disco_party/spotify/spotify_api.dart';
import 'package:disco_party/spotify/spotify_song.dart';
import 'package:firebase_database/firebase_database.dart';

class DiscoPartyApi {
  static final DiscoPartyApi _instance = DiscoPartyApi._internal();

  factory DiscoPartyApi() {
    return _instance;
  }

  DiscoPartyApi._internal();

  final DatabaseReference _discoPartRef =
      FirebaseDatabase.instance.ref('disco_party/');
  UserInfos? currentUser;

  Future<void> getOrCreateUserInfos(
      {required String username, required String id}) async {
    DataSnapshot snapshot = await _discoPartRef.child('users').get();
    Map datas = snapshot.value as Map? ?? {};

    if (datas.isNotEmpty && datas.containsKey(id)) {
      await _getUserInfos(id);
    } else {
      currentUser = _initUser(username, id);
    }
  }

  Future<bool> addSongToQueue(SpotifySong spotifySong) async {
    if (currentUser == null || currentUser!.credits <= 0) {
      return false;
    }

    try {
      await SpotifyApi.addSongToQueue(spotifySong.uri);

      var song = Song(
        userID: currentUser!.id,
        info: spotifySong,
      );

      final DatabaseReference userSongsRef = _discoPartRef.child('songs');

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

  Future<bool> voteSong(String songId, int value) async {
    if (currentUser == null) {
      return false;
    }

    final DatabaseReference songRef =
        FirebaseDatabase.instance.ref('disco_party/songs/$songId');

    try {
      DataSnapshot snapshot = await songRef.get();

      if (snapshot.value == null) {
        return false;
      }

      Song song = Song.fromJson(snapshot.value as Map);
      if (song.votes.containsKey(currentUser!.id)) {
        return false;
      }

      song.votes[currentUser!.id] = value;
      await songRef.set(song.toJson());

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

      final DatabaseReference userRef = _discoPartRef.child('users').child(id);
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
    _discoPartRef.child('users').child(id).set(user.toJson());
    return user;
  }

  // Method to check if a user is initialized
  bool get isUserInitialized => currentUser != null;

  // Method to get current credits
  int get currentCredits => currentUser?.credits ?? 0;
}
