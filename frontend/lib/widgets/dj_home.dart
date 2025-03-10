import 'package:disco_party/spotify/widgets/search_widget.dart';
import 'package:disco_party/widgets/player.dart';
import 'package:flutter/material.dart';

class DjHome extends StatelessWidget {
  const DjHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          Player(),
          Expanded(
            child: SearchWidget(),
          ),
        ],
      ),
    );
  }
}
