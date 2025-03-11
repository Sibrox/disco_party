import 'package:disco_party/logics/disco_party_api.dart';
import 'package:disco_party/spotify/spotify_api.dart';
import 'package:disco_party/spotify/spotify_song.dart';
import 'package:flutter/material.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  PlayerState createState() => PlayerState();
}

class PlayerState extends State<Player> {
  SpotifySong? _currentSong;

  @override
  void initState() {
    super.initState();
    loadCurrentSong();
  }

  void loadCurrentSong() async {
    SpotifySong song = await SpotifyApi.player();
    setState(() {
      _currentSong = song;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: _currentSong == null
          ? const CircularProgressIndicator()
          : Column(
              children: [
                Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 10),
                  ),
                  child: Image.network(_currentSong!.image),
                ),
                const Text('Stai ascontando'),
                Text(_currentSong!.name),
                Text('di ${_currentSong!.artist}'),
                const SizedBox(height: 16),
                // Vote buttons
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.thumb_down,
                      color: Colors.white,
                    ),
                    label: const Text('Dislike'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.thumb_up,
                      color: Colors.white,
                    ),
                    label: const Text('Like'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                    ),
                  )
                ]),
              ],
            ),
    );
  }
}
