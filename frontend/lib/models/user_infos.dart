class Song {
  String album;
  String artist;
  String image;
  String name;
  String uri;
  List<int> votes;
  String userID;
  String get id => uri.split(':')[2];

  Song({
    required this.album,
    required this.artist,
    required this.image,
    required this.name,
    required this.uri,
    required this.votes,
    required this.userID,
  });

  toJson() {
    var baseJson = {
      'id': id,
      'album': album,
      'artist': artist,
      'image': image,
      'name': name,
      'uri': uri,
      'userID': userID,
    };

    return votes.isEmpty
        ? baseJson
        : {
            ...baseJson,
            'votes': votes,
          };
  }
}

class UserInfos {
  String id;
  int credits;
  String name;
  String? team;
  List<Song> songs;

  UserInfos({
    required this.id,
    required this.credits,
    required this.name,
    this.team,
    this.songs = const [],
  });

  toJson() {
    return {
      'id': id,
      'credits': credits,
      'name': name,
      'team': team,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  factory UserInfos.fromJson(Map<dynamic, dynamic> json) {
    List<Song> songsList = [];
    if (json.containsKey('songs')) {
      final songsMap = json['songs'] as Map;
      songsList = songsMap.values.map((song) {
        return Song(
          userID: song['userID'],
          album: song['album'],
          artist: song['artist'],
          image: song['image'],
          name: song['name'],
          uri: song['uri'],
          votes: song['votes']?.cast<int>() ?? [],
        );
      }).toList();
    }
    return UserInfos(
      id: json['id'],
      credits: json['credits'],
      name: json['name'],
      team: json['team'],
      songs: songsList,
    );
  }
}
