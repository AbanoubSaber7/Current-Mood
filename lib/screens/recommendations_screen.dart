import 'package:flutter/material.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:mood_app/screens/playlists_screen.dart';
import 'package:mood_app/screens/videos_screen.dart';
import 'package:mood_app/screens/stories_screen.dart';
import 'package:mood_app/screens/activities_screen.dart'; // تأكد من استيراد ملف الأنشطة

class RecommendationsScreen extends StatelessWidget {
  final String userName;
  final String emotion;

  const RecommendationsScreen({
    Key? key,
    required this.userName,
    required this.emotion,
  }) : super(key: key);

  String _getQuote(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'sad': return 'Don\'t be sad, better days are coming!';
      case 'angry': return 'Take a deep breath and let it go.';
      case 'happy': return 'Keep shining and sharing your joy!';
      case 'fear': return 'You are stronger than you think.';
      case 'neutral': return 'A calm mind is a powerful mind.';
      default: return 'Embrace every moment and let your light radiate.';
    }
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget targetScreen,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.2),
              radius: 28, // صغرت الحجم قليلاً ليناسب الـ Grid
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Color(0xFFC04F4C), fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations', style: TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFFC04F4C),
        elevation: 0,
        centerTitle: true,
      ),
      body: BackgroundWidget(
        emotion: emotion,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                'Welcome, $userName',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC04F4C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Your Mood is: $emotion',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFC04F4C)),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _getQuote(emotion),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.95, // عدلت النسبة ليظهر الكرت بشكل متناسق
                  children: [
                    _buildCard(
                      context: context,
                      title: 'Music',
                      subtitle: 'Lift your spirits with our selection',
                      icon: Icons.music_note_rounded,
                      iconColor: Colors.teal,
                      targetScreen: PlaylistsScreen(emotion: emotion),
                    ),
                    _buildCard(
                      context: context,
                      title: 'Videos',
                      subtitle: 'Watch and get inspired!',
                      icon: Icons.play_circle_fill_rounded,
                      iconColor: Colors.orange,
                      targetScreen: VideosScreen(emotion: emotion),
                    ),
                    _buildCard(
                      context: context,
                      title: 'Stories',
                      subtitle: 'Discover powerful imagination',
                      icon: Icons.auto_stories_rounded,
                      iconColor: Colors.blueAccent,
                      targetScreen: StoriesScreen(emotion: emotion),
                    ),
                    // الكارت الرابع: الأنشطة المقترحة
                    _buildCard(
                      context: context,
                      title: 'Activities',
                      subtitle: 'Simple tasks to change your mood',
                      icon: Icons.directions_run_rounded,
                      iconColor: Colors.purple,
                      targetScreen: ActivitiesScreen(emotion: emotion),
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