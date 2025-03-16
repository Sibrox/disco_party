import 'package:disco_party/screens/current_user_widget.dart';
import 'package:disco_party/screens/disco_bottom_bar.dart';
import 'package:disco_party/screens/leadboard_user.dart';
import 'package:disco_party/screens/leaderboard.dart';
import 'package:disco_party/spotify/widgets/player.dart';
import 'package:flutter/material.dart'; // Create this page
import 'package:disco_party/screens/search_page.dart'; // Create this page

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _currentIndex = 1; // Start with Player screen
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _pages = [
    const UserLeaderboard(),
    const Player(),
    const SearchPage(),
  ];

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> getCenteredPages(double height) {
    return _pages.map((page) {
      return Container(
          height: height,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: page,
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFFC51162), Colors.white],
            stops: [0.0, 0.8],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: getCenteredPages(height),
              ),

              // Bottom navigation
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: DiscoBottomBar(
                  currentIndex: _currentIndex,
                  onTap: _onNavTap,
                ),
              ),
              const Positioned(top: 0, child: CurrentUserWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
