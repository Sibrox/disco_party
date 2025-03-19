import 'dart:convert';

import 'package:disco_party/spotify/models/spotify_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SpotifyApi {
  static String get baseUrl {
    final serverIp = dotenv.env['SERVER_IP'] ?? 'localhost';
    final serverPort = dotenv.env['SERVER_PORT'] ?? '8080';
    return 'http://$serverIp:$serverPort';
  }

  static Future<SpotifyInfo?> player() async {
    var response = await http.get(Uri.parse('$baseUrl/player'));

    if (response.statusCode == 404) return null;

    return SpotifyInfo.fromJson(jsonDecode(response.body));
  }

  static searchSongByTitle(String query) {
    var url = '$baseUrl/search?q=$query';
    return http.get(Uri.parse(url)).then((response) {
      var trackJson = jsonDecode(response.body) as List<dynamic>;
      return trackJson.map((track) => SpotifyInfo.fromJson(track)).toList();
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
