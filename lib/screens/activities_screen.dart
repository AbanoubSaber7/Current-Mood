import 'package:flutter/material.dart';
import '../widgets/background_widget.dart'; // ده المسار لملف الخلفية اللي أنت فاتحه في الصورة

class ActivitiesScreen extends StatelessWidget {
  final String emotion;
  const ActivitiesScreen({Key? key, required this.emotion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الأنشطة بناءً على المود
    Map<String, List<String>> activities = {
      'happy': ['شارك فرحتك مع صديق', 'سجل لحظتك السعيدة بصورة', 'اخرج للتمشية'],
      'sad': ['اكتب 3 أشياء أنت ممتن لها', 'استمع لموسيقى هادئة', 'تحدث مع شخص تثق به'],
      'angry': ['تمارين تنفس (شهيق وزفير)', 'مارس بعض التمارين الرياضية', 'عد من 1 لـ 100'],
      'fear': ['قاعدة 5-4-3-2-1 للتركيز', 'استمع لأصوات طبيعية', 'ذكر نفسك أنك في أمان'],
      'neutral': ['خطط لمهامك القادمة', 'اقرأ مقالاً ممتعاً', 'رتب غرفتك أو مكتبك'],
    };

    List<String> currentActivities = activities[emotion.toLowerCase()] ?? ['استرخِ قليلاً'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BackgroundWidget(
        emotion: emotion,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "بما أنك تشعر بـ $emotion",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ...currentActivities.map((activity) => Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.white.withOpacity(0.2),
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.white),
                  title: Text(activity, style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}