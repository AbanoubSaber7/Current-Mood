import 'package:flutter/material.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaylistsScreen extends StatelessWidget {
  final String emotion;

  const PlaylistsScreen({Key? key, required this.emotion}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeColors.redColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSongItem(String title, String subtitle, String url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _launchUrl(url),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.redColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Open in Spotify', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlaylistForEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'sad':
        return [
          _buildSectionTitle('Arabic Playlist'),
          _buildSongItem('أنا مصمم', 'Artist: بهاء سلطان',
              'https://open.spotify.com/search/%D8%A3%D9%86%D8%A7%20%D9%85%D8%B5%D9%85%D9%85%20%D8%A8%D9%87%D8%A7%D8%A1%20%D8%B3%D9%84%D8%B7%D8%A7%D9%86'),
          _buildSongItem('كلام عينيه', 'Artist: شيرين',
              'https://open.spotify.com/search/%D9%83%D9%84%D8%A7%D9%85%20%D8%B9%D9%8A%D9%86%D9%8A%D9%87%20%D8%B4%D9%8A%D8%B1%D9%8A%D9%86'),
          _buildSectionTitle('Spanish Playlist'),
          _buildSongItem('Despacito', 'Artist: Luis Fonsi & Daddy Yankee - Album: VIDA',
              'https://open.spotify.com/search/Despacito'),
          _buildSongItem('La Bicicleta', 'Artist: Carlos Vives, Shakira',
              'https://open.spotify.com/search/La%20Bicicleta'),
          _buildSongItem('La Camisa Negra', 'Artist: Juanes',
              'https://open.spotify.com/search/La%20Camisa%20Negra'),
        ];
      case 'neutral':
        return [
          _buildSectionTitle('Arabic Playlist'),
          _buildSongItem('فيها حاجة حلوة', 'Artist: ريهام عبد الحكيم',
              'https://open.spotify.com/search/%D9%81%D9%8A%D9%87%D8%A7%20%D8%AD%D8%A7%D8%AC%D8%A9%20%D8%AD%D9%84%D9%88%D8%A9'),
          _buildSongItem('نسم علينا الهوى', 'Artist: فيروز',
              'https://open.spotify.com/search/%D9%86%D8%B3%D9%85%20%D8%B9%D9%84%D9%8A%D9%86%D8%A7%20%D8%A7%D9%84%D9%87%D9%88%D9%89%20%D9%81%D9%8A%D8%B1%D9%88%D8%B2'),
          _buildSectionTitle('French Playlist'),
          _buildSongItem('Dernière Danse', 'Artist: Indila',
              'https://open.spotify.com/search/Derniere%20Danse'),
          _buildSongItem('La Vie En Rose', 'Artist: Édith Piaf',
              'https://open.spotify.com/search/La%20Vie%20En%20Rose'),
        ];
      case 'angry':
        return [
          _buildSectionTitle('Arabic Playlist'),
          _buildSongItem('نمبر وان', 'Artist: محمد رمضان',
              'https://open.spotify.com/search/%D9%86%D9%85%D8%A8%D8%B1%20%D9%88%D8%A7%D9%86%20%D9%85%D8%AD%D9%85%D8%AF%20%D8%B1%D9%85%D8%B6%D8%A7%D9%86'),
          _buildSongItem('دورك جاي', 'Artist: ويجز',
              'https://open.spotify.com/search/%D8%AF%D9%88%D8%B1%D9%83%20%D8%AC%D8%A7%D9%8A%20%D9%88%D9%8A%D8%AC%D8%B2'),
          _buildSectionTitle('English Playlist'),
          _buildSongItem('Till I Collapse', 'Artist: Eminem',
              'https://open.spotify.com/search/Till%20I%20Collapse'),
          _buildSongItem('Bangarang', 'Artist: Skrillex',
              'https://open.spotify.com/search/Bangarang%20Skrillex'),
        ];
      case 'happy':
      default:
        return [
          _buildSectionTitle('Arabic Playlist'),
          _buildSongItem('حبيبي يا نور العين', 'Artist: عمرو دياب - Album: حبيبي يا نور العين',
              'https://open.spotify.com/search/%D8%AD%D8%A8%D9%8A%D8%A8%D9%8A%20%D9%8A%D8%A7%20%D9%86%D9%88%D8%B1%20%D8%A7%D9%84%D8%B9%D9%8A%D9%86'),
          _buildSongItem('ساموراي', 'Band: كايروكي - Album: روما',
              'https://open.spotify.com/search/Cairokee%20Samurai'),
          _buildSongItem('مسيطرة', 'Artist: لميس كان',
              'https://open.spotify.com/search/%D9%85%D8%B3%D9%8A%D8%B7%D8%B1%D8%A9'),
          _buildSectionTitle('English Playlist'),
          _buildSongItem('Happy', 'Artist: Pharrell Williams - Album: G I R L',
              'https://open.spotify.com/search/Pharrell%20Williams%20Happy'),
          _buildSongItem('Don\'t Stop Me Now', 'Artist: Queen - Album: Jazz',
              'https://open.spotify.com/search/Queen%20Dont%20Stop%20Me%20Now'),
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
        title: const Text('Playlists'),
        backgroundColor: abColor,
        foregroundColor: fgColor,
        elevation: 0,
      ),
      body: BackgroundWidget(
        emotion: emotion,
        child: ListView(
          children: [
            ..._buildPlaylistForEmotion(emotion),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
