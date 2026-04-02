import 'package:flutter/material.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:mood_app/screens/playlists_screen.dart';
import 'package:mood_app/screens/videos_screen.dart';
import 'package:mood_app/screens/stories_screen.dart';

class RecommendationsScreen extends StatelessWidget {
  final String userName;
  final String emotion;

  const RecommendationsScreen({
    Key? key,
    required this.userName,
    required this.emotion,
  }) : super(key: key);

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: iconColor,
              radius: 25,
              child: Icon(icon, color: Colors.white, size: 25),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: ThemeColors.redColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        emotion: emotion,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
          children: [
            Text(
              'Welcome, $userName',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ThemeColors.redColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Mood is $emotion',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColors.accentColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Embrace every moment and let your happiness radiate from within',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.darkTextColor,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85, // Added this to fix the overflow
                children: [
                  _buildCard(
                    title: 'Music',
                    subtitle: 'Let the music lift your spirits',
                    icon: Icons.music_note,
                    iconColor: Colors.teal,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaylistsScreen(emotion: emotion))),
                  ),
                  _buildCard(
                    title: 'Video',
                    subtitle: 'watch that video and get Inspired!',
                    icon: Icons.play_arrow,
                    iconColor: Colors.teal,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideosScreen(emotion: emotion))),
                  ),
                  _buildCard(
                    title: 'Stories',
                    subtitle: 'Discover the power of Imagination',
                    icon: Icons.book,
                    iconColor: Colors.teal,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoriesScreen(emotion: emotion))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
