import 'package:flutter/material.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaylistsScreen extends StatelessWidget {
  final String emotion;

  const PlaylistsScreen({Key? key, required this.emotion}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFC04F4C),
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildSongItem(String title, String subtitle, String url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFC04F4C),
          child: Icon(Icons.music_note_rounded, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.play_circle_fill, color: Color(0xFFC04F4C), size: 30),
        onTap: () => _launchUrl(url),
      ),
    );
  }

  List<Widget> _buildPlaylistForEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'sad':
        return [
          _buildSectionTitle('Arabic Classics'),
          _buildSongItem('أنا مصمم', 'بهاء سلطان', 'https://open.spotify.com/track/sad1'),
          _buildSongItem('كلام عينيه', 'شيرين', 'https://open.spotify.com/track/sad2'),
          _buildSongItem('عكس اللي شايفينها', 'إليسا', 'https://open.spotify.com/track/sad3'),
          _buildSongItem('تنسى كأنك لم تكن', 'كايروكي', 'https://open.spotify.com/track/sad4'),
          _buildSectionTitle('International Melancholy'),
          _buildSongItem('Someone Like You', 'Adele', 'https://open.spotify.com/track/sad5'),
          _buildSongItem('Fix You', 'Coldplay', 'https://open.spotify.com/track/sad6'),
          _buildSongItem('Sola', 'Jessie Reyez', 'https://open.spotify.com/track/sad7'),
          _buildSongItem('Lose You To Love Me', 'Selena Gomez', 'https://open.spotify.com/track/sad8'),
        ];
      case 'angry':
      case 'disgust':
        return [
          _buildSectionTitle('Power & Energy'),
          _buildSongItem('نمبر وان', 'محمد رمضان', 'https://open.spotify.com/track/ang1'),
          _buildSongItem('دورك جاي', 'ويجز', 'https://open.spotify.com/track/ang2'),
          _buildSongItem('باظت خالص', 'شارموفرز', 'https://open.spotify.com/track/ang3'),
          _buildSongItem('مش بالحظ', 'عفروتو', 'https://open.spotify.com/track/ang4'),
          _buildSectionTitle('Rock & Gym Vibes'),
          _buildSongItem('Till I Collapse', 'Eminem', 'https://open.spotify.com/track/ang5'),
          _buildSongItem('In the End', 'Linkin Park', 'https://open.spotify.com/track/ang6'),
          _buildSongItem('Believer', 'Imagine Dragons', 'https://open.spotify.com/track/ang7'),
          _buildSongItem('Bangarang', 'Skrillex', 'https://open.spotify.com/track/ang8'),
        ];
      case 'fear':
      case 'surprise':
        return [
          _buildSectionTitle('Calm & Serenity'),
          _buildSongItem('نسم علينا الهوى', 'فيروز', 'https://open.spotify.com/track/fear1'),
          _buildSongItem('يا غالي', 'جيتارا', 'https://open.spotify.com/track/fear2'),
          _buildSongItem('أعطني الناي', 'فيروز', 'https://open.spotify.com/track/fear3'),
          _buildSongItem('هدوء النسيم', 'موسيقى هادئة', 'https://open.spotify.com/track/fear4'),
          _buildSectionTitle('Deep Relaxation'),
          _buildSongItem('Weightless', 'Marconi Union', 'https://open.spotify.com/track/fear5'),
          _buildSongItem('River Flows in You', 'Yiruma', 'https://open.spotify.com/track/fear6'),
          _buildSongItem('Claire de Lune', 'Debussy', 'https://open.spotify.com/track/fear7'),
          _buildSongItem('Rainy Night', 'Sleep Sounds', 'https://open.spotify.com/track/fear8'),
        ];
      case 'neutral':
        return [
          _buildSectionTitle('Arabic Chill'),
          _buildSongItem('فيها حاجة حلوة', 'ريهام عبد الحكيم', 'https://open.spotify.com/track/neu1'),
          _buildSongItem('سهر الليالي', 'فيروز', 'https://open.spotify.com/track/neu2'),
          _buildSongItem('البنت القوية', 'وائل كفوري', 'https://open.spotify.com/track/neu3'),
          _buildSectionTitle('Lofi & Acoustic'),
          _buildSongItem('Dernière Danse', 'Indila', 'https://open.spotify.com/track/neu4'),
          _buildSongItem('La Vie En Rose', 'Édith Piaf', 'https://open.spotify.com/track/neu5'),
          _buildSongItem('Perfect', 'Ed Sheeran', 'https://open.spotify.com/track/neu6'),
          _buildSongItem('Lofi Girl Radio', 'Lofi Hip Hop', 'https://open.spotify.com/track/neu7'),
        ];
      case 'happy':
      default:
        return [
          _buildSectionTitle('Arabic Party'),
          _buildSongItem('نور العين', 'عمرو دياب', 'https://open.spotify.com/track/hap1'),
          _buildSongItem('ساموراي', 'كايروكي', 'https://open.spotify.com/track/hap2'),
          _buildSongItem('مسيطرة', 'لميس كان', 'https://open.spotify.com/track/hap3'),
          _buildSongItem('حتة تانية', 'روبي', 'https://open.spotify.com/track/hap4'),
          _buildSongItem('يا حبيبي', 'محمد رمضان', 'https://open.spotify.com/track/hap5'),
          _buildSectionTitle('Global Hits'),
          _buildSongItem('Happy', 'Pharrell Williams', 'https://open.spotify.com/track/hap6'),
          _buildSongItem('Don\'t Stop Me Now', 'Queen', 'https://open.spotify.com/track/hap7'),
          _buildSongItem('Can\'t Stop the Feeling', 'Justin Timberlake', 'https://open.spotify.com/track/hap8'),
          _buildSongItem('Uptown Funk', 'Bruno Mars', 'https://open.spotify.com/track/hap9'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${emotion.toUpperCase()} PLAYLIST'),
        backgroundColor: const Color(0xFFC04F4C),
        elevation: 0,
        centerTitle: true,
      ),
      body: BackgroundWidget(
        emotion: emotion,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            ..._buildPlaylistForEmotion(emotion),
          ],
        ),
      ),
    );
  }
}