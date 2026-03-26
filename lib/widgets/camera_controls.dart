import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onFlip;
  final bool isCapturing;
  final bool hasFrontCamera;

  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onFlip,
    required this.isCapturing,
    required this.hasFrontCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Placeholder kiri (reserved for gallery shortcut Day 3+)
          const SizedBox(width: 56),

          // Shutter button
          GestureDetector(
            onTap: isCapturing ? null : onCapture,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isCapturing ? 68 : 72,
              height: isCapturing ? 68 : 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isCapturing ? 52 : 58,
                  height: isCapturing ? 52 : 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCapturing
                        ? AppTheme.accent
                        : Colors.white,
                  ),
                  child: isCapturing
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Flip camera button
          GestureDetector(
            onTap: hasFrontCamera ? onFlip : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: hasFrontCamera ? 1.0 : 0.3,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: const Icon(
                  Icons.flip_camera_ios_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
