import 'dart:html' as html;
import 'package:disco_party/logics/disco_party_api.dart';
import 'package:disco_party/logics/string_utils.dart';
import 'package:disco_party/models/user.dart';
import 'package:disco_party/screens/menu_home.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _checkUserIdFromUrl();
  }

  Future<void> _checkUserIdFromUrl() async {
    final uri = Uri.parse(html.window.location.href);
    final queryParams = uri.queryParameters;

    if (queryParams.containsKey('id')) {
      final userId = queryParams['id']!;
      setState(() {
        _userId = userId;
      });

      try {
        User? currentUser = await User.getById(userId);

        if (currentUser == null) {
          throw ("User not found");
        }

        DiscoPartyApi.instance.currentUser = currentUser;

        setState(() {
          _userExists = true;
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
      final userId = _userId ?? StringUtils.generateUserId();

      await DiscoPartyApi.instance.init(
        userId: userId,
        userName: _usernameController.text.trim(),
      );

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
      return Scaffold(
        body: Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: const Color(0xFFC51162), size: 80)),
      );
    }

    if (_userExists) {
      return const MenuPage();
    } else {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Color(0xFFC51162),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Card(
                shadowColor: Color(0xFFC51162),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                margin: const EdgeInsets.all(20),
                elevation: 8,
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
                            'Hai voglia di DISCO PARTY?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Dimostra il tuo talento!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Il tuo nome',
                              hintText: 'Gli altri giocatori ti vedranno così',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Per favore inserisci il tuo nome';
                              }
                              if (value.trim().length < 2) {
                                return 'Nome troppo corto. Minimo 2 caratteri';
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
                              'UNISCITI ALLA FESTA!',
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
