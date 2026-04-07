import 'package:flutter/material.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:mood_app/screens/playlists_screen.dart';
import 'package:mood_app/screens/videos_screen.dart';
import 'package:mood_app/screens/stories_screen.dart';
import 'package:mood_app/screens/activities_screen.dart'; // تأكد من استيراد ملف الأنشطة
import 'package:mood_app/models/mood_history_entry.dart';
import 'package:mood_app/services/mood_history_service.dart';

class RecommendationsScreen extends StatefulWidget {
  final String userName;
  final String emotion;
  final double? confidencePercent;
  final String source; // "model" | "manual" | "fallback"

  const RecommendationsScreen({
    Key? key,
    required this.userName,
    required this.emotion,
    this.confidencePercent,
    this.source = 'model',
‍  }) : super(key: key);

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  static const double _lowConfidenceThreshold = 40.0;
  static const List<String> _emotionLabels = [
    'Neutral',
    'Happy',
    'Surprise',
    'Sad',
    'Angry',
    'Disgust',
    'Fear',
    'Contempt',
  ];

  final _history = MoodHistoryService();

  late String _selectedEmotion;
  late bool _confirmed;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _selectedEmotion = widget.emotion;
    final conf = widget.confidencePercent;
    _confirmed = conf == null || conf >= _lowConfidenceThreshold || widget.source != 'model';
    if (_confirmed) {
      _saveHistoryIfNeeded(
        finalEmotion: _selectedEmotion,
        predictedEmotion: widget.source == 'model' ? widget.emotion : null,
      );
    }
  }

  Future<void> _saveHistoryIfNeeded({
    required String finalEmotion,
    String? predictedEmotion,
  }) async {
    if (_saved) return;
    _saved = true;
    await _history.addEntry(
      MoodHistoryEntry(
        emotion: finalEmotion,
        confidencePercent: widget.confidencePercent,
        timestamp: DateTime.now(),
        source: widget.source,
        predictedEmotion: predictedEmotion,
      ),
      maxEntries: 20,
    );
  }

  String _getQuote(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'sad': return 'Don\'t be sad, better days are coming!';
      case 'angry': return 'Take a deep breath and let it go.';
      case 'happy': return 'Keep shining and sharing your joy!';
      case 'fear': return 'You are stronger than you think.';
      case 'neutral': return 'A calm mind is a powerful mind.';
      case 'disgust':
      case 'contempt': return 'It is okay to step back and reset your space.';
      case 'surprise': return 'New moments can bring fresh energy—ride the wave.';
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
    final conf = widget.confidencePercent;
    final confText = conf == null ? null : '${conf.toStringAsFixed(1)}%';
    final showConfirm = widget.source == 'model' && conf != null && conf < _lowConfidenceThreshold && !_confirmed;

    final effectiveEmotion = _confirmed ? _selectedEmotion : 'Neutral';
    final headerEmotion = _confirmed ? _selectedEmotion : '${widget.emotion} (unconfirmed)';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations', style: TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFFC04F4C),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => Navigator.pushNamed(context, '/history'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: BackgroundWidget(
        emotion: effectiveEmotion,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                'Welcome, ${widget.userName}',
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
                  'Your Mood is: $headerEmotion',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFC04F4C)),
                ),
              ),
              if (confText != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Confidence: $confText',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _getQuote(effectiveEmotion),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              ),
              if (showConfirm) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'We are not fully sure about your mood.',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Confirm or correct it to get more accurate recommendations. Until then, you will see general suggestions.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedEmotion,
                        items: _emotionLabels
                            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                            .toList(),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _selectedEmotion = v);
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC04F4C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          setState(() => _confirmed = true);
                          await _saveHistoryIfNeeded(
                            finalEmotion: _selectedEmotion,
                            predictedEmotion: widget.emotion,
                          );
                          if (mounted) setState(() {});
                        },
                        child: const Text('Confirm mood', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
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
                      targetScreen: PlaylistsScreen(emotion: effectiveEmotion),
                    ),
                    _buildCard(
                      context: context,
                      title: 'Videos',
                      subtitle: 'Watch and get inspired!',
                      icon: Icons.play_circle_fill_rounded,
                      iconColor: Colors.orange,
                      targetScreen: VideosScreen(emotion: effectiveEmotion),
                    ),
                    _buildCard(
                      context: context,
                      title: 'Stories',
                      subtitle: 'Discover powerful imagination',
                      icon: Icons.auto_stories_rounded,
                      iconColor: Colors.blueAccent,
                      targetScreen: StoriesScreen(emotion: effectiveEmotion),
                    ),
                    // الكارت الرابع: الأنشطة المقترحة
                    _buildCard(
                      context: context,
                      title: 'Activities',
                      subtitle: 'Simple tasks to change your mood',
                      icon: Icons.directions_run_rounded,
                      iconColor: Colors.purple,
                      targetScreen: ActivitiesScreen(emotion: effectiveEmotion),
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