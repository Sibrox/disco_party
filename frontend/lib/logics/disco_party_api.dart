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
    User? currentUser = await User.getById(userId);
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
    if (currentUser == null || currentUser!.credits <= 0) {
      return false;
    }

    try {
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

  Future<bool> voteSong(String songId, int value) async {
    User? currentUser = this.currentUser;
    if (currentUser == null) {
      return false;
    }

    try {
      Song? song = await SongService.instance.getSong(songId);
      if (song == null) {
        throw Exception('Song not found');
      }

      if (song.hasUserVoted(currentUser.id)) {
        return false;
      }

      UserService.instance.addCredits(currentUser.id, 1);
      SongService.instance.addVote(songId, currentUser.id, value);

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }
}
