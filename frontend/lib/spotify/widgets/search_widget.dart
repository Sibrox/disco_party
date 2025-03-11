import 'package:disco_party/logics/disco_party_api.dart';
import 'package:disco_party/models/disco_party_song.dart';
import 'package:flutter/material.dart';
import 'package:disco_party/spotify/spotify_song.dart';
import 'package:disco_party/spotify/spotify_api.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<SpotifySong> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await SpotifyApi.searchSongByTitle(query);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for songs...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults = [];
                  });
                },
              ),
            ),
            onSubmitted: _performSearch,
            textInputAction: TextInputAction.search,
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_searchResults.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final song = _searchResults[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.network(
                      song.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.music_note, size: 25),
                        );
                      },
                    ),
                  ),
                  title: Text(song.name),
                  subtitle: Text('${song.artist} • ${song.album}'),
                  onTap: () {
                    var firebaseSong = Song(info: song, userID: 'dj');
                    DiscoPartyApi().addSongToQueue(firebaseSong);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added ${song.name} to queue')),
                    );

                    setState(() {
                      _searchResults = [];
                      _searchController.clear();
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
