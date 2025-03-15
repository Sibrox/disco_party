import 'dart:async';

import 'package:disco_party/spotify/models/spotify_info.dart';
import 'package:disco_party/spotify/spotify_api.dart';
import 'package:disco_party/spotify/widgets/interaction_vote.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  SpotifyInfo? _currentInfo;
  Timer? _progressTimer;

  @override
  void initState() {
    loadCurrentSong();
    super.initState();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

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

  void loadCurrentSong() async {
    SpotifyInfo? info = await SpotifyApi.player();

    if (info != null) {
      _startProgressTimer();
      Future.delayed(Duration(milliseconds: info.durationsMs - info.progressMs),
          () {
        loadCurrentSong();
      });
    } else {
      Future.delayed(const Duration(seconds: 10), () {
        loadCurrentSong();
      });
    }

    setState(() {
      _currentInfo = info;
    });
  }

  // ignore: non_constant_identifier_names
  Widget SongProgress(SpotifyInfo? info) {
    if (info == null) {
      return Container();
    }

    String formatDuration(int milliseconds) {
      final int seconds = (milliseconds / 1000).floor();
      final int minutes = (seconds / 60).floor();
      final int remainingSeconds = seconds % 60;
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: info.progressMs / info.durationsMs,
              backgroundColor: const Color(0xFFFF80AB).withValues(alpha: 0.2),
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
                formatDuration(info.progressMs),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '-${formatDuration(info.durationsMs - info.progressMs)}',
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
    SpotifyInfo? info = _currentInfo;
    bool showSkeleton = info == null;

    return Skeletonizer(
        enabled: showSkeleton,
        effect: PulseEffect(
          duration: const Duration(milliseconds: 2000),
          from: Colors.white.withAlpha(100),
          to: Colors.white.withAlpha(0),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(36),
            child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC51162).withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]),
                child: Skeleton.replace(
                  height: 250,
                  width: 250,
                  child: showSkeleton ? Container() : Image.network(info.image),
                )),
          ),
          showSkeleton ? Container() : SongProgress(info),
          Skeleton.keep(
              child: Text(
            showSkeleton
                ? 'MI STO CONNETTENDO A SPOTIFY...'
                : 'STAI ASCOLTANDO',
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9E9E9E),
            ),
          )),
          showSkeleton
              ? LoadingAnimationWidget.staggeredDotsWave(
                  color: const Color(0xFFC51162), size: 40)
              : Container(),
          const SizedBox(height: 6),
          Skeleton.keep(
              child: Text(
            showSkeleton ? '' : info.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          showSkeleton ? Container() : const SizedBox(height: 4),
          const SizedBox(height: 4),
          Skeleton.ignore(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person,
                size: 16,
                color: Color(0xFFC51162),
              ),
              const SizedBox(width: 4),
              Text(
                showSkeleton ? '' : info.artist,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFC51162),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )),
          const SizedBox(height: 2),
          Skeleton.ignore(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.album,
                size: 14,
                color: Color(0xFF9E9E9E),
              ),
              const SizedBox(width: 4),
              Text(
                showSkeleton ? '' : info.album,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )),
          const SizedBox(height: 16),
          Skeleton.ignore(
            child: InteractionVote(
              currentInfo: _currentInfo,
            ),
          ),
        ]));
  }
}
