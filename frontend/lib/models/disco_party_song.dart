import 'package:disco_party/spotify/spotify_song.dart';

class Song {
  String userID;
  SpotifySong info;
  Map<dynamic, dynamic>? votes;

  static String table = 'songs';

  String get id => info.id;

  Song({required this.userID, required this.info, this.votes}) {
    votes = {};
  }

  Map<String, dynamic> toJson() {
    var baseJson = {
      'userID': userID,
      'info': info.toJson(),
    };

    return votes!.isEmpty
        ? baseJson
        : {
            ...baseJson,
            'votes': votes,
          };
  }

  static Song fromJson(Map<String, dynamic> json) {
    return Song(
      userID: json['userID'],
      info: SpotifySong.fromJson(json['info']),
      votes: json['votes'],
    );
  }
}
