import 'package:flutter/material.dart';

class ThemeColors {
  static const Color accentColor = Color(0xFFA57D7A); // Used for blobs and buttons
  static const Color darkTextColor = Color(0xFF6B4542);
  static const Color redColor = Color(0xFFB14844); // Predict emotion button
  static const Color cardColor = Color(0xFFF2DDD6); // Used for cards
  static const Color gradientStart = Color(0xFFC04F4C);
  static const Color gradientEnd = Color(0xFF5F2753);
}

class BackgroundTheme {
  final Color bgColor;
  final Color blobColor;

  BackgroundTheme(this.bgColor, this.blobColor);
}

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final String emotion;

  const BackgroundWidget({Key? key, required this.child, this.emotion = 'happy'}) : super(key: key);

  BackgroundTheme _getTheme() {
    switch (emotion.toLowerCase()) {
      case 'sad':
        return BackgroundTheme(Colors.black, Colors.grey.withValues(alpha: 0.3));
      case 'neutral':
        return BackgroundTheme(const Color(0xFFD0AE8F), const Color(0xFFB18F6A));
      case 'angry':
        return BackgroundTheme(const Color(0xFFF0DFD1), const Color(0xFFD5B495));

    // --- الإضافات الجديدة هنا ---
      case 'fear':
      // ألوان توحي بالخوف (بنفسجي غامق مع دوائر أغمق)
        return BackgroundTheme(const Color(0xFF2C1A35), const Color(0xFF4A2B5A));
      case 'disgust':
      // ألوان توحي بالاشمئزاز (درجات الأخضر الزيتوني)
        return BackgroundTheme(const Color(0xFF4A5D23), const Color(0xFF6B8E23));
      case 'surprise':
      // ألوان توحي بالمفاجأة (درجات البرتقالي أو الوردي الساطع)
        return BackgroundTheme(const Color(0xFFFFF4E1), const Color(0xFFFFCC80));
    // --------------------------

      case 'happy':
      default:
        return BackgroundTheme(Colors.white, ThemeColors.accentColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme();
    // استخدمت AnimatedContainer عشان الألوان تتغير بنعومة لما تختار من القائمة
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: theme.bgColor,
      child: Stack(
        children: [
          // Top Left Blob
          Positioned(
            top: -50,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: theme.blobColor.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -20,
            left: -60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.blobColor.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Top Right Blob
          Positioned(
            top: -40,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.blobColor.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: -40,
            child: Container(
              width: 80,
              height: 150,
              decoration: BoxDecoration(
                color: theme.blobColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          // Bottom Left Blob
          Positioned(
            bottom: -60,
            left: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: theme.blobColor.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom Right Blob
          Positioned(
            bottom: -50,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: theme.blobColor.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main Content
          SafeArea(child: child),
        ],
      ),
    );
  }
}