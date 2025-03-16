import 'package:disco_party/models/song.dart';
import 'package:firebase_database/firebase_database.dart';

class SongService {
  static final SongService instance = SongService._internal();
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('disco_party/songs');

  factory SongService() {
    return instance;
  }

  SongService._internal();

  Future<Song> addSong(Song song) async {
    try {
      await _dbRef.child(song.id).set(song.toJson());
      return song;
    } catch (e) {
      throw Exception('Failed to add song: $e');
    }
  }

  Future<Song?> getSong(String songId) async {
    try {
      final DataSnapshot snapshot = await _dbRef.child(songId).get();

      if (snapshot.exists && snapshot.value != null) {
        return Song.fromJson(snapshot.value as Map<dynamic, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get song: $e');
    }
  }

  Future<List<Song>> getAllSongs() async {
    try {
      final DataSnapshot snapshot = await _dbRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> values =
            snapshot.value as Map<dynamic, dynamic>;
        return values.entries
            .map((entry) => Song.fromJson(entry.value as Map<dynamic, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get songs: $e');
    }
  }

  Future<List<Song>> getUserSongs(String userId) async {
    try {
      final DataSnapshot snapshot =
          await _dbRef.orderByChild('userID').equalTo(userId).get();

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> values =
            snapshot.value as Map<dynamic, dynamic>;
        return values.entries
            .map((entry) => Song.fromJson(entry.value as Map<dynamic, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get user songs: $e');
    }
  }

  Future<bool> addVote(String songId, String userId, int voteValue) async {
    try {
      final DataSnapshot snapshot =
          await _dbRef.child(songId).child('votes').child(userId).get();

      if (snapshot.exists) {
        return false;
      }

      await _dbRef.child(songId).child('votes').child(userId).set(voteValue);
      return true;
    } catch (e) {
      throw Exception('Failed to add vote: $e');
    }
  }

  Future<int> calculateTotalVotes(String songId) async {
    try {
      final DataSnapshot snapshot =
          await _dbRef.child(songId).child('votes').get();

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> votes =
            snapshot.value as Map<dynamic, dynamic>;
        return votes.values.fold<int>(0, (sum, value) => sum + (value as int));
      }
      return 0;
    } catch (e) {
      throw Exception('Failed to calculate votes: $e');
    }
  }

  Future<List<Song>> getTopVotedSongs({int limit = 10}) async {
    try {
      List<Song> allSongs = await getAllSongs();

      List<MapEntry<Song, int>> songsWithVotes = [];

      for (var song in allSongs) {
        int totalVotes = 0;
        song.votes.forEach((user, vote) {
          totalVotes += vote as int;
        });

        songsWithVotes.add(MapEntry(song, totalVotes));
      }

      songsWithVotes.sort((a, b) => b.value.compareTo(a.value));

      return songsWithVotes.take(limit).map((entry) => entry.key).toList();
    } catch (e) {
      throw Exception('Failed to get top voted songs: $e');
    }
  }

  Future<String?> getDJBySongID({required String songID}) {
    try {
      return _dbRef.child(songID).child('userID').get().then((snapshot) {
        if (snapshot.exists) {
          return snapshot.value as String;
        }
        return null;
      });
    } catch (error) {
      throw Exception('Failed to get DJ by song ID: $error');
    }
  }

  Future<List<Song>> getSongLeaderboard() async {
    try {
      List<Song> allSongs = await getAllSongs();
      allSongs = allSongs
          .where((song) =>
              song.votes.isNotEmpty &&
              song.votes.entries
                  .where((vote) => vote.value > 0)
                  .toList()
                  .isNotEmpty)
          .toList();
      allSongs.sort((a, b) {
        int positiveVotesA = a.votes.values.where((vote) => vote > 0).length;
        int positiveVotesB = b.votes.values.where((vote) => vote > 0).length;

        return positiveVotesB.compareTo(positiveVotesA);
      });

      return allSongs.take(10).toList();
    } catch (error) {
      throw Exception('Failed to get song leaderboard: $error');
    }
  }
}
