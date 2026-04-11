import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
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
  double? predictedConfidencePercent;
  String? manualSelectedEmotion;
  bool isLoading = false;
  bool isImage = false;

  final ImagePicker _picker = ImagePicker();
  Interpreter? _interpreter;
  FaceDetector? _faceDetector;

  int _numClasses = 8;
  int _inputChannels = 1;

  static const List<String> _emotionLabels = [
    'Neutral', 'Happy', 'Surprise', 'Sad', 'Angry', 'Disgust', 'Fear', 'Contempt',
  ];

  static bool get _canUseMlKitFace =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    if (_canUseMlKitFace) {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          minFaceSize: 0.12,
        ),
      );
    }
    loadModel();
  }

  @override
  void dispose() {
    _faceDetector?.close();
    _interpreter?.close();
    super.dispose();
  }

  Future<void> loadModel() async {
    const assetPath = 'assets/model/ferplus_model_pd_best.tflite';
    try {
      _interpreter = await Interpreter.fromAsset(assetPath);
      _applyModelIOShapes();
    } catch (e) {
      debugPrint('Error loading TFLite: $e');
    }
    if (mounted) setState(() {});
  }

  void _applyModelIOShapes() {
    if (_interpreter == null) return;
    final inShape = _interpreter!.getInputTensor(0).shape;
    final outShape = _interpreter!.getOutputTensor(0).shape;
    _inputChannels = inShape.last;
    if (outShape.length >= 2) _numClasses = outShape[1];
  }

  Future<void> _predictFromModel() async {
    if (_interpreter == null || _pickedFile == null) return;
    setState(() => isLoading = true);

    try {
      var input = await preprocessImage(_pickedFile!);
      if (input.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      var output = List.filled(1 * _numClasses, 0.0).reshape([1, _numClasses]);
      _interpreter!.run(input, output);

      final raw = List<double>.generate(_numClasses, (i) => (output[0][i] as num).toDouble());
      final probs = _rawScoresToProbabilities(raw);

      int index = 0;
      double bestP = probs[0];
      for (int i = 1; i < _numClasses; i++) {
        if (probs[i] > bestP) {
          bestP = probs[i];
          index = i;
        }
      }

      String result = _emotionLabels[index];
      final confidencePct = (bestP * 100).clamp(0.0, 100.0);

      await _uploadImageAndSaveRecord(result, confidencePct);

      setState(() {
        predictedEmotion = result;
        predictedConfidencePercent = confidencePct;
        isLoading = false;
      });

      await Future.delayed(const Duration(milliseconds: 1700));
      if (mounted) {
        _navigateToRecommendations(result, confidencePercent: confidencePct, source: 'model');
      }
    } catch (e) {
      debugPrint("Prediction Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _uploadImageAndSaveRecord(String emotion, double confidence) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || _pickedFile == null) return;

    try {
      String fileName = 'history/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      await storageRef.putFile(_pickedFile!);
      String downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('mood_history')
          .add({
        'emotion': emotion,
        'confidence': confidence,
        'image_url': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Upload failed: $e");
    }
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
        predictedConfidencePercent = null;
      });
    }
  }

  Future<void> _handleNavigation() async {
    if (manualSelectedEmotion != null && _pickedFile == null) {
      _navigateToRecommendations(manualSelectedEmotion!, source: 'manual');
      return;
    }
    if (_pickedFile != null && isImage) {
      await _predictFromModel();
    }
  }

  void _navigateToRecommendations(String finalEmotion, {double? confidencePercent, String source = 'model'}) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendationsScreen(
          userName: widget.userName,
          emotion: finalEmotion,
          confidencePercent: confidencePercent,
          source: source,
        ),
      ),
    );
  }

  Future<void> handleLogout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return [];
    final m = logits.reduce(math.max);
    var sum = 0.0;
    final exps = <double>[];
    for (final x in logits) {
      final e = math.exp(x - m);
      exps.add(e);
      sum += e;
    }
    if (sum <= 0) return List.filled(logits.length, 1.0 / logits.length);
    return exps.map((e) => e / sum).toList();
  }

  List<double> _rawScoresToProbabilities(List<double> raw) {
    if (raw.isEmpty) return raw;
    final sum = raw.fold<double>(0, (a, b) => a + b);
    final allNonNeg = raw.every((v) => v >= -1e-6);
    final looksProb = allNonNeg && sum > 0.9 && sum < 1.1;
    if (looksProb) return raw.map((v) => v.clamp(0.0, 1.0)).toList();
    return _softmax(raw);
  }

  Face _largestFace(List<Face> faces) {
    Face best = faces.first;
    double bestArea = best.boundingBox.width * best.boundingBox.height;
    for (final f in faces.skip(1)) {
      final a = f.boundingBox.width * f.boundingBox.height;
      if (a > bestArea) {
        best = f;
        bestArea = a;
      }
    }
    return best;
  }

  img.Image _cropFaceRegion(img.Image image, Face face, {double padFraction = 0.22}) {
    final box = face.boundingBox;
    final iw = image.width.toDouble();
    final ih = image.height.toDouble();
    double left = box.left - box.width * padFraction;
    double top = box.top - box.height * padFraction;
    double right = box.right + box.width * padFraction;
    double bottom = box.bottom + box.height * padFraction;
    left = left.clamp(0.0, iw - 1);
    top = top.clamp(0.0, ih - 1);
    right = right.clamp(left + 1, iw);
    bottom = bottom.clamp(top + 1, ih);
    return img.copyCrop(image, x: left.floor(), y: top.floor(), width: (right - left).ceil().clamp(1, image.width), height: (bottom - top).ceil().clamp(1, image.height));
  }

  img.Image _centerSquareCrop(img.Image image) {
    final side = image.width < image.height ? image.width : image.height;
    return img.copyCrop(image, x: (image.width - side) ~/ 2, y: (image.height - side) ~/ 2, width: side, height: side);
  }

  Future<List<dynamic>> preprocessImage(File file) async {
    Uint8List bytes = file.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return [];
    img.Image region = image;
    if (_faceDetector != null) {
      try {
        final inputImage = InputImage.fromFilePath(file.path);
        final faces = await _faceDetector!.processImage(inputImage);
        if (faces.isNotEmpty) {
          region = _cropFaceRegion(image, _largestFace(faces));
        } else {
          region = _centerSquareCrop(image);
        }
      } catch (e) {
        region = _centerSquareCrop(image);
      }
    } else {
      region = _centerSquareCrop(image);
    }
    img.Image resized = img.copyResize(region, width: 48, height: 48);
    var input = List.generate(1, (i) => List.generate(48, (j) => List.generate(48, (k) => List.filled(_inputChannels, 0.0))));
    for (int y = 0; y < 48; y++) {
      for (int x = 0; x < 48; x++) {
        final pixel = resized.getPixel(x, y);
        if (_inputChannels == 1) {
          input[0][y][x][0] = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;
        } else {
          input[0][y][x][0] = pixel.r / 255.0;
          input[0][y][x][1] = pixel.g / 255.0;
          input[0][y][x][2] = pixel.b / 255.0;
        }
      }
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Detection", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFFC05A4E),
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: handleLogout)],
      ),
      body: BackgroundWidget(
        emotion: predictedEmotion ?? manualSelectedEmotion ?? 'Neutral',
        child: SizedBox.expand(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text('Welcome, ${widget.userName}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8B4513))),
                  const SizedBox(height: 25),
                  _buildImagePreview(),
                  const SizedBox(height: 25),
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                  _buildManualDropdown(),
                  const SizedBox(height: 35),
                  _buildPredictButton(),
                  const SizedBox(height: 20),
                  if (predictedEmotion != null) _buildResultCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: 250, height: 250,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.5)), color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: _pickedFile != null
            ? ClipRRect(borderRadius: BorderRadius.circular(20), child: isImage ? Image.file(_pickedFile!, fit: BoxFit.cover, width: 250, height: 250) : const Icon(Icons.insert_drive_file, size: 50))
            : const Text("No Item Selected"),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
      children: [
        _buildButton('Upload Picture', Icons.photo_library, () => _pickImage(ImageSource.gallery)),
        _buildButton('Take Picture', Icons.camera_alt, () => _pickImage(ImageSource.camera)),
      ],
    );
  }

  Widget _buildManualDropdown() {
    return Container(
      width: 220, padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: manualSelectedEmotion, hint: const Text("Select Mood Manually"), isExpanded: true,
          items: _emotionLabels.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() { manualSelectedEmotion = v; _pickedFile = null; predictedEmotion = null; }),
        ),
      ),
    );
  }

  Widget _buildPredictButton() {
    return SizedBox(
      width: 220, height: 50,
      child: ElevatedButton(
        onPressed: (_pickedFile != null || manualSelectedEmotion != null) && !isLoading ? _handleNavigation : null,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC05A4E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_pickedFile != null ? 'Predict My Mood' : 'Next Step'),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(children: [
        Text('Your Mood: $predictedEmotion', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC05A4E))),
        Text('Confidence: ${predictedConfidencePercent!.toStringAsFixed(1)}%'),
      ]),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(onPressed: onPressed, icon: Icon(icon, size: 14), label: Text(text, style: const TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB08981)));
  }
}