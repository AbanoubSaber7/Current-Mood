import 'package:flutter/material.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class StoriesScreen extends StatelessWidget {
  final String emotion;

  const StoriesScreen({Key? key, required this.emotion}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildStoryCard(String title, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        width: double.infinity,
        padding: const EdgeInsets.all(15.0),
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          color: ThemeColors.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStoriesForEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'sad': // Arabic + French
        return [
          _buildStoryCard('تجاوز الأحزان', 'https://ar.wikipedia.org/wiki/%D9%82%D8%B5%D8%A9_%D9%82%D8%B5%D9%8A%D8%B1%D8%A9'),
          _buildStoryCard('Le Petit Prince (La Planète)', 'https://fr.wikipedia.org/wiki/Le_Petit_Prince'),
          _buildStoryCard('قصة الأمل المفقود', 'https://ar.wikipedia.org/wiki/%D9%82%D8%B5%D8%A9_%D9%82%D8%B5%D9%8A%D8%B1%D8%A9'),
          _buildStoryCard('Les Misérables (Résumé)', 'https://fr.wikipedia.org/wiki/Les_Mis%C3%A9rables'),
        ];
      case 'neutral': // Arabic + Spanish
        return [
          _buildStoryCard('حكمة الفلاح العجوز', 'https://ar.wikipedia.org/wiki/%D9%82%D8%B5%D8%A9_%D9%82%D8%B5%D9%8A%D8%B1%D8%A9'),
          _buildStoryCard('El Alquimista (Resumen)', 'https://es.wikipedia.org/wiki/El_alquimista_(novela)'),
          _buildStoryCard('طريق السلام الداخلي', 'https://ar.wikipedia.org/wiki/%D9%82%D8%B5%D8%A9_%D9%82%D8%B5%D9%8A%D8%B1%D8%A9'),
          _buildStoryCard('Cien Años de Soledad', 'https://es.wikipedia.org/wiki/Cien_a%C3%B1os_de_soledad'),
        ];
      case 'angry': // Arabic + German
        return [
          _buildStoryCard('قوة التسامح', 'https://ar.wikipedia.org/wiki/%D9%82%D8%B5%D8%A9_%D9%82%D8%B5%D9%8A%D8%B1%D8%A9'),
          _buildStoryCard('Die Verwandlung (Kafka)', 'https://de.wikipedia.org/wiki/Die_Verwandlung'),
          _buildStoryCard('رسالة غضب ومحبة', 'https://ar.wikipedia.org/wiki/%D9%82%D8%B5%D8%A9_%D9%82%D8%B5%D9%8A%D8%B1%D8%A9'),
          _buildStoryCard('Der Steppenwolf (Hesse)', 'https://de.wikipedia.org/wiki/Der_Steppenwolf'),
        ];
      case 'happy': // Arabic + English
      default:
        return [
          _buildStoryCard('المفاجأة السعيدة', 'https://ar.wikipedia.org/wiki/%D9%82%D8%B5%D8%A9_%D9%82%D8%B5%D9%8A%D8%B1%D8%A9'),
          _buildStoryCard('The Generous Teacher', 'https://americanliterature.com/short-stories'),
          _buildStoryCard('يوم في الملاهي', 'https://ar.wikipedia.org/wiki/%D9%82%D8%B5%D8%A9_%D9%82%D8%B5%D9%8A%D8%B1%D8%A9'),
          _buildStoryCard('The Successful Journey', 'https://americanliterature.com/short-stories'),
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
        title: const Text('Stories'),
        backgroundColor: abColor,
        foregroundColor: fgColor,
        elevation: 0,
      ),
      body: BackgroundWidget(
        emotion: emotion,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: _buildStoriesForEmotion(emotion),
          ),
        ),
      ),
    );
  }
}
