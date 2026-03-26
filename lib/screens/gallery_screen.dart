import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _picker = ImagePicker();
  File? _selectedImage;
  bool _hasPermission = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.photos.request();
    setState(() {
      _hasPermission = status.isGranted || status.isLimited;
      _isLoading = false;
      if (!_hasPermission) {
        _errorMessage = status.isPermanentlyDenied
            ? 'Photo access permanently denied. Please enable it in Settings.'
            : 'Photo access denied.';
      }
    });
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1200,
      );
      if (picked != null && mounted) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  void _confirmImage() {
    if (_selectedImage != null) {
      // TODO Day 8+ — pass to ML Kit face detector
      Navigator.pop(context, _selectedImage);
    }
  }

  void _retake() => setState(() => _selectedImage = null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
          Text(
            _selectedImage != null ? 'Preview' : 'Choose a Photo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const _LoadingState();

    if (!_hasPermission) {
      return _PermissionDeniedState(
        message: _errorMessage ?? 'Permission denied.',
        onOpenSettings: () => openAppSettings(),
      );
    }

    if (_selectedImage != null) return _buildPreview();

    return _buildPickerPrompt();
  }

  // ── Picker Prompt ──────────────────────────────────────────────

  Widget _buildPickerPrompt() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: AppTheme.primary,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select a photo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Choose a clear, well-lit photo\nwith a visible face for best results.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.onSurfaceMuted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_rounded, size: 20),
              label: const Text('Open Gallery'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildTips(),
        ],
      ),
    );
  }

  Widget _buildTips() {
    final tips = [
      (Icons.light_mode_rounded, 'Good lighting'),
      (Icons.face_rounded, 'Face clearly visible'),
      (Icons.hd_rounded, 'High resolution'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tips
          .map((t) => Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(t.$1, color: AppTheme.accent, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.$2,
                    style: const TextStyle(
                      color: AppTheme.onSurfaceMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }

  // ── Preview ────────────────────────────────────────────────────

  Widget _buildPreview() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_selectedImage!, fit: BoxFit.cover),
                  // Face guide hint
                  Center(
                    child: Container(
                      width: 180,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90),
                        border: Border.all(
                          color: AppTheme.accent.withValues(alpha: 0.7),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Badge
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.white60, size: 13),
                          SizedBox(width: 5),
                          Text(
                            'Face detection on Day 8+',
                            style:
                                TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  label: 'Choose Again',
                  icon: Icons.replay_rounded,
                  onTap: _retake,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _confirmImage,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Use This Photo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primary,
        strokeWidth: 2,
      ),
    );
  }
}

class _PermissionDeniedState extends StatelessWidget {
  final String message;
  final VoidCallback onOpenSettings;

  const _PermissionDeniedState({
    required this.message,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, color: AppTheme.onSurfaceMuted, size: 48),
          const SizedBox(height: 20),
          const Text(
            'No Photo Access',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.onSurfaceMuted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_rounded, size: 18),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.surfaceVariant, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.onSurfaceMuted, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.onSurfaceMuted,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
