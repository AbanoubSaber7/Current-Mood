import 'package:flutter/material.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class VideosScreen extends StatelessWidget {
  final String emotion;

  const VideosScreen({Key? key, required this.emotion}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildVideoCard(String title, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFC04F4C),
              radius: 25,
              child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 35),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF4E342E)
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
          _buildVideoCard('مقاطع مضحكة جداً', 'https://www.youtube.com/results?search_query=funny+videos+2026'),
          _buildVideoCard('Stand-up Comedy', 'https://www.youtube.com/results?search_query=ستاند+اب+كوميدي+مصري'),
          _buildVideoCard('تحفيز للدراسة والعمل', 'https://www.youtube.com/results?search_query=motivational+videos+arabic'),
          _buildVideoCard('Cute Puppies', 'https://www.youtube.com/results?search_query=cute+puppies+compilation'),
          _buildVideoCard('ناشيونال جيوغرافيك مضحك', 'https://www.youtube.com/results?search_query=funny+animals+national+geographic'),
          _buildVideoCard('Life Hacks', 'https://www.youtube.com/results?search_query=amazing+life+hacks'),
        ];
      case 'angry':
        return [
          _buildVideoCard('تمارين تنفس عميق', 'https://www.youtube.com/results?search_query=deep+breathing+exercises'),
          _buildVideoCard('ASMR Satisfying', 'https://www.youtube.com/results?search_query=satisfying+video+asmr'),
          _buildVideoCard('موسيقى هادئة للأعصاب', 'https://www.youtube.com/results?search_query=calm+music+for+anger'),
          _buildVideoCard('Yoga for Beginners', 'https://www.youtube.com/results?search_query=yoga+for+relaxation'),
          _buildVideoCard('Nature Scenery 4K', 'https://www.youtube.com/results?search_query=nature+4k+relax'),
          _buildVideoCard('قصص تفاؤل', 'https://www.youtube.com/results?search_query=inspiring+short+stories'),
        ];
      case 'fear':
      case 'disgust':
        return [
          _buildVideoCard('كيف تتغلب على القلق', 'https://www.youtube.com/results?search_query=overcoming+anxiety+tips'),
          _buildVideoCard('Guided Meditation', 'https://www.youtube.com/results?search_query=meditation+for+fear'),
          _buildVideoCard('تحديات ممتعة', 'https://www.youtube.com/results?search_query=fun+challenges+videos'),
          _buildVideoCard('Beautiful Cities', 'https://www.youtube.com/results?search_query=beautiful+cities+walkthrough'),
          _buildVideoCard('Positive Affirmations', 'https://www.youtube.com/results?search_query=positive+affirmations+arabic'),
          _buildVideoCard('إبداع يدوي', 'https://www.youtube.com/results?search_query=creative+art+process'),
        ];
      case 'neutral':
        return [
          _buildVideoCard('وثائقي قصير', 'https://www.youtube.com/results?search_query=short+documentary+interesting'),
          _buildVideoCard('Tech Reviews', 'https://www.youtube.com/results?search_query=latest+tech+gadgets+2026'),
          _buildVideoCard('تعلم مهارة جديدة', 'https://www.youtube.com/results?search_query=learn+new+skill+in+5+minutes'),
          _buildVideoCard('Space Exploration', 'https://www.youtube.com/results?search_query=space+and+planets+discovery'),
          _buildVideoCard('بودكاست ملهم', 'https://www.youtube.com/results?search_query=inspiring+podcast+arabic'),
          _buildVideoCard('Top 10 Facts', 'https://www.youtube.com/results?search_query=top+10+interesting+facts'),
        ];
      case 'surprise':
        return [
          _buildVideoCard('خدع سحرية مذهلة', 'https://www.youtube.com/results?search_query=amazing+magic+tricks+revealed'),
          _buildVideoCard('Sci-Fi Concept Art', 'https://www.youtube.com/results?search_query=future+technology+concepts'),
          _buildVideoCard('Reaction Videos', 'https://www.youtube.com/results?search_query=funny+reaction+videos'),
          _buildVideoCard('Science Experiments', 'https://www.youtube.com/results?search_query=cool+science+experiments'),
          _buildVideoCard('أغرب أماكن في العالم', 'https://www.youtube.com/results?search_query=strangest+places+on+earth'),
          _buildVideoCard('Optical Illusions', 'https://www.youtube.com/results?search_query=best+optical+illusions'),
        ];
      case 'happy':
      default:
        return [
          _buildVideoCard('أغاني مبهجة', 'https://www.youtube.com/results?search_query=happy+upbeat+songs'),
          _buildVideoCard('Celebration Moments', 'https://www.youtube.com/results?search_query=best+celebration+moments'),
          _buildVideoCard('مقالب مضحكة', 'https://www.youtube.com/results?search_query=funny+pranks+clean'),
          _buildVideoCard('Travel Vlogs', 'https://www.youtube.com/results?search_query=fun+travel+vlogs'),
          _buildVideoCard('Kids Playing', 'https://www.youtube.com/results?search_query=kids+funny+moments'),
          _buildVideoCard('فلوجات يومية ممتعة', 'https://www.youtube.com/results?search_query=daily+vlogs+fun'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${emotion.toUpperCase()} VIDEOS'),
        backgroundColor: const Color(0xFFC04F4C),
        elevation: 0,
      ),
      body: BackgroundWidget(
        emotion: emotion,
        child: GridView.count(
          padding: const EdgeInsets.all(15),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
          physics: const BouncingScrollPhysics(),
          children: _buildVideosForEmotion(emotion),
        ),
      ),
    );
  }
}