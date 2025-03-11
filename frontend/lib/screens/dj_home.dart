import 'package:disco_party/screens/player.dart';
import 'package:flutter/material.dart';

class DjHome extends StatelessWidget {
  const DjHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            // Matching gradient from login screen with a subtle adjustment
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0xFFC51162), Colors.white],
                stops: [0.0, 0.8], // Adjust gradient stops for better visual
              ),
            ),
            child: const SafeArea(
              child: Column(
                children: [
                  Player(),
                ],
              ),
            )));
  }
}
