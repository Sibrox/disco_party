class SpotifyInfo {
  final String name;
  final String artist;
  final String album;
  final String image;
  final String uri;

  final int durationsMs;
  final int progressMs;

  String get id => uri.split(':')[2];

  SpotifyInfo({
    required this.name,
    required this.artist,
    required this.album,
    required this.image,
    required this.uri,
    this.durationsMs = 0,
    this.progressMs = 0,
  });
  SpotifyInfo copyWith({
    String? name,
    String? artist,
    String? album,
    String? image,
    String? uri,
    int? progressMs,
    int? durationsMs,
  }) {
    return SpotifyInfo(
      name: name ?? this.name,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      image: image ?? this.image,
      progressMs: progressMs ?? this.progressMs,
      durationsMs: durationsMs ?? this.durationsMs,
      uri: uri ?? this.uri,
    );
  }

  factory SpotifyInfo.fromJson(Map<dynamic, dynamic> json) {
    return SpotifyInfo(
      name: json['name'],
      artist: json['artist'],
      album: json['album'],
      image: json['image'],
      uri: json['uri'],
      durationsMs: json.containsKey('progress_ms') ? json['duration_ms'] : 0,
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
