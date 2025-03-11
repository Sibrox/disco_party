class SpotifySong {
  final String name;
  final String artist;
  final String album;
  final String image;
  final String uri;

  final int durationsMs;
  final int progressMs;

  String get id => uri.split(':')[2];

  SpotifySong({
    required this.name,
    required this.artist,
    required this.album,
    required this.image,
    required this.uri,
    this.durationsMs = 0,
    this.progressMs = 0,
  });

  factory SpotifySong.fromJson(Map<dynamic, dynamic> json) {
    print(json);
    return SpotifySong(
      name: json['name'],
      artist: json['artist'],
      album: json['album'],
      image: json['image'],
      uri: json['uri'],
      durationsMs: json['duration_ms'],
      progressMs: json.containsKey('progress_ms') ? json['progress_ms'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'artist': artist,
      'album': album,
      'image': image,
      'uri': uri,
      'durations_ms': durationsMs,
    };
  }
}
