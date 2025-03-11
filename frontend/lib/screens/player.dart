import 'dart:async';

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

  String _formatDuration(int milliseconds) {
    final int seconds = (milliseconds / 1000).floor();
    final int minutes = (seconds / 60).floor();
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Timer? _progressTimer;

  void _startProgressTimer() {
    _progressTimer?.cancel();

    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSong != null && mounted) {
        setState(() {
          _currentSong = _currentSong!.copyWith(
            progressMs: _currentSong!.progressMs + 1000,
          );

          if (_currentSong!.progressMs >= _currentSong!.durationsMs) {
            timer.cancel();
            loadCurrentSong();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void loadCurrentSong() async {
    _progressTimer?.cancel();

    SpotifySong song = await SpotifyApi.player();
    setState(() {
      _currentSong = song;
    });

    _startProgressTimer();

    Future.delayed(Duration(milliseconds: song.durationsMs - song.progressMs),
        () {
      if (mounted) {
        loadCurrentSong();
      }
    });
  }

  Widget progressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _currentSong!.progressMs / _currentSong!.durationsMs,
              backgroundColor: Color(0xFFFF80AB).withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFC51162)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentSong!.progressMs),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '-${_formatDuration(_currentSong!.durationsMs - _currentSong!.progressMs)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: _currentSong == null
          ? const CircularProgressIndicator()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(36),
                  child: Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC51162).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]),
                    child: Image.network(_currentSong!.image),
                  ),
                ),
                progressIndicator(),
                const Text(
                  'STAI ASCOLTANDO',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentSong!.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Color(0xFFC51162),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentSong!.artist,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC51162),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.album,
                      size: 14,
                      color: Color(0xFF9E9E9E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentSong!.album,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      DiscoPartyApi.instance.voteSong(_currentSong!.id, -1);
                    },
                    icon: const Icon(
                      Icons.thumb_down,
                      color: Color(0xFFC51162),
                      size: 18,
                    ),
                    label: const Text(
                      'No, ti prego :(',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC51162),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFC51162),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                            color: Color(0xFFC51162), width: 1),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      DiscoPartyApi.instance.voteSong(_currentSong!.id, 1);
                    },
                    icon: const Icon(
                      Icons.thumb_up,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Mi piace!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC51162),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: const Color(0x29C51162),
                    ),
                  ),
                ]),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
    );
  }
}
