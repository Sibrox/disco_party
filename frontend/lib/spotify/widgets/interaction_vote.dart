import 'package:disco_party/firebase/song_service.dart';
import 'package:disco_party/logics/disco_party_api.dart';
import 'package:disco_party/models/song.dart';
import 'package:disco_party/spotify/models/spotify_info.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class InteractionVote extends StatefulWidget {
  final SpotifyInfo? currentInfo;
  const InteractionVote({super.key, required this.currentInfo});

  @override
  State<InteractionVote> createState() => _InteractionVoteState();
}

class _InteractionVoteState extends State<InteractionVote> {
  bool _isAlredyVoted = false;
  bool _isYourSong = false;

  bool _checking = true;
  String? _previousSongId;

  @override
  void initState() {
    super.initState();
    _previousSongId = widget.currentInfo?.id;
    checkCurrentSongInteraction();
  }

  @override
  void didUpdateWidget(InteractionVote oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentId = widget.currentInfo?.id;
    if (currentId != _previousSongId) {
      _previousSongId = currentId;

      setState(() {
        _isAlredyVoted = false;
        _isYourSong = false;
        _checking = true;
      });

      checkCurrentSongInteraction();
    }
  }

  void checkCurrentSongInteraction() async {
    var songId = _previousSongId;
    if (songId == null) {
      if (mounted) {
        setState(() {
          _checking = false;
        });
      }
      return;
    }

    bool isAlredyVoted = false;
    bool isYourSong = false;

    try {
      Song? currentSong = await SongService.instance.getSong(songId);

      var currentUser = DiscoPartyApi.instance.currentUser;
      if (currentSong != null && currentUser != null) {
        isAlredyVoted = await currentSong.hasUserVoted(currentUser.id);
        isYourSong = currentSong.userID == currentUser.id;
      }
    } catch (e) {
      print("Error checking song interaction: $e");
    }

    if (mounted) {
      setState(() {
        _isAlredyVoted = isAlredyVoted;
        _isYourSong = isYourSong;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentInfo = widget.currentInfo;
    if (currentInfo == null) {
      return Container();
    }

    if (_checking) {
      return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
              color: const Color(0xFFC51162), size: 30));
    }

    if (_isAlredyVoted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: BoxBorder.lerp(
            Border.all(color: const Color(0xFFC51162), width: 1.5),
            Border.all(color: Colors.white, width: 1.5),
            0.5,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 12),
            Text(
              'Hai già votato!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFFC51162),
              ),
            ),
            SizedBox(width: 12),
            Icon(
              Icons.check_circle,
              color: Color(0xFFC51162),
              size: 18,
            ),
            SizedBox(width: 12),
          ],
        ),
      );
    }

    if (_isYourSong) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: BoxBorder.lerp(
            Border.all(color: const Color(0xFFC51162), width: 1.5),
            Border.all(color: Colors.white, width: 1.5),
            0.5,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 12),
            Text(
              'Questo è un tuo brano',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFFC51162),
              ),
            ),
            SizedBox(width: 12),
            Icon(
              Icons.star,
              color: Color(0xFFC51162),
              size: 24,
            ),
            SizedBox(width: 12),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dislike button
          ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                _checking = true;
              });

              await DiscoPartyApi.instance.voteSong(currentInfo, -1);

              setState(() {
                _isAlredyVoted = true;
                _checking = false;
              });
            },
            icon: const Icon(
              Icons.thumb_down,
              color: Color(0xFFC51162),
              size: 22,
            ),
            label: const Text(
              'Oh no..',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFC51162),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFC51162),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Color(0xFFC51162), width: 1.5),
              ),
              shadowColor: Colors.transparent,
            ),
          ),

          const SizedBox(width: 16),

          // Like button
          ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                _checking = true;
              });

              await DiscoPartyApi.instance.voteSong(currentInfo, 1);

              setState(() {
                _isAlredyVoted = true;
                _checking = false;
              });
            },
            icon: const Icon(
              Icons.thumb_up,
              color: Colors.white,
              size: 22,
            ),
            label: const Text(
              'Mi piace!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC51162),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Color(0xFFC51162), width: 1.5),
              ),
              shadowColor: const Color(0x29C51162),
            ),
          )
        ],
      ),
    );
  }
}
