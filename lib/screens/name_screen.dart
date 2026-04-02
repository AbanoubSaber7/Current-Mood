import 'package:flutter/material.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:mood_app/screens/detection_screen.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({Key? key}) : super(key: key);

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Enter Your Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 12.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Go Back'),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        final name = _nameController.text.trim();

                        // ✅ التحقق
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter your name"),
                            ),
                          );
                          return;
                        }

                        // ✅ الانتقال
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetectionScreen(userName: name),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.accentColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 12.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}