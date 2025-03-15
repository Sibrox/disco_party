import 'package:disco_party/firebase/song_service.dart';
import 'package:disco_party/firebase/user_service.dart';
import 'package:disco_party/models/user.dart';
import 'package:disco_party/models/song.dart';
import 'package:disco_party/spotify/spotify_api.dart';
import 'package:disco_party/spotify/models/spotify_info.dart';

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

  Future<bool> addSongToQueue(SpotifyInfo spotifySong) async {
    User? currentUser = this.currentUser;
    if (currentUser == null) {
      return false;
    }

    try {
      currentUser = await User.getById(currentUser.id);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      if (currentUser.credits <= 0) {
        return false;
      }

      var song = Song(
        userID: currentUser.id,
        info: spotifySong,
      );

      await UserService.instance.payCredits(currentUser.id, 5);
      await SpotifyApi.addSongToQueue(spotifySong.uri);
      await SongService.instance.addSong(song);

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> voteSong(SpotifyInfo info, int value) async {
    User? currentUser = this.currentUser;
    if (currentUser == null) {
      return false;
    }

    try {
      currentUser = await User.getById(currentUser.id);
      String? djID = await SongService.instance.getDJBySongID(songID: info.id);

      if (currentUser == null || (currentUser.id == djID)) {
        return false;
      }

      Song? song = await SongService.instance.getSong(info.id);

      if (song == null) {
        song = Song(info: info);
        SongService.instance.addSong(song);
      }

      if (await song.hasUserVoted(currentUser!.id)) {
        return false;
      }

      if (value == 1) {
        await UserService.instance.addCredits(song.userID, 1);
      }
      await SongService.instance.addVote(song.id, currentUser.id, value);

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }
}
