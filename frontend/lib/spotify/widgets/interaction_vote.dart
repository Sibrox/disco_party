import 'package:disco_party/firebase/song_service.dart';
import 'package:disco_party/logics/disco_party_api.dart';
import 'package:disco_party/models/song.dart';
import 'package:disco_party/spotify/models/spotify_info.dart';
import 'package:flutter/material.dart';

class InteractionVote extends StatefulWidget {
  final SpotifyInfo currentInfo;
  const InteractionVote({super.key, required this.currentInfo});

  @override
  State<InteractionVote> createState() => _InteractionVoteState();
}

class _InteractionVoteState extends State<InteractionVote> {
  bool _isAlredyVoted = false;
  bool _isYourSong = false;

  bool _checking = true;

  @override
  void didUpdateWidget(covariant InteractionVote oldWidget) {
    checkCurrentSongInteraction();
    super.didUpdateWidget(oldWidget);
  }

  void checkCurrentSongInteraction() async {
    bool checking = true;

    bool isAlredyVoted = false;
    bool isYourSong = false;

    Song? currentSong =
        await SongService.instance.getSong(widget.currentInfo.id);

    var currentUser = DiscoPartyApi.instance.currentUser;
    if (currentSong != null && currentUser != null) {
      isAlredyVoted = await currentSong.hasUserVoted(currentUser.id);
      isYourSong = currentSong.userID == currentUser.id;
    }

    checking = false;

    setState(() {
      _isAlredyVoted = isAlredyVoted;
      _isYourSong = isYourSong;
      _checking = checking;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_isAlredyVoted) {
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
    }

    if (_isYourSong) {
      return const Center(
        child: Text(
          'Questo è un tuo brano!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton.icon(
          onPressed: () async {
            setState(() {
              _checking = true;
            });

            await DiscoPartyApi.instance.voteSong(widget.currentInfo, -1);

            setState(() {
              _isAlredyVoted = true;
              _checking = false;
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
              _checking = true;
            });

            await DiscoPartyApi.instance.voteSong(widget.currentInfo, 1);

            setState(() {
              _isAlredyVoted = true;
              _checking = false;
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
        )
      ]),
    );
  }
}
