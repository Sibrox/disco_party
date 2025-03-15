import 'package:disco_party/firebase/song_service.dart';
import 'package:disco_party/logics/disco_party_api.dart';
import 'package:disco_party/models/song.dart';
import 'package:flutter/material.dart';
import 'package:disco_party/spotify/models/spotify_info.dart';
import 'package:disco_party/spotify/spotify_api.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SearchWidget extends StatefulWidget {
  final Function onToggleSearch;
  const SearchWidget({super.key, required this.onToggleSearch});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<SpotifyInfo> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDialog(SpotifyInfo song, List<String> messages) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sei sicur*?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: messages.map((message) => Text(message)).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Non aggiungere'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aggiungi'),
              onPressed: () {
                DiscoPartyApi().addSongToQueue(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hai aggiunto "${song.name}" in coda'),
                    backgroundColor: const Color(0xFFC51162),
                  ),
                );

                setState(() {
                  widget.onToggleSearch();
                  _searchResults = [];
                  _searchController.clear();
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void tryToAddSongInQueue(SpotifyInfo info) async {
    Song? song = await SongService.instance.getSong(info.id);
    song == null
        ? _confirmDialog(info, [
            'Stai per aggiungere la canzone "${info.name}" di "${info.artist}" alla coda.',
            'Questo ti costerà un credito',
            'Sei sicur*?'
          ])
        : _confirmDialog(info, [
            'La canzone "${info.name}" di "${info.artist}" è già presente nella coda.',
            'Puoi aggiungerla gratuitamente, ma il primo DJ ad averla inserita riceverà i voti al posto tuo.'
          ]);
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
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Aggiungi in coda',
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
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide:
                      const BorderSide(color: Color(0xFFFCE4EC), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide:
                      const BorderSide(color: Color(0xFFC51162), width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onSubmitted: _performSearch,
              textInputAction: TextInputAction.search,
              cursorColor: const Color(0xFFC51162),
            )),
        if (_isLoading)
          Padding(
              padding: const EdgeInsets.all(32.0),
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: const Color(0xFFC51162), size: 30))
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
                      tryToAddSongInQueue(song);
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
                                tryToAddSongInQueue(song);
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
