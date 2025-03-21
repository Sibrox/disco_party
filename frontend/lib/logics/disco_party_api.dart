import 'package:disco_party/firebase/song_service.dart';
import 'package:disco_party/firebase/user_service.dart';
import 'package:disco_party/models/user.dart';
import 'package:disco_party/models/song.dart';
import 'package:disco_party/spotify/spotify_api.dart';
import 'package:disco_party/spotify/models/spotify_info.dart';
import 'package:firebase_database/firebase_database.dart';

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
    Song? songInQueue = await SongService.instance.getSong(spotifySong.id);
    if (songInQueue != null) {
      await SpotifyApi.addSongToQueue(spotifySong.uri);
      return true;
    }

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

  Future<bool> voteSong(SpotifyInfo info, int voteValue) async {
    User? currentUser = this.currentUser;
    if (currentUser == null) {
      return false;
    }

    try {
      currentUser = await User.getById(currentUser.id);
      Song? song = await SongService.instance.getSong(info.id);

      if (song == null) {
        song = Song(info: info);
        await SongService.instance.addSong(song);
      }

      if (currentUser == null || (currentUser.id == song.userID)) {
        return false;
      }

      if (await song.hasUserVoted(currentUser.id)) {
        return false;
      }

      final negVotes = song.votes.values.where((vote) => vote < 0).length;
      // final numberOfUsers = (await UserService.instance.getAllUsers()).length;
      if (negVotes >= 10) await SpotifyApi().skipSong();

      vote(userID: currentUser.id, song: song, vote: voteValue);
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<void> vote(
      {required String userID, required Song song, required int vote}) async {
    try {
      await FirebaseDatabase.instance.ref().update({
        'disco_party/songs/${song.id}/votes/$userID': vote,
        'disco_party/users/${song.userID}/credits': ServerValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to vote: $e');
    }
  }
}
