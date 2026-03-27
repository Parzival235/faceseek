import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/face_detector_service.dart';

// ── State ──────────────────────────────────────────────────────

enum DetectionStatus { idle, detecting, done, error }

class DetectionState {
  final DetectionStatus status;
  final FaceDetectionResult? result;
  final String? errorMessage;
  final File? sourceImage;

  const DetectionState({
    this.status = DetectionStatus.idle,
    this.result,
    this.errorMessage,
    this.sourceImage,
  });

  bool get isDetecting => status == DetectionStatus.detecting;
  bool get hasResult => status == DetectionStatus.done && result != null;
  bool get hasError => status == DetectionStatus.error;

  DetectionState copyWith({
    DetectionStatus? status,
    FaceDetectionResult? result,
    String? errorMessage,
    File? sourceImage,
  }) {
    return DetectionState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      sourceImage: sourceImage ?? this.sourceImage,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────

class DetectionNotifier extends StateNotifier<DetectionState> {
  DetectionNotifier() : super(const DetectionState());

  Future<void> detectFaces(File imageFile) async {
    state = DetectionState(
      status: DetectionStatus.detecting,
      sourceImage: imageFile,
    );

    try {
      final result = await FaceDetectorService.instance.detectFaces(imageFile);

      if (!result.hasFaces) {
        state = DetectionState(
          status: DetectionStatus.error,
          sourceImage: imageFile,
          errorMessage: 'No face detected. Try a clearer photo with a visible face.',
        );
        return;
      }

      state = DetectionState(
        status: DetectionStatus.done,
        result: result,
        sourceImage: imageFile,
      );
    } catch (e) {
      state = DetectionState(
        status: DetectionStatus.error,
        sourceImage: imageFile,
        errorMessage: 'Detection failed: ${e.toString()}',
      );
    }
  }

  void reset() => state = const DetectionState();
}

// ── Provider ───────────────────────────────────────────────────

final detectionProvider =
    StateNotifierProvider<DetectionNotifier, DetectionState>(
  (ref) => DetectionNotifier(),
);
