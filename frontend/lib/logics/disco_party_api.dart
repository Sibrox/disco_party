import 'package:disco_party/firebase/song_service.dart';
import 'package:disco_party/firebase/user_service.dart';
import 'package:disco_party/models/user.dart';
import 'package:disco_party/models/song.dart';
import 'package:disco_party/spotify/spotify_api.dart';
import 'package:disco_party/spotify/spotify_song.dart';

class DiscoPartyApi {
  static final DiscoPartyApi instance = DiscoPartyApi._internal();
  User? currentUser;

  DiscoPartyApi._internal();

  factory DiscoPartyApi() {
    return instance;
  }

  Future<User> init({required String userId, String? userName}) async {
    currentUser = await User.getById(userId);
    if (currentUser == null && userName != null) {
      currentUser = await User.create(id: userId, name: userName);
    }

    User? newUser = currentUser;
    if (newUser != null) {
      return newUser;
    }

    throw Exception('Failed to get or create user');
  }

  Future<bool> addSongToQueue(SpotifySong spotifySong) async {
    try {
      currentUser = await User.getById(currentUser!.id);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      if (currentUser!.credits <= 0) {
        return false;
      }

      await SpotifyApi.addSongToQueue(spotifySong.uri);

      var song = Song(
        userID: currentUser!.id,
        info: spotifySong,
      );

      UserService.instance.addCredits(currentUser!.id, -1);
      SongService.instance.addSong(song);

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> voteSong(SpotifySong info, int value) async {
    try {
      currentUser = await User.getById(currentUser!.id);
      String? djID = await SongService.instance.getDJBySongID(songID: info.id);

      if (currentUser == null || (currentUser!.id == djID)) {
        return false;
      }

      Song? song = await SongService.instance.getSong(info.id);

      if (song == null) {
        song = Song(info: info, userID: 'dj_gallottino');
        print(song);
        SongService.instance.addSong(song);
      }

      if (await song.hasUserVoted(currentUser!.id)) {
        return false;
      }

      UserService.instance.addCredits(currentUser!.id, 1);
      SongService.instance.addVote(song.id, currentUser!.id, value);

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }
}
