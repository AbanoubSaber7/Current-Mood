import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
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
  /// ثقة التنبؤ 0–100 بعد softmax (أو توزيع احتمالات من الموديل).
  double? predictedConfidencePercent;
  String? manualSelectedEmotion;
  bool isLoading = false;
  bool isImage = false;

  final ImagePicker _picker = ImagePicker();
  Interpreter? _interpreter;
  FaceDetector? _faceDetector;

  /// يُحدَّد بعد التحميل من شكل مخرجات الـ TFLite (FER+ = 8 فئات).
  int _numClasses = 8;
  int _inputChannels = 1;

  /// ترتيب vicksam / FER-Plus (dataset.py COLUMN_NAMES بعد fer_code).
  static const List<String> _emotionLabels = [
    'Neutral',
    'Happy',
    'Surprise',
    'Sad',
    'Angry',
    'Disgust',
    'Fear',
    'Contempt',
  ];

  static bool get _canUseMlKitFace =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    if (_canUseMlKitFace) {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          enableContours: false,
          enableLandmarks: false,
          enableClassification: false,
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

  void _applyModelIOShapes() {
    if (_interpreter == null) return;
    final inShape = _interpreter!.getInputTensor(0).shape;
    final outShape = _interpreter!.getOutputTensor(0).shape;
    if (inShape.length == 4) {
      if (inShape[1] == 48 && inShape[2] == 48) {
        _inputChannels = inShape[3];
      } else if (inShape[2] == 48 && inShape[3] == 48) {
        _inputChannels = inShape[1];
      } else {
        _inputChannels = inShape[3];
      }
    }
    if (outShape.length >= 2) {
      _numClasses = outShape[1];
    } else if (outShape.length == 1) {
      _numClasses = outShape[0];
    }
  }

  Future<void> loadModel() async {
    _interpreter?.close();
    _interpreter = null;
    _numClasses = 8;
    _inputChannels = 1;

    const assetPath = 'assets/model/ferplus_model_pd_best.tflite';
    try {
      _interpreter = await Interpreter.fromAsset(assetPath);
      _applyModelIOShapes();
      debugPrint('TFLite OK: $assetPath  classes=$_numClasses  ch=$_inputChannels');
    } catch (e) {
      debugPrint('Error loading TFLite: $e');
      _interpreter?.close();
      _interpreter = null;
    }
    if (mounted) setState(() {});
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
        predictedConfidencePercent = null;
      });
    }
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

  /// يدعم موديلات تخرج logits أو احتمالات (softmax).
  List<double> _rawScoresToProbabilities(List<double> raw) {
    if (raw.isEmpty) return raw;
    final sum = raw.fold<double>(0, (a, b) => a + b);
    final allNonNeg = raw.every((v) => v >= -1e-6);
    final looksProb =
        allNonNeg && sum > 0.9 && sum < 1.1 && raw.every((v) => v <= 1.0 + 1e-6);
    if (looksProb) {
      final s = sum <= 0 ? 1.0 : sum;
      return raw.map((v) => (v / s).clamp(0.0, 1.0)).toList();
    }
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

  /// قص منطقة الوجه مع هامش بسيط؛ يطابق تدريب FER عادةً (وجه فقط وليس الإطار كامل).
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
    final x = left.floor();
    final y = top.floor();
    var w = (right - left).ceil();
    var h = (bottom - top).ceil();
    w = w.clamp(1, image.width - x);
    h = h.clamp(1, image.height - y);
    return img.copyCrop(image, x: x, y: y, width: w, height: h);
  }

  /// بدون كشف وجه: مربع من المنتصف ثم تصغير — أوضح من ضغط الصورة كاملة (تشويه).
  img.Image _centerSquareCrop(img.Image image) {
    final w = image.width;
    final h = image.height;
    if (w <= 0 || h <= 0) return image;
    final side = w < h ? w : h;
    final x = (w - side) ~/ 2;
    final y = (h - side) ~/ 2;
    return img.copyCrop(image, x: x, y: y, width: side, height: side);
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
        debugPrint('Face detection skipped: $e');
        region = _centerSquareCrop(image);
      }
    } else {
      region = _centerSquareCrop(image);
    }

    img.Image resized = img.copyResize(region, width: 48, height: 48);

    if (_inputChannels == 1) {
      var input = List.generate(1, (i) =>
          List.generate(48, (j) =>
              List.generate(48, (k) => List.filled(1, 0.0))
          )
      );
      for (int y = 0; y < 48; y++) {
        for (int x = 0; x < 48; x++) {
          final pixel = resized.getPixel(x, y);
          final gray =
              (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;
          input[0][y][x][0] = gray;
        }
      }
      return input;
    }

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

  // --- التعديل في عملية التنبؤ ---
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

      final raw = List<double>.generate(
        _numClasses,
        (i) => (output[0][i] as num).toDouble(),
      );
      final probs = _rawScoresToProbabilities(raw);
      int index = 0;
      double bestP = probs[0];
      for (int i = 1; i < _numClasses; i++) {
        if (probs[i] > bestP) {
          bestP = probs[i];
          index = i;
        }
      }

      final confidencePct = (bestP * 100).clamp(0.0, 100.0);
      if (index >= _emotionLabels.length) {
        setState(() => isLoading = false);
        return;
      }
      String result = _emotionLabels[index];

      setState(() {
        predictedEmotion = result;
        predictedConfidencePercent = confidencePct;
        isLoading = false;
      });

      // تأخير بسيط لعرض النتيجة ثم الانتقال
      await Future.delayed(const Duration(milliseconds: 1700));

      if (mounted) {
        _navigateToRecommendations(
          result,
          confidencePercent: confidencePct,
          source: 'model',
        );
      }
    } catch (e) {
      debugPrint("Prediction Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleNavigation() async {
    if (manualSelectedEmotion != null && _pickedFile == null) {
      _navigateToRecommendations(
        manualSelectedEmotion!,
        confidencePercent: null,
        source: 'manual',
      );
      return;
    }
    if (_pickedFile != null && isImage) {
      await _predictFromModel();
    } else if (_pickedFile != null && !isImage) {
      _navigateToRecommendations(
        "Neutral",
        confidencePercent: null,
        source: 'fallback',
      );
    }
  }

  void _navigateToRecommendations(
    String finalEmotion, {
    double? confidencePercent,
    String source = 'model',
  }) {
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

  // دوال الـ UI والمظهر
  Future<void> _pickVideo(ImageSource source) async {
    final XFile? video = await _picker.pickVideo(source: source);
    if (video != null) {
      setState(() {
        _pickedFile = File(video.path);
        _pickedFileName = video.name;
        isImage = false;
        manualSelectedEmotion = null;
        predictedEmotion = null;
        predictedConfidencePercent = null;
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
        predictedConfidencePercent = null;
      });
    }
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
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
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
                        items: _emotionLabels.map((value) {
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
                            predictedConfidencePercent = null;
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
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Your Mood: $predictedEmotion',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC05A4E)),
                          ),
                          if (predictedConfidencePercent != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Confidence: ${predictedConfidencePercent!.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.brown.shade700,
                              ),
                            ),
                          ],
                        ],
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