import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/detection_provider.dart';
import '../services/face_detector_service.dart';
import '../theme/app_theme.dart';
import '../widgets/face_overlay_painter.dart';

class DetectionScreen extends ConsumerStatefulWidget {
  final File imageFile;
  const DetectionScreen({super.key, required this.imageFile});

  @override
  ConsumerState<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends ConsumerState<DetectionScreen> {
  final _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Run detection as soon as the screen is turned on.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(detectionProvider.notifier).detectFaces(widget.imageFile);
    });
  }

  @override
  void dispose() {
    ref.read(detectionProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(detectionProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(state),
            Expanded(child: _buildImageArea(state)),
            _buildBottomPanel(state),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────

  Widget _buildTopBar(DetectionState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppTheme.onSurface, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _titleFor(state),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
            ),
          ),
          if (state.hasResult)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.face_rounded,
                      color: AppTheme.accent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${state.result!.faceCount} face${state.result!.faceCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _titleFor(DetectionState state) {
    switch (state.status) {
      case DetectionStatus.detecting:
        return 'Detecting...';
      case DetectionStatus.done:
        return 'Face Detected';
      case DetectionStatus.error:
        return 'No Face Found';
      default:
        return 'Detection';
    }
  }

  // ── Image Area ─────────────────────────────────────────────────

  Widget _buildImageArea(DetectionState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            Image.file(
              widget.imageFile,
              key: _imageKey,
              fit: BoxFit.cover,
            ),

            // Bounding box overlay
            if (state.hasResult)
              LayoutBuilder(
                builder: (context, constraints) {
                  return CustomPaint(
                    painter: FaceOverlayPainter(
                      faces: state.result!.faces,
                      imageSize: state.result!.imageSize,
                      widgetSize: Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      ),
                    ),
                  );
                },
              ),

            // Detecting overlay
            if (state.isDetecting) _DetectingOverlay(),

            // Error overlay
            if (state.hasError) _ErrorOverlay(message: state.errorMessage!),
          ],
        ),
      ),
    );
  }

  // ── Bottom Panel ───────────────────────────────────────────────

  Widget _buildBottomPanel(DetectionState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.hasResult) ...[
            _FaceInfoCard(result: state.result!),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO Day 13+ — pass primary face to search
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Search coming Day 13+'),
                    ),
                  );
                },
                icon: const Icon(Icons.travel_explore_rounded, size: 18),
                label: const Text('Search This Face'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
          if (state.hasError) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Try Another Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.onSurface,
                  side: const BorderSide(color: AppTheme.surfaceVariant),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _DetectingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.accent,
              strokeWidth: 2.5,
            ),
            SizedBox(height: 16),
            Text(
              'Scanning for faces...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Running on-device with ML Kit',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  final String message;
  const _ErrorOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.face_retouching_off_rounded,
                  color: AppTheme.error, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceInfoCard extends StatelessWidget {
  final FaceDetectionResult result;
  const _FaceInfoCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final primary = result.primaryFace!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Row(
        children: [
          _InfoChip(
            icon: Icons.face_rounded,
            label: '${result.faceCount} face${result.faceCount > 1 ? 's' : ''}',
            color: AppTheme.accent,
          ),
          const SizedBox(width: 10),
          _InfoChip(
            icon: Icons.stars_rounded,
            label: primary.qualityLabel,
            color: _qualityColor(primary.qualityScore),
          ),
          if (primary.smilingProbability != null) ...[
            const SizedBox(width: 10),
            _InfoChip(
              icon: Icons.sentiment_satisfied_rounded,
              label: '${(primary.smilingProbability! * 100).toInt()}% smile',
              color: AppTheme.primary,
            ),
          ],
        ],
      ),
    );
  }

  Color _qualityColor(double score) {
    if (score >= 0.8) return const Color(0xFF4CAF50);
    if (score >= 0.6) return const Color(0xFFFF9800);
    return AppTheme.error;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
