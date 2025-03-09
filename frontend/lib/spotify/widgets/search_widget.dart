import 'package:disco_party/spotify/spotify_api.dart';
import 'package:disco_party/spotify/spotify_song.dart';
import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({
    Key? key,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _controller = TextEditingController();
  List<SpotifySong> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchSong(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var results = await SpotifyApi.searchSongByTitle(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error searching songs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Search for a song',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  _searchSong(_controller.text);
                },
              ),
            ),
            onSubmitted: (value) {
              _searchSong(value);
            },
          ),
        ),
        _isLoading
            ? const CircularProgressIndicator()
            : Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    var song = _searchResults[index];
                    return ListTile(
                      leading: SizedBox(
                        height: 250,
                        child: Image.network(song.image),
                      ),
                      title: Text(song.name),
                      subtitle: Text(song.artist),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              SpotifyApi.addSongToQueue(
                                song.uri,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
