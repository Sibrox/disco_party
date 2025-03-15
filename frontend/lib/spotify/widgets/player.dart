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

class _PlayerState extends State<Player> with WidgetsBindingObserver {
  SpotifyInfo? _currentInfo;
  Timer? _progressTimer;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    loadCurrentSong();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadCurrentSong();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _progressTimer?.cancel();
      _refreshTimer?.cancel();
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();

    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel(); // Cancel if not mounted
        return;
      }

      if (_currentInfo != null) {
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
    _refreshTimer?.cancel();

    if (!mounted) return;

    try {
      SpotifyInfo? info = await SpotifyApi.player();

      if (!mounted) return;

      setState(() {
        _currentInfo = info;
      });

      if (info != null) {
        _startProgressTimer();

        int delayMs = info.durationsMs - info.progressMs;
        _refreshTimer = Timer(Duration(milliseconds: delayMs), () {
          if (mounted) {
            loadCurrentSong();
          }
        });
      } else {
        _refreshTimer = Timer(const Duration(seconds: 10), () {
          if (mounted) {
            loadCurrentSong();
          }
        });
      }
    } catch (e) {
      if (!mounted) return;

      print("Error loading song: $e");

      // Try again in 10 seconds in case of error
      _refreshTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          loadCurrentSong();
        }
      });
    }
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
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 18),
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
