import 'package:flutter/material.dart';
import 'package:disco_party/spotify/spotify_song.dart';

class CurrentSongWidget extends StatelessWidget {
  final SpotifySong song;
  final bool isPlaying;

  const CurrentSongWidget({
    super.key,
    required this.song,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Album cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                song.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(width: 16.0),
            // Song details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    song.artist,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    song.album,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Playing indicator
            if (isPlaying)
              const Icon(
                Icons.equalizer,
                color: Colors.green,
                size: 32.0,
              ),
          ],
        ),
      ),
    );
  }
}
