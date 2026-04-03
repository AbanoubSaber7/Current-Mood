import 'package:flutter/material.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class StoriesScreen extends StatelessWidget {
  final String emotion;

  const StoriesScreen({Key? key, required this.emotion}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildStoryCard(String title, String subtitle, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.menu_book_rounded, color: Color(0xFFC04F4C), size: 30),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStoriesForEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'sad':
        return [
          _buildStoryCard('تجاوز الأحزان والبدايات الجديدة', 'نصائح وقصص ملهمة', 'https://ar.wikipedia.org/wiki/تفاؤل'),
          _buildStoryCard('Le Petit Prince', 'Antoine de Saint-Exupéry', 'https://fr.wikipedia.org/wiki/Le_Petit_Prince'),
          _buildStoryCard('البحث عن السعادة', 'قصة قصيرة عن الأمل', 'https://ar.wikipedia.org/wiki/سعادة'),
          _buildStoryCard('The Light in the Dark', 'Short Story for Hope', 'https://americanliterature.com/short-stories'),
        ];
      case 'angry':
      case 'disgust':
        return [
          _buildStoryCard('فن الهدوء النفسي', 'كيف تتحكم في انفعالاتك', 'https://ar.wikipedia.org/wiki/ضبط_النفس'),
          _buildStoryCard('Die Verwandlung', 'Franz Kafka', 'https://de.wikipedia.org/wiki/Die_Verwandlung'),
          _buildStoryCard('قوة التسامح', 'قصة عن السلام الداخلي', 'https://ar.wikipedia.org/wiki/تسامح'),
          _buildStoryCard('The Art of Patience', 'Moral Story', 'https://americanliterature.com/short-stories'),
        ];
      case 'fear':
      case 'surprise':
        return [
          _buildStoryCard('مواجهة المجهول', 'قصة عن الشجاعة', 'https://ar.wikipedia.org/wiki/شجاعة'),
          _buildStoryCard('The Brave Little Toaster', 'Adventure Story', 'https://americanliterature.com/short-stories'),
          _buildStoryCard('رحلة إلى باطن الأرض', 'خيال ومغامرة', 'https://ar.wikipedia.org/wiki/رحلة_إلى_مركز_الأرض'),
          _buildStoryCard('Alice in Wonderland', 'Lewis Carroll', 'https://en.wikipedia.org/wiki/Alice%27s_Adventures_in_Wonderland'),
        ];
      case 'neutral':
        return [
          _buildStoryCard('حكمة الفلاح العجوز', 'دروس من الحياة', 'https://ar.wikipedia.org/wiki/حكمة'),
          _buildStoryCard('El Alquimista', 'Paulo Coelho', 'https://es.wikipedia.org/wiki/El_alquimista_(novela)'),
          _buildStoryCard('طريق النجاح الهادئ', 'تطوير الذات', 'https://ar.wikipedia.org/wiki/نجاح'),
          _buildStoryCard('Walden', 'Henry David Thoreau', 'https://en.wikipedia.org/wiki/Walden'),
        ];
      case 'happy':
      default:
        return [
          _buildStoryCard('المفاجأة السعيدة', 'قصة مبهجة للجميع', 'https://ar.wikipedia.org/wiki/فرح'),
          _buildStoryCard('The Gift of the Magi', 'O. Henry', 'https://americanliterature.com/short-stories'),
          _buildStoryCard('يوم لا يُنسى', 'مواقف مضحكة وسعيدة', 'https://ar.wikipedia.org/wiki/ضحك'),
          _buildStoryCard('A Happy Life', 'Inspirational Story', 'https://americanliterature.com/short-stories'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${emotion.toUpperCase()} STORIES'),
        backgroundColor: const Color(0xFFC04F4C),
        elevation: 0,
      ),
      body: BackgroundWidget(
        emotion: emotion,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          children: _buildStoriesForEmotion(emotion),
        ),
      ),
    );
  }
}