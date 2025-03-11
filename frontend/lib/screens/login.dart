import 'dart:html' as html;
import 'package:disco_party/logics/disco_party_api.dart';
import 'package:disco_party/logics/string_utils.dart';
import 'package:disco_party/widgets/dj_home.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = true;
  bool _userExists = false;
  String? _userId;
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DiscoPartyApi _api = DiscoPartyApi();

  @override
  void initState() {
    super.initState();
    _checkUserIdFromUrl();
  }

  Future<void> _checkUserIdFromUrl() async {
    // Get the URL and parse it
    final uri = Uri.parse(html.window.location.href);
    final queryParams = uri.queryParameters;

    // Check if 'id' parameter exists in URL
    if (queryParams.containsKey('id')) {
      final userId = queryParams['id']!;
      setState(() {
        _userId = userId;
      });

      // Check if this user ID exists in Firebase
      try {
        final snapshot = await FirebaseDatabase.instance
            .ref('disco_party/users/$userId')
            .get();

        setState(() {
          _userExists = snapshot.exists;
          _isLoading = false;
        });
      } catch (e) {
        print('Error checking user: $e');
        setState(() {
          _userExists = false;
          _isLoading = false;
        });
      }
    } else {
      // No ID in URL
      setState(() {
        _userId = null;
        _userExists = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate a new user ID if needed
      final userId = _userId ?? StringUtils.generateUserId();

      // Create user with API
      await _api.getOrCreateUserInfos(
        username: _usernameController.text.trim(),
        id: userId,
      );

      // If we created a new ID, add it to URL
      if (_userId == null) {
        final uri = Uri.parse(html.window.location.href);
        final newUrl = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'id': userId,
        }).toString();

        html.window.history.pushState(null, '', newUrl);
      }

      setState(() {
        _userExists = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error creating user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create account: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userExists) {
      // User exists, show DjHome
      return const DjHome();
    } else {
      // User does not exist, show login form
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF80AB), Color(0xFFC51162)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(20),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: 400,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.music_note,
                            size: 80,
                            color: Color(0xFFC51162),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Welcome to Disco Party',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Enter your name to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              hintText: 'How should we call you?',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.trim().length < 2) {
                                return 'Name is too short';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _createNewUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC51162),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 0),
                            ),
                            child: const Text(
                              'JOIN THE PARTY',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
