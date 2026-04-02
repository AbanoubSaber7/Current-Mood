import 'package:flutter/material.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class VideosScreen extends StatelessWidget {
  final String emotion;

  const VideosScreen({Key? key, required this.emotion}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildVideoCard(String title, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: ThemeColors.redColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundColor: Colors.black87,
              radius: 30,
              child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVideosForEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'sad':
        return [
          _buildVideoCard('فيديوهات مضحكة', 'https://m.youtube.com/results?search_query=%D9%81%D9%8A%D8%AF%D9%8A%D9%88%D9%87%D8%A7%D8%AA+%D9%85%D8%B6%D8%AD%D9%83%D8%A9'),
          _buildVideoCard('Cute Baby Laughs', 'https://m.youtube.com/results?search_query=cute+baby+laughs'),
          _buildVideoCard('كوميديا مصرية', 'https://m.youtube.com/results?search_query=%D9%83%D9%88%D9%85%D9%8A%D8%AF%D9%8A%D8%A7+%D9%85%D8%B5%D8%B1%D9%8A%D8%A9'),
          _buildVideoCard('Silly Cats', 'https://m.youtube.com/results?search_query=silly+cats'),
          _buildVideoCard('أجمل المقاطع الرائجة', 'https://m.youtube.com/results?search_query=%D9%85%D9%82%D8%A7%D8%B7%D8%B9+%D8%B1%D8%A7%D8%A6%D8%AC%D8%A9'),
          _buildVideoCard('Baby Animals', 'https://m.youtube.com/results?search_query=baby+animals+compilation'),
        ];
      case 'neutral':
        return [
          _buildVideoCard('وثائقي الطبيعة', 'https://m.youtube.com/results?search_query=%D9%88%D8%AB%D8%A7%D8%A6%D9%82%D9%8A+%D8%A7%D9%84%D8%B7%D8%A8%D9%8A%D8%B9%D8%A9'),
          _buildVideoCard('Peaceful Nature Walk', 'https://m.youtube.com/results?search_query=peaceful+nature+walk'),
          _buildVideoCard('أجمل المناظر الطبيعية', 'https://m.youtube.com/results?search_query=%D9%85%D9%86%D8%A7%D8%B8%D8%B1+%D8%B7%D8%A8%D9%8A%D8%B9%D9%8A%D8%A9+%D8%AC%D9%85%D9%8A%D9%84%D8%A9'),
          _buildVideoCard('Relaxing Rain Sounds', 'https://m.youtube.com/results?search_query=relaxing+rain+sounds'),
          _buildVideoCard('قهوة الصباح', 'https://m.youtube.com/results?search_query=%D9%82%D9%87%D9%88%D8%A9+%D8%A7%D9%84%D8%B5%D8%A8%D8%A7%D8%AD'),
          _buildVideoCard('Ocean Waves', 'https://m.youtube.com/results?search_query=ocean+waves+relaxing'),
        ];
      case 'angry':
        return [
          _buildVideoCard('تمارين التنفس', 'https://m.youtube.com/results?search_query=%D8%AA%D9%85%D8%A7%D8%B1%D9%8A%D9%86+%D8%AA%D9%86%D9%81%D8%B3'),
          _buildVideoCard('Meditation for Calm', 'https://m.youtube.com/results?search_query=meditation+for+anger+calm'),
          _buildVideoCard('يوغا للمبتدئين', 'https://m.youtube.com/results?search_query=%D9%8A%D9%88%D8%BA%D8%A7+%D9%84%D9%84%D9%85%D8%A8%D8%AA%D8%AF%D8%A6%D9%8A%D9%86'),
          _buildVideoCard('Stress Relief Sounds', 'https://m.youtube.com/results?search_query=stress+relief+sounds'),
          _buildVideoCard('قصص ملهمة', 'https://m.youtube.com/results?search_query=%D9%82%D8%B5%D8%B5+%D9%85%D9%84%D9%87%D9%85%D8%A9'),
          _buildVideoCard('Calming Piano Music', 'https://m.youtube.com/results?search_query=calming+piano+music'),
        ];
      case 'happy':
      default:
        return [
          _buildVideoCard('رقصات شعبية', 'https://m.youtube.com/results?search_query=%D8%B1%D9%82%D8%B5%D8%A7%D8%AA+%D8%B4%D8%B9%D8%A8%D9%8A%D8%A9'),
          _buildVideoCard('Happy Dogs', 'https://m.youtube.com/results?search_query=happy+dogs'),
          _buildVideoCard('فرح وعيله', 'https://m.youtube.com/results?search_query=%D9%81%D9%8A%D8%AF%D9%8A%D9%88%D9%87%D8%A7%D8%AA+%D9%81%D8%B1%D8%AD'),
          _buildVideoCard('Dancing Parrot', 'https://m.youtube.com/results?search_query=dancing+parrot'),
          _buildVideoCard('أحلى لحظات', 'https://m.youtube.com/results?search_query=%D8%A3%D8%AD%D9%84%D9%89+%D9%84%D8%AD%D8%B8%D8%A7%D8%AA'),
          _buildVideoCard('Puppies Playing', 'https://m.youtube.com/results?search_query=cute+puppies+playing'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSad = emotion.toLowerCase() == 'sad';
    final bool isNeutral = emotion.toLowerCase() == 'neutral';
    final Color abColor = isSad ? Colors.white : (isNeutral ? const Color(0xFFB18F6A) : ThemeColors.redColor);
    final Color fgColor = isSad ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text('${emotion.toUpperCase()} Videos'),
        backgroundColor: abColor,
        foregroundColor: fgColor,
        elevation: 0,
      ),
      body: BackgroundWidget(
        emotion: emotion,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
            children: _buildVideosForEmotion(emotion),
          ),
        ),
      ),
    );
  }
}
