import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/camera_controls.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.off;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      await _startCamera(_cameras[_selectedCameraIndex]);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _startCamera(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Camera start error: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      final image = await _controller!.takePicture();
      setState(() {
        _capturedImage = File(image.path);
        _isCapturing = false;
      });
    } catch (e) {
      setState(() => _isCapturing = false);
      debugPrint('Capture error: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() => _isInitialized = false);
    await _controller?.dispose();
    await _startCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    final next = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _controller!.setFlashMode(next);
    setState(() => _flashMode = next);
  }

  void _retake() {
    setState(() => _capturedImage = null);
  }

  void _confirmAndSearch() {
    if (_capturedImage == null) return;
    // TODO Day 8+ — pass to ML Kit face detector
    Navigator.pop(context, _capturedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _capturedImage != null
          ? _buildPreview()
          : _buildCamera(),
    );
  }

  // ── Camera Viewfinder ──────────────────────────────────────────

  Widget _buildCamera() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        if (_isInitialized && _controller != null)
          _CameraPreviewWidget(controller: _controller!)
        else
          const _CameraLoadingPlaceholder(),

        // Top bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const Text(
                  'Position face in frame',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _CircleButton(
                  icon: _flashMode == FlashMode.off
                      ? Icons.flash_off_rounded
                      : Icons.flash_on_rounded,
                  onTap: _toggleFlash,
                  active: _flashMode != FlashMode.off,
                ),
              ],
            ),
          ),
        ),

        // Face guide overlay
        Center(child: _FaceGuideOverlay(isCapturing: _isCapturing)),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: CameraControls(
              onCapture: _takePicture,
              onFlip: _toggleCamera,
              isCapturing: _isCapturing,
              hasFrontCamera: _cameras.length > 1,
            ),
          ),
        ),
      ],
    );
  }

  // ── Captured Preview ──────────────────────────────────────────

  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(_capturedImage!, fit: BoxFit.cover),

        // Dark overlay bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: _PreviewButton(
                      label: 'Retake',
                      icon: Icons.replay_rounded,
                      onTap: _retake,
                      outlined: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PreviewButton(
                      label: 'Use Photo',
                      icon: Icons.search_rounded,
                      onTap: _confirmAndSearch,
                      outlined: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Top close
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _CircleButton(
              icon: Icons.close_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  const _CameraPreviewWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = 1 /
        (controller.value.aspectRatio * size.aspectRatio);
    return Transform.scale(
      scale: scale,
      child: Center(child: CameraPreview(controller)),
    );
  }
}

class _CameraLoadingPlaceholder extends StatelessWidget {
  const _CameraLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              'Starting camera...',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceGuideOverlay extends StatelessWidget {
  final bool isCapturing;
  const _FaceGuideOverlay({required this.isCapturing});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 240,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(120),
        border: Border.all(
          color: isCapturing
              ? AppTheme.accent
              : Colors.white.withOpacity(0.5),
          width: isCapturing ? 3 : 1.5,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primary.withOpacity(0.3)
              : Colors.black38,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? AppTheme.primary : Colors.white24,
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  const _PreviewButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.outlined,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppTheme.primary,
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: Colors.white38, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
