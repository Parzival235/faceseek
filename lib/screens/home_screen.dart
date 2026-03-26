import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/upload_card.dart';
import '../widgets/disclaimer_banner.dart';
import 'camera_screen.dart';
import 'gallery_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // HomeScreen owns the selected image state — single source of truth
  File? _selectedImage;

  // ── Navigation ─────────────────────────────────────────────────

  Future<void> _openGallery() async {
    try {
      final result = await Navigator.push<File>(
        context,
        MaterialPageRoute(builder: (_) => const GalleryScreen()),
      );
      if (result != null && mounted) {
        setState(() => _selectedImage = result);
      }
    } catch (e) {
      if (mounted) _showError('Could not open gallery. Please try again.');
    }
  }

  Future<void> _openCamera() async {
    try {
      final result = await Navigator.push<File>(
        context,
        MaterialPageRoute(builder: (_) => const CameraScreen()),
      );
      if (result != null && mounted) {
        setState(() => _selectedImage = result);
      }
    } catch (e) {
      if (mounted) _showError('Could not open camera. Please try again.');
    }
  }

  void _clearImage() => setState(() => _selectedImage = null);

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  const DisclaimerBanner(),
                  const SizedBox(height: 28),
                  _buildHeroSection(),
                  const SizedBox(height: 32),
                  UploadCard(
                    onCameraPressed: _openCamera,
                    onGalleryPressed: _openGallery,
                    selectedImage: _selectedImage,
                    onClearImage: _clearImage,
                  ),
                  const SizedBox(height: 32),
                  _buildHowItWorks(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.background,
      pinned: true,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming soon — Day 21+')),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection() {
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

  Widget _buildHowItWorks() {
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
