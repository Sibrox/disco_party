import 'package:disco_party/spotify/spotify_song.dart';
import 'package:disco_party/firebase/song_service.dart';

class Song {
  String userID;
  SpotifySong info;
  Map<dynamic, dynamic> votes;

  static String table = 'songs';

  String get id => info.id;

  Song({required this.userID, required this.info, this.votes = const {}}) {
    votes = {};
  }

  Map<String, dynamic> toJson() {
    var baseJson = {
      'userID': userID,
      'info': info.toJson(),
    };

    return votes.isEmpty
        ? baseJson
        : {
            ...baseJson,
            'votes': votes,
          };
  }

  static Song fromJson(Map<dynamic, dynamic> json) {
    return Song(
      userID: json['userID'],
      info: SpotifySong.fromJson(json['info']),
      votes: json.containsKey('votes') ? json['votes'] : {},
    );
  }

  int get voteScore {
    int total = 0;
    votes.forEach((user, vote) {
      total += vote as int;
    });
    return total;
  }

  Future<bool> hasUserVoted(String userId) async {
    Song? updatedSong = await SongService.instance.getSong(id);
    return updatedSong?.votes.containsKey(userId) ?? false;
  }

  Future<int?> getUserVote(String userId) async {
    if (!(await hasUserVoted(userId))) return null;
    return votes[userId] as int;
  }

  static Future<Song> addToQueue(String userId, SpotifySong spotifySong) async {
    final song = Song(userID: userId, info: spotifySong);
    return await SongService.instance.addSong(song);
  }

  static Future<Song?> getById(String songId) async {
    return await SongService.instance.getSong(songId);
  }

  static Future<List<Song>> getAll() async {
    return await SongService.instance.getAllSongs();
  }

  static Future<List<Song>> getByUserId(String userId) async {
    return await SongService.instance.getUserSongs(userId);
  }

  static Future<List<Song>> getTopVoted({int limit = 10}) async {
    return await SongService.instance.getTopVotedSongs(limit: limit);
  }

  Future<bool> addVote(String userId, int voteValue) async {
    final success = await SongService.instance.addVote(id, userId, voteValue);
    if (success) {
      votes[userId] = voteValue;
    }
    return success;
  }
}
