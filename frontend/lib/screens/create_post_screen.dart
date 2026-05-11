import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';
import 'package:image_picker/image_picker.dart';

import '../services/post_creation_service.dart';
import '../theme/vyral_theme.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_universal_actions.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  File? _selectedImage;
  final _picker = ImagePicker();
  bool _isPosting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (x != null) {
      setState(() => _selectedImage = File(x.path));
    }
  }

  void _addLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location coming soon')),
    );
  }

  void _addTag() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tags coming soon')),
    );
  }

  void _addMood() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mood coming soon')),
    );
  }

  Future<void> _submitPost() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a caption or a photo to post.')),
      );
      return;
    }
    setState(() => _isPosting = true);
    try {
      await PostCreationService.instance.submitPost(
        caption: caption,
        image: _selectedImage,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create post: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.surface : VyralColors.mainBackground;
    final divider = isDark ? VyralColors.blueGray : VyralColors.border;
    final title = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.dustyRose : VyralColors.secondaryText;
    final card = isDark ? VyralColors.card : VyralColors.cardBackground;
    final inputText = isDark ? VyralColors.caption : VyralColors.primaryText;
    final toolbarBg = isDark ? VyralColors.deepBlack : VyralColors.cardBackground;
    final toolbarBorder = isDark ? Colors.transparent : VyralColors.border;
    final maxCaptionLength = 280;

    return Scaffold(
      backgroundColor: pageBg,
      drawer: const VyralNavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: VyralTypography.inter(
              fontSize: 15,
              color: muted,
            ),
          ),
        ),
        title: Text(
          'New Post',
          style: VyralTypography.display(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: title,
          ),
        ),
        actions: [
          VyralOpenNavMenuButton(color: title, size: 22),
          const VyralUniversalActions(compact: true),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _isPosting ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? VyralColors.softPink : VyralColors.primaryRose,
                foregroundColor: isDark ? VyralColors.deepBlack : VyralColors.cardBackground,
                minimumSize: const Size(64, 32),
                shape: const StadiumBorder(),
                textStyle: VyralTypography.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: _isPosting
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? VyralColors.deepBlack : VyralColors.cardBackground,
                      ),
                    )
                  : const Text('Post'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(
              color: VyralColors.blueGray,
              height: 1,
              thickness: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isDark
                              ? VyralColors.blueGray
                              : VyralColors.secondaryBackground,
                          child: Text(
                            'Y',
                            style: VyralTypography.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? VyralColors.white : VyralColors.primaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _captionController,
                            maxLines: null,
                            minLines: 4,
                            decoration: InputDecoration.collapsed(
                              hintText: "What's on your mind?",
                              hintStyle: VyralTypography.inter(
                                fontSize: 16,
                                color: isDark
                                    ? VyralColors.mutedText
                                    : VyralColors.placeholder,
                              ),
                            ),
                            style: VyralTypography.inter(
                              fontSize: 16,
                              color: inputText,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            width: double.infinity,
                            height: _selectedImage == null ? 200 : 250,
                            decoration: BoxDecoration(
                              color: card,
                              borderRadius: BorderRadius.all(Radius.circular(18)),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo_camera_outlined,
                                        size: 32,
                                        color: isDark
                                            ? VyralColors.mutedText
                                            : VyralColors.secondaryText,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add photo or video',
                                        style: VyralTypography.inter(
                                          fontSize: 14,
                                          color: isDark
                                              ? VyralColors.mutedText
                                              : VyralColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          if (_selectedImage != null)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImage = null),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: DashedRoundedRectPainter(
                                  color: divider,
                                  borderRadius: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: toolbarBg,
                border: Border(top: BorderSide(color: toolbarBorder)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Center(
                      child: _ToolButton(
                        icon: Icons.photo_outlined,
                        label: 'Photo',
                        onTap: _pickImage,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _ToolButton(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        onTap: _addLocation,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _ToolButton(
                        icon: Icons.sell_outlined,
                        label: 'Tag',
                        onTap: _addTag,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _ToolButton(
                        icon: Icons.mood_outlined,
                        label: 'Mood',
                        onTap: _addMood,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '✦ vyral',
                    textAlign: TextAlign.center,
                    style: VyralTypography.inter(
                      fontSize: 12,
                      color: muted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_captionController.text.length}/$maxCaptionLength',
                    style: VyralTypography.inter(
                      fontSize: 12,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? VyralColors.surface : VyralColors.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isDark ? VyralColors.white : VyralColors.primaryText),
            const SizedBox(height: 4),
            Text(
              label,
              style: VyralTypography.inter(
                fontSize: 10,
                color: isDark ? VyralColors.mutedText : VyralColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedRoundedRectPainter extends CustomPainter {
  DashedRoundedRectPainter({
    required this.color,
    required this.borderRadius,
    this.strokeWidth = 1,
    this.dashLength = 5,
    this.gapLength = 4,
  });

  final Color color;
  final double borderRadius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(max(0, borderRadius - strokeWidth / 2)),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
