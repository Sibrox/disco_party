import 'package:disco_party/logics/disco_party_api.dart';
import 'package:flutter/material.dart';
import 'package:disco_party/spotify/spotify_song.dart';
import 'package:disco_party/spotify/spotify_api.dart';

class SearchWidget extends StatefulWidget {
  final Function onToggleSearch;
  const SearchWidget({super.key, required this.onToggleSearch});

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
    if (_searchResults.isEmpty) {
      widget.onToggleSearch();
    }

    await Future.delayed(const Duration(milliseconds: 300), () {});

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
              hintText: 'Metti la tua musica!',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFFC51162),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFFC51162),
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    widget.onToggleSearch(close: true);
                    _searchResults = [];
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFCE4EC), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFC51162), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onSubmitted: _performSearch,
            textInputAction: TextInputAction.search,
            cursorColor: const Color(0xFFC51162),
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(
              color: Color(0xFFC51162),
            ),
          )
        else if (_searchResults.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final song = _searchResults[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Color(0xFFFCE4EC), width: 1),
                  ),
                  child: InkWell(
                    onTap: () {
                      DiscoPartyApi().addSongToQueue(song);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text('Added "${song.name}" to queue')),
                            ],
                          ),
                          backgroundColor: const Color(0xFFC51162),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      setState(() {
                        widget.onToggleSearch();
                        _searchResults = [];
                        _searchController.clear();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Album art with pink border
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFFFD8E1), width: 2),
                            ),
                            child: ClipRRect(
                              child: Image.network(
                                song.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFFFCE4EC),
                                    child: const Icon(
                                      Icons.music_note,
                                      size: 28,
                                      color: Color(0xFFC51162),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Song details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${song.artist} • ${song.album}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Add button
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFCE4EC),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.add,
                                size: 20,
                                color: Color(0xFFC51162),
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                DiscoPartyApi().addSongToQueue(song);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Added "${song.name}" to queue'),
                                    backgroundColor: const Color(0xFFC51162),
                                  ),
                                );

                                setState(() {
                                  widget.onToggleSearch();
                                  _searchResults = [];
                                  _searchController.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
