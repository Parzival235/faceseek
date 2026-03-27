import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Detection results from an image
class FaceDetectionResult {
  final List<DetectedFace> faces;
  final Size imageSize;

  const FaceDetectionResult({
    required this.faces,
    required this.imageSize,
  });

  bool get hasFaces => faces.isNotEmpty;
  int get faceCount => faces.length;

  /// The face is the clearest (largest area).
  DetectedFace? get primaryFace => faces.isEmpty
      ? null
      : faces.reduce((a, b) => a.area > b.area ? a : b);
}

class DetectedFace {
  final Rect boundingBox;
  final double? headEulerAngleY; // left/right tilt
  final double? headEulerAngleZ; // rotation
  final double? smilingProbability;
  final double? leftEyeOpenProbability;
  final double? rightEyeOpenProbability;

  const DetectedFace({
    required this.boundingBox,
    this.headEulerAngleY,
    this.headEulerAngleZ,
    this.smilingProbability,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
  });

  double get area => boundingBox.width * boundingBox.height;

  /// Face quality for search (0.0 - 1.0)
  double get qualityScore {
    double score = 1.0;

    // Penalize if your face is tilted too much.
    if (headEulerAngleY != null && headEulerAngleY!.abs() > 30) {
      score -= 0.3;
    }
    if (headEulerAngleZ != null && headEulerAngleZ!.abs() > 20) {
      score -= 0.2;
    }

    // PenalizePenalize if you close your eyes.
    final leftOpen = leftEyeOpenProbability ?? 1.0;
    final rightOpen = rightEyeOpenProbability ?? 1.0;
    if (leftOpen < 0.5 || rightOpen < 0.5) score -= 0.2;

    return score.clamp(0.0, 1.0);
  }

  String get qualityLabel {
    final s = qualityScore;
    if (s >= 0.8) return 'Excellent';
    if (s >= 0.6) return 'Good';
    if (s >= 0.4) return 'Fair';
    return 'Poor';
  }
}

class FaceDetectorService {
  static FaceDetectorService? _instance;
  FaceDetector? _detector;
  bool _isInitialized = false;

  FaceDetectorService._();

  static FaceDetectorService get instance {
    _instance ??= FaceDetectorService._();
    return _instance!;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      _detector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,   // smile, eye open probability
          enableTracking: false,        // not tracking, detect 1 frame
          minFaceSize: 0.1,             // Face detection is possible for faces as small as 10% of the image.
          performanceMode: FaceDetectorMode.accurate,
        ),
      );
      _isInitialized = true;
    }
  }

  /// Detect all faces in the photo
  Future<FaceDetectionResult> detectFaces(File imageFile) async {
    _ensureInitialized();

    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _detector!.processImage(inputImage);

    // Get the actual image size
    final imageSize = await _getImageSize(imageFile);

    final detectedFaces = faces.map((face) {
      return DetectedFace(
        boundingBox: face.boundingBox,
        headEulerAngleY: face.headEulerAngleY,
        headEulerAngleZ: face.headEulerAngleZ,
        smilingProbability: face.smilingProbability,
        leftEyeOpenProbability: face.leftEyeOpenProbability,
        rightEyeOpenProbability: face.rightEyeOpenProbability,
      );
    }).toList();

    // Sort by area descending (largest face first)
    detectedFaces.sort((a, b) => b.area.compareTo(a.area));

    return FaceDetectionResult(
      faces: detectedFaces,
      imageSize: imageSize,
    );
  }

  Future<Size> _getImageSize(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
    } catch (_) {
      return const Size(1080, 1920); // fallback
    }
  }

  void dispose() {
    _detector?.close();
    _isInitialized = false;
    _instance = null;
  }
}
