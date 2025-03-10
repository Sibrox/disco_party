class Song {
  String album;
  String artist;
  String image;
  String name;
  String uri;
  Map<dynamic,dynamic> votes;
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
  Map<dynamic, dynamic> songs;

  UserInfos({
    required this.id,
    required this.credits,
    required this.name,
    this.team,
    this.songs = const {},
  });

  toJson() {
    return {
      'id': id,
      'credits': credits,
      'name': name,
      'team': team,
      'songs': songs,
    };
  }

  factory UserInfos.fromJson(Map<dynamic, dynamic> json) {
 
    return UserInfos(
      id: json['id'],
      credits: json['credits'],
      name: json['name'],
      team: json['team'],
      songs: json['songs'] ?? {},
    );
  }
}
