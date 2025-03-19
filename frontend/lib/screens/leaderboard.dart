import 'package:disco_party/firebase/user_service.dart';
import 'package:flutter/material.dart';
import 'package:disco_party/models/song.dart';
import 'package:disco_party/firebase/song_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFFC51162);
  final Color secondaryColor = Colors.white;

  // Tab controller
  late TabController _tabController;

  List<Song> songs = [];
  List<MapEntry<String, int>> userVotes = [];
  bool _isLoading = true;
  Map<String, String> userNames = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 1. Load songs
      final leaderboardSongs = await SongService.instance.getSongLeaderboard();
      final userVotesMap = <String, int>{};
      final userIdsToFetch = <String>{};

      // 2. Calculate votes and collect user IDs
      for (var song in leaderboardSongs) {
        if (!userIdsToFetch.contains(song.userID)) {
          userIdsToFetch.add(song.userID);
        }
        for (var entry in song.votes.entries) {
          if (entry.value > 0) {
            // Update vote counts as before
            userVotesMap.update(
                song.userID, (value) => (value + entry.value).toInt(),
                ifAbsent: () => 1);
          }
        }
      }

      // 3. Fetch user data in bulk
      userNames = await _getUserNames(userIdsToFetch.toList());

      if (mounted) {
        setState(() {
          songs = leaderboardSongs;
          userVotes = userVotesMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error loading leaderboard: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to get user names from Firebase
  Future<Map<String, String>> _getUserNames(List<String> userIds) async {
    final result = <String, String>{};

    try {
      // Get user data from Firebase
      final usersData = await UserService.instance.getUsersByIds(userIds);

      // Create a map of user ID to name
      for (var user in usersData) {
        result[user.id] = user.name;
      }
    } catch (e) {
      print('Error fetching user names: $e');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Get the bottom padding to account for navigation bar
    double bottomPadding = 75;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: LoadingAnimationWidget.staggeredDotsWave(
                        color: primaryColor, size: 25),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Caricamento classifica...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(vertical: 45),
              child: Column(
                children: [
                  // Custom tab bar with gradient background
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: primaryColor,
                        ),
                        labelColor: secondaryColor,
                        unselectedLabelColor: primaryColor,
                        dividerColor: Colors.transparent, // Add this line
                        indicatorSize: TabBarIndicatorSize.tab, // Add this line
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        tabs: const [
                          Tab(
                            icon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.emoji_events),
                                    SizedBox(width: 8),
                                    Text('Top Songs'),
                                  ],
                                )),
                          ),
                          Tab(
                            icon: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people),
                                    SizedBox(width: 8),
                                    Text('Top Users'),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // TOP SONGS TAB
                        _buildTopSongsTab(bottomPadding),

                        // TOP USERS TAB
                        _buildTopUsersTab(bottomPadding),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTopSongsTab(double bottomPadding) {
    return songs.isEmpty
        ? _buildEmptyState(
            icon: Icons.music_off,
            message: 'Nessuna canzone in classifica',
          )
        : ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomPadding),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final positiveVotes =
                  song.votes.values.where((vote) => vote > 0).length;

              // Special styling for top 3 songs
              final isTopThree = index < 3;
              final cardColor = isTopThree
                  ? [
                      const Color(0xFFFFD700), // Gold
                      const Color(0xFFC0C0C0), // Silver
                      const Color(0xFFCD7F32), // Bronze
                    ][index]
                  : Colors.white;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    // Replace the existing leading with this image-based version
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isTopThree
                                ? cardColor.withOpacity(0.2)
                                : primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isTopThree
                                ? Icon(
                                    [
                                      Icons.looks_one,
                                      Icons.looks_two,
                                      Icons.looks_3,
                                    ][index],
                                    color:
                                        isTopThree ? cardColor : primaryColor,
                                    size: 18,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            song.info.image,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.music_note,
                                  color: Color(0xFFC51162),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      song.info.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: isTopThree ? 16 : 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.info.artist,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: isTopThree ? 14 : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isTopThree)
                          Text(
                            song.info.album,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isTopThree ? cardColor : primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$positiveVotes',
                            style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildTopUsersTab(double bottomPadding) {
    return userVotes.isEmpty
        ? _buildEmptyState(
            icon: Icons.person_off,
            message: 'Nessun utente in classifica',
          )
        : ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomPadding),
            itemCount: userVotes.length,
            itemBuilder: (context, index) {
              final userVote = userVotes[index];

              final userName = '${userNames[userVote.key]} (#${userVote.key})';

              final isTopThree = index < 3;
              final cardColor = isTopThree
                  ? [
                      const Color(0xFFFFD700), // Gold
                      const Color(0xFFC0C0C0), // Silver
                      const Color(0xFFCD7F32), // Bronze
                    ][index]
                  : Colors.white;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isTopThree
                            ? cardColor.withOpacity(0.2)
                            : primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isTopThree ? cardColor : primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isTopThree
                            ? Icon(
                                [
                                  Icons.looks_one,
                                  Icons.looks_two,
                                  Icons.looks_3,
                                ][index],
                                color: isTopThree ? cardColor : primaryColor,
                                size: 24,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    title: Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: isTopThree ? 16 : 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isTopThree ? cardColor : primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${userVote.value}',
                            style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withAlpha(50),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
