import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/upload_card.dart';
import '../widgets/disclaimer_banner.dart';
import 'camera_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  const DisclaimerBanner(),
                  const SizedBox(height: 28),
                  _buildHeroSection(context),
                  const SizedBox(height: 32),
                  UploadCard(
                    onCameraPressed: () => _openCamera(context),
                  ),
                  const SizedBox(height: 32),
                  _buildHowItWorks(context),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (result != null) {
      // TODO Day 8+ — pass image to face detector
      debugPrint('Got image from camera: ${result.path}');
    }
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.background,
      pinned: true,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.face_retouching_natural,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'FaceSeek',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: AppTheme.onSurfaceMuted),
          onPressed: () {
            // TODO Day 21+ - history screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming soon — Day 21+')),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find faces\nacross the web.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 32,
                height: 1.2,
                letterSpacing: -1,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Upload a photo, detect the face, and discover where it appears online.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    final steps = [
      (Icons.upload_rounded, 'Upload', 'Take a photo or pick from gallery'),
      (Icons.face_rounded, 'Detect', 'ML Kit finds the face on-device'),
      (Icons.travel_explore_rounded, 'Search', 'Reverse search finds web results'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How it works',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          return _StepTile(
            number: i + 1,
            icon: step.$1,
            title: step.$2,
            subtitle: step.$3,
          );
        }),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final int number;
  final IconData icon;
  final String title;
  final String subtitle;

  const _StepTile({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: const TextStyle(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.onSurfaceMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
