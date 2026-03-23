import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DisclaimerBanner extends StatefulWidget {
  const DisclaimerBanner({super.key});

  @override
  State<DisclaimerBanner> createState() => _DisclaimerBannerState();
}

class _DisclaimerBannerState extends State<DisclaimerBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF9800),
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'For personal & research use only. Do not use to identify or track others without consent.',
              style: TextStyle(
                color: const Color(0xFFFF9800).withOpacity(0.9),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _dismissed = true),
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFFFF9800),
              size: 14,
            ),
          ),
        ],
      ),
    );
  }
}
