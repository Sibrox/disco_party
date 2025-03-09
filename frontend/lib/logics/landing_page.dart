import 'package:disco_party/models/user_infos.dart';
import 'package:firebase_database/firebase_database.dart';

class LandingPageLogic {
  final DatabaseReference _discoPartRef =
      FirebaseDatabase.instance.ref('disco_party/users');
  UserInfos? currentUser;

  Future<void> getOrCreateUserInfos(String username, String id) async {
    DataSnapshot snapshot = await _discoPartRef.get();
    Map datas = snapshot.value as Map;

    if (datas.isNotEmpty && datas.containsKey(id)) {
      await _getUserInfos(id);
    } else {
      currentUser = _initUser(username, id);
    }
  }

  addSongToQueue(Song? song) async {
    if (currentUser!.credits <= 0) {
      return;
    }

    //TODO: api for get the song

    Song mockUpSong = Song(
      userID: 'caxscx23',
      album: 'album',
      artist: 'artist',
      image: 'image',
      name: 'name',
      uri: 'spotify:track:23xcxs',
      votes: [],
    );

    print(mockUpSong.toJson());

    final DatabaseReference userSongsRef =
        _discoPartRef.child(currentUser!.id).child('songs');

    DataSnapshot snapshot = await userSongsRef.get();

    if (snapshot.value != null) {
      Map songs = snapshot.value as Map;
      if (songs.containsKey(mockUpSong.id)) {
        return;
      }
    }
    //TODO: there is a bug when i add a new song and there are other songs. The previous id are change to 0 1 ... n

    _addOrRemoveCredits(value: -1, id: currentUser!.id);
    userSongsRef.child(mockUpSong.id).set(mockUpSong.toJson());
  }

  voteSong(Song song, int value) {
    // final DatabaseReference userSongsRef = FirebaseDatabase.instance
    //     .ref('disco_party/users/${currentUser!.id}/songs/${song.id}');

    // if (value == 1) {
    //   song.votes.add(1);
    // } else {
    //   song.votes.remove(1);
    // }

    // userSongsRef.set(song.toJson());
  }

  void _addOrRemoveCredits({required int value, required String id}) async {
    try {
      currentUser!.credits += value;
      await _discoPartRef.child(id).set(currentUser!.toJson());
    } catch (error) {
      currentUser!.credits -= value;
    }
  }

  Future<void> _getUserInfos(String id) async {
    DataSnapshot snapshot = await _discoPartRef.child(id).get();
    currentUser = UserInfos.fromJson(snapshot.value as Map);
  }

  UserInfos _initUser(String name, String id) {
    UserInfos user = UserInfos(id: id, credits: 0, name: name);
    _discoPartRef.child(id).set(user.toJson());
    return user;
  }
}
