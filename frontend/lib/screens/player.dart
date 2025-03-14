import 'dart:async';

import 'package:disco_party/firebase/song_service.dart';
import 'package:disco_party/logics/disco_party_api.dart';
import 'package:disco_party/models/song.dart';
import 'package:disco_party/spotify/spotify_api.dart';
import 'package:disco_party/spotify/spotify_song.dart';
import 'package:flutter/material.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  PlayerState createState() => PlayerState();
}

class PlayerState extends State<Player> {
  SpotifySong? _currentInfo;
  bool _alreadyVoted = false;
  bool _isYourSong = false;
  bool _isLoading = false;

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
      if (_currentInfo != null && mounted) {
        setState(() {
          _currentInfo = _currentInfo!.copyWith(
            progressMs: _currentInfo!.progressMs + 1000,
          );

          if (_currentInfo!.progressMs >= _currentInfo!.durationsMs) {
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

    SpotifySong info = await SpotifyApi.player();
    Song? song = await SongService.instance.getSong(info.id);
    bool alreadyVoted = song != null &&
        await song.hasUserVoted(DiscoPartyApi.instance.currentUser!.id);
    bool isYourSong =
        song != null && DiscoPartyApi.instance.currentUser!.id == song.userID;
    print("AlreadyVoted: $alreadyVoted isYourSong:$isYourSong");

    setState(() {
      _currentInfo = info;
      _alreadyVoted = alreadyVoted;
      _isYourSong = isYourSong;
    });

    _startProgressTimer();

    Future.delayed(Duration(milliseconds: info.durationsMs - info.progressMs),
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
              value: _currentInfo!.progressMs / _currentInfo!.durationsMs,
              backgroundColor: const Color(0xFFFF80AB).withOpacity(0.2),
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
                _formatDuration(_currentInfo!.progressMs),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '-${_formatDuration(_currentInfo!.durationsMs - _currentInfo!.progressMs)}',
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

  Widget bottomVoteBar() {
    if (_alreadyVoted) {
      return const Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check,
            color: Color(0xFFC51162),
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'Hai già votato!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFFC51162),
            ),
          ),
        ],
      ));
    } else if (_isYourSong) {
      return const Center(
        child: Text(
          'Questo è un tuo brano!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFFC51162),
          ),
        ),
      );
    } else {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton.icon(
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            bool success =
                await DiscoPartyApi.instance.voteSong(_currentInfo!, -1);
            if (success) {
              setState(() {
                _alreadyVoted = true;
              });
            }
            setState(() {
              _isLoading = false;
            });
          },
          icon: const Icon(
            Icons.thumb_down,
            color: Color(0xFFC51162),
            size: 24,
          ),
          label: const Text(
            'Oh no..',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFFC51162),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFC51162),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Color(0xFFC51162), width: 1),
            ),
            shadowColor: Colors.transparent,
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            bool success =
                await DiscoPartyApi.instance.voteSong(_currentInfo!, 1);

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hai votato con successo!'),
                  backgroundColor: const Color(0xFFC51162),
                ),
              );
              setState(() {
                _alreadyVoted = true;
              });
            }

            setState(() {
              _isLoading = false;
            });
          },
          icon: const Icon(Icons.thumb_up, color: Colors.white, size: 24),
          label: const Text(
            'Mi piace!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC51162),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Color(0xFFC51162), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shadowColor: const Color(0x29C51162),
          ),
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: _currentInfo == null
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
                    child: Image.network(_currentInfo!.image),
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
                  _currentInfo!.name,
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
                      _currentInfo!.artist,
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
                      _currentInfo!.album,
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : bottomVoteBar(),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
    );
  }
}
