import 'package:flutter/material.dart';
import '../services/face_detector_service.dart';
import '../theme/app_theme.dart';

/// CustomPainter draws bounding boxes and labels onto images after detection.
class FaceOverlayPainter extends CustomPainter {
  final List<DetectedFace> faces;
  final Size imageSize;
  final Size widgetSize;

  FaceOverlayPainter({
    required this.faces,
    required this.imageSize,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scale from image coordinates → widget coordinates
    final scaleX = widgetSize.width / imageSize.width;
    final scaleY = widgetSize.height / imageSize.height;

    for (int i = 0; i < faces.length; i++) {
      final face = faces[i];
      final isPrimary = i == 0;

      final scaledRect = Rect.fromLTRB(
        face.boundingBox.left * scaleX,
        face.boundingBox.top * scaleY,
        face.boundingBox.right * scaleX,
        face.boundingBox.bottom * scaleY,
      );

      // Color by quality
      final color = isPrimary ? AppTheme.accent : AppTheme.primary;

      // Bounding box
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isPrimary ? 2.5 : 1.5;

      _drawCornerBox(canvas, scaledRect, boxPaint, isPrimary ? 16.0 : 10.0);

      // Label
      _drawLabel(
        canvas,
        isPrimary ? 'Primary • ${face.qualityLabel}' : 'Face ${i + 1}',
        scaledRect,
        color,
      );
    }
  }

  /// Draw a corner bracket style instead of a full rectangle.
  void _drawCornerBox(Canvas canvas, Rect rect, Paint paint, double cornerLen) {
    final path = Path();

    // Top-left
    path.moveTo(rect.left, rect.top + cornerLen);
    path.lineTo(rect.left, rect.top);
    path.lineTo(rect.left + cornerLen, rect.top);

    // Top-right
    path.moveTo(rect.right - cornerLen, rect.top);
    path.lineTo(rect.right, rect.top);
    path.lineTo(rect.right, rect.top + cornerLen);

    // Bottom-right
    path.moveTo(rect.right, rect.bottom - cornerLen);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.right - cornerLen, rect.bottom);

    // Bottom-left
    path.moveTo(rect.left + cornerLen, rect.bottom);
    path.lineTo(rect.left, rect.bottom);
    path.lineTo(rect.left, rect.bottom - cornerLen);

    canvas.drawPath(path, paint);
  }

  void _drawLabel(Canvas canvas, String text, Rect rect, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const padding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final bgRect = Rect.fromLTWH(
      rect.left,
      rect.top - textPainter.height - padding.vertical - 2,
      textPainter.width + padding.horizontal,
      textPainter.height + padding.vertical,
    );

    // Background pill
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = color.withValues(alpha: 0.85),
    );

    // Text
    textPainter.paint(
      canvas,
      Offset(
        bgRect.left + padding.left,
        bgRect.top + padding.top,
      ),
    );
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) =>
      oldDelegate.faces != faces || oldDelegate.widgetSize != widgetSize;
}
