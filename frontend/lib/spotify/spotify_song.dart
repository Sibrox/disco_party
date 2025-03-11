class SpotifySong {
  final String name;
  final String artist;
  final String album;
  final String image;
  final String uri;
  String get id => uri.split(':')[2];

  SpotifySong({
    required this.name,
    required this.artist,
    required this.album,
    required this.image,
    required this.uri,
  });

  factory SpotifySong.fromJson(Map<dynamic, dynamic> json) {
    return SpotifySong(
      name: json['name'],
      artist: json['artist'],
      album: json['album'],
      image: json['image'],
      uri: json['uri'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'artist': artist,
      'album': album,
      'image': image,
      'uri': uri,
    };
  }
}
