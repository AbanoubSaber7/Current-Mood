import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_app/widgets/background_widget.dart';
import 'package:mood_app/screens/recommendations_screen.dart';

class DetectionScreen extends StatefulWidget {
  final String userName;
  const DetectionScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  File? _pickedFile;
  String? _pickedFileName;
  String? predictedEmotion;
  String? manualSelectedEmotion;
  bool isLoading = false;
  bool isImage = false;

  final ImagePicker _picker = ImagePicker();
  Interpreter? _interpreter;

  final List<String> emotions = [
    'Angry',
    'Disgust',
    'Fear',
    'Happy',
    'Neutral',
    'Sad',
    'Surprise'
  ];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/Face_model122.tflite');
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _pickedFile = File(image.path);
        _pickedFileName = image.name;
        isImage = true;
        manualSelectedEmotion = null;
        predictedEmotion = null;
      });
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final XFile? video = await _picker.pickVideo(source: source);
    if (video != null) {
      setState(() {
        _pickedFile = File(video.path);
        _pickedFileName = video.name;
        isImage = false;
        manualSelectedEmotion = null;
        predictedEmotion = null;
      });
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _pickedFileName = result.files.single.name;
        isImage = false;
        manualSelectedEmotion = null;
        predictedEmotion = null;
      });
    }
  }

  List<dynamic> preprocessImage(File file) {
    Uint8List bytes = file.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return [];

    img.Image resized = img.copyResize(image, width: 48, height: 48);
    var input = List.generate(1, (i) =>
        List.generate(48, (j) =>
            List.generate(48, (k) => List.filled(3, 0.0))
        )
    );

    for (int y = 0; y < 48; y++) {
      for (int x = 0; x < 48; x++) {
        var pixel = resized.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }
    return input;
  }

  Future<void> _predictFromModel() async {
    if (_interpreter == null) return;
    setState(() => isLoading = true);

    try {
      var input = preprocessImage(_pickedFile!);
      var output = List.filled(1 * 7, 0.0).reshape([1, 7]);

      _interpreter!.run(input, output);

      int index = 0;
      double maxVal = output[0][0];
      for (int i = 1; i < 7; i++) {
        if (output[0][i] > maxVal) {
          maxVal = output[0][i];
          index = i;
        }
      }

      String result = emotions[index];

      setState(() {
        predictedEmotion = result;
        isLoading = false;
      });

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        _navigateToRecommendations(result);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleNavigation() async {
    if (manualSelectedEmotion != null && _pickedFile == null) {
      _navigateToRecommendations(manualSelectedEmotion!);
      return;
    }
    if (_pickedFile != null && isImage) {
      await _predictFromModel();
    } else if (_pickedFile != null && !isImage) {
      _navigateToRecommendations("Neutral");
    }
  }

  void _navigateToRecommendations(String finalEmotion) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendationsScreen(
          userName: widget.userName,
          emotion: finalEmotion,
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(text, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB08981),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Detection", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFFC05A4E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: handleLogout,
          )
        ],
      ),
      body: BackgroundWidget(
        emotion: predictedEmotion ?? manualSelectedEmotion ?? 'Neutral',
        child: SizedBox.expand(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Welcome, ${widget.userName}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: _pickedFile != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: isImage
                            ? Image.file(_pickedFile!, fit: BoxFit.cover, width: 250, height: 250)
                            : const Icon(Icons.insert_drive_file, size: 50, color: Colors.brown),
                      )
                          : const Text("No Item Selected", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildButton('Upload Picture', Icons.photo_library, () => _pickImage(ImageSource.gallery)),
                      _buildButton('Take Picture', Icons.camera_alt, () => _pickImage(ImageSource.camera)),
                      _buildButton('Upload Record', Icons.audiotrack, _pickAudio),
                      _buildButton('Upload Video', Icons.video_library, () => _pickVideo(ImageSource.gallery)),
                      _buildButton('Take Video', Icons.videocam, () => _pickVideo(ImageSource.camera)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Or tell us how you feel directly:",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8B4513)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFB08981).withOpacity(0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: manualSelectedEmotion,
                        hint: const Text("Select Mood Manually"),
                        isExpanded: true,
                        items: emotions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: Colors.brown)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            manualSelectedEmotion = newValue;
                            _pickedFile = null;
                            predictedEmotion = null;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: 220,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_pickedFile != null || manualSelectedEmotion != null) && !isLoading
                          ? _handleNavigation
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC05A4E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 4,
                      ),
                      child: isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                        _pickedFile != null ? 'Predict My Mood' : 'Next Step',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (predictedEmotion != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Text(
                        'Your Mood: $predictedEmotion',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC05A4E)),
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}