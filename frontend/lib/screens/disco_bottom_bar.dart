import 'package:flutter/material.dart';

class DiscoBottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DiscoBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<DiscoBottomBar> createState() => _DiscoBottomBarState();
}

class _DiscoBottomBarState extends State<DiscoBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC51162).withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildNavItem(0, Icons.equalizer),
        _buildNavItem(1, Icons.music_note),
        _buildNavItem(2, Icons.search),
      ]),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = widget.currentIndex == index;

    return Container(
      width: 50,
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFC51162) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: () => widget.onTap(index),
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFFC51162),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
