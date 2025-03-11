import 'package:disco_party/logics/disco_party_api.dart';
import 'package:disco_party/models/disco_party_song.dart';
import 'package:disco_party/spotify/spotify_song.dart';
import 'package:flutter/material.dart';
import 'dart:html';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Map<String, dynamic>? queryParams;
  late String url;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final DiscoPartyApi logic = DiscoPartyApi();

  @override
  void initState() {
    super.initState();
    getQueryParams();
  }

  void getQueryParams() {
    url = window.location.href;
    final uri = Uri.parse(url);
    setState(() {
      queryParams = uri.queryParameters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Card(
            elevation: 8,
            shadowColor: Colors.purpleAccent.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'DISCO PARTY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Enter your name',
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.deepPurple, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() &&
                            queryParams?['id'] != null) {
                          final String name = _nameController.text;

                          logic.getOrCreateUserInfos(
                              username: name, id: queryParams!['id']);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'START DANCING',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {},
                        child: const Text("Add song to queue")),
                    ElevatedButton(
                      onPressed: () {
                        var spotifySong = SpotifySong(
                          album: 'album',
                          artist: 'artist',
                          image: 'image',
                          name: 'name',
                          uri: 'spotify:track:23xcxs22',
                        );

                        Song mockUpSong = Song(
                          info: spotifySong,
                          userID: '2324',
                          votes: {},
                        );
                        logic.voteSong(mockUpSong, 1);
                      },
                      child: const Text("Vote song"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
