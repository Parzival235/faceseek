import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UploadCard extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final File? selectedImage;
  final VoidCallback? onClearImage;

  const UploadCard({
    super.key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    this.selectedImage,
    this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceVariant, width: 1.5),
      ),
      child: Column(
        children: [
          _buildImageArea(context),
          const Divider(color: AppTheme.surfaceVariant, height: 1),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildImageArea(BuildContext context) {
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Stack(
          children: [
            Image.file(
              selectedImage!,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: onClearImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white60, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Face detection coming Day 8+',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onGalleryPressed,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: 200,
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tap to upload a photo',
              style: TextStyle(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'JPG, PNG up to 10MB',
              style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onTap: onGalleryPressed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              onTap: onCameraPressed,
            ),
          ),
          if (selectedImage != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO Day 13+ — trigger search
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search coming Day 13+')),
                  );
                },
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text('Search'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.onSurfaceMuted, size: 18),
            const SizedBox(width: 6),
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
