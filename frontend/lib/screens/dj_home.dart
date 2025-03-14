import 'package:disco_party/screens/current_user_widget.dart';
import 'package:disco_party/spotify/widgets/player.dart';
import 'package:disco_party/spotify/widgets/search_widget.dart';
import 'package:flutter/material.dart';

class DjHome extends StatefulWidget {
  const DjHome({super.key});

  @override
  State<DjHome> createState() => _DjHomeState();
}

class _DjHomeState extends State<DjHome> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch({bool close = false}) {
    setState(() {
      if (close) {
        _isSearchExpanded = false;
        _animationController.reverse();
        return;
      }

      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final searchMaxHeight = screenHeight * 0.75;

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
              const Positioned(
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: CurrentUserWidget(),
                  )),
              Positioned(
                left: 0,
                right: 0,
                child: AnimatedPadding(
                    padding: const EdgeInsets.only(
                      top: 100,
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: const Column(
                      children: [
                        Player(),
                      ],
                    )),
              ),
              _isSearchExpanded
                  ? Container(
                      color: Colors.black38,
                      height: 10000,
                      width: 10000,
                    )
                  : Container(),
              Positioned(
                left: 0,
                right: 0,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 45),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: _isSearchExpanded ? searchMaxHeight : 140,
                          margin:
                              const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                          decoration: BoxDecoration(
                            color: _isSearchExpanded
                                ? Colors.white
                                : Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              // Search widget in an expanded container
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(16),
                                    ),
                                    child: SearchWidget(
                                      onToggleSearch: _toggleSearch,
                                    )),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
