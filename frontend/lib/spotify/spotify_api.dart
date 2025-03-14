import 'dart:convert';

import 'package:disco_party/spotify/spotify_song.dart';
import 'package:http/http.dart' as http;

class SpotifyApi {
  static const String baseUrl = 'http://localhost:8080';

  static Future<SpotifySong?> player() async {
    //TODO: heandle if the song is not playing
    var response = await http.get(Uri.parse('$baseUrl/player'));

    if (response.statusCode == 404) return null;

    return SpotifySong.fromJson(jsonDecode(response.body));
  }

  static searchSongByTitle(String query) {
    var url = '$baseUrl/search?q=$query';
    return http.get(Uri.parse(url)).then((response) {
      var trackJson = jsonDecode(response.body) as List<dynamic>;
      return trackJson.map((track) => SpotifySong.fromJson(track)).toList();
    });
  }

  static Future<void> addSongToQueue(uri) async {
    var url = '$baseUrl/add_to_queue?uri=$uri';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to add song to queue');
    }
  }
}
