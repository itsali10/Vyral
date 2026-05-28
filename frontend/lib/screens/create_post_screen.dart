import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../models/picked_media.dart';
import '../services/api_client.dart';
import '../services/media_picker_service.dart';
import '../services/post_creation_service.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_theme.dart';
import '../widgets/picked_image_preview.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_scaffold.dart';
import '../widgets/vyral_universal_actions.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  PickedMedia? _selectedImage;
  bool _isPosting = false;
  bool _isPickingImage = false;
  String? _location;
  final List<String> _hashtags = [];
  String? _moodLabel;

  bool get _picksFromComputer => MediaPickerService.picksFromComputer;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingImage || _isPosting) return;
    setState(() => _isPickingImage = true);
    try {
      final picked = await MediaPickerService.instance.pickImage();
      if (!mounted) return;
      if (picked != null) {
        setState(() => _selectedImage = picked);
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _addLocation() async {
    final controller = TextEditingController(text: _location ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'City, country'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && value.isNotEmpty && mounted) {
      setState(() => _location = value);
    }
  }

  Future<void> _addTag() async {
    final controller = TextEditingController(
      text: _hashtags.map((t) => '#$t').join(' '),
    );
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add tags'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '#sunset #vibes or sunset, vibes',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && mounted) {
      final tags = value
          .split(RegExp(r'[,\s]+'))
          .map((t) => t.replaceAll('#', '').trim())
          .where((t) => t.isNotEmpty)
          .toList();
      setState(() {
        _hashtags
          ..clear()
          ..addAll(tags);
      });
    }
  }

  Future<void> _addMood() async {
    const moods = ['✨ Inspired', '🔥 Hyped', '😌 Chill', '💪 Motivated', '😂 Funny'];
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: moods
              .map(
                (m) => ListTile(
                  title: Text(m),
                  onTap: () => Navigator.pop(ctx, m),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _moodLabel = picked);
  }

  Future<void> _submitPost() async {
    var caption = _captionController.text.trim();
    if (_moodLabel != null && _moodLabel!.isNotEmpty) {
      caption = caption.isEmpty ? _moodLabel! : '${_moodLabel!} $caption';
    }
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
        hashtags: _hashtags.isEmpty ? null : _hashtags,
        location: _location,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException
          ? friendlyApiMessage(e)
          : 'Could not create post. Try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
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

    return VyralScaffold(
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
      body: Column(
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _PostImageSlot(
                      selectedImage: _selectedImage,
                      isPickingImage: _isPickingImage,
                      cardColor: card,
                      dividerColor: divider,
                      mutedColor: isDark
                          ? VyralColors.mutedText
                          : VyralColors.secondaryText,
                      placeholder: _picksFromComputer
                          ? 'Choose image from your computer'
                          : 'Add photo or video',
                      onPick: _pickImage,
                      onClear: () => setState(() => _selectedImage = null),
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
                        onTap: _isPickingImage ? null : _pickImage,
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
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _captionController,
                    builder: (context, value, _) {
                      return Text(
                        '${value.text.length}/$maxCaptionLength',
                        style: VyralTypography.inter(
                          fontSize: 12,
                          color: muted,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

class _PostImageSlot extends StatelessWidget {
  const _PostImageSlot({
    required this.selectedImage,
    required this.isPickingImage,
    required this.cardColor,
    required this.dividerColor,
    required this.mutedColor,
    required this.placeholder,
    required this.onPick,
    required this.onClear,
  });

  final PickedMedia? selectedImage;
  final bool isPickingImage;
  final Color cardColor;
  final Color dividerColor;
  final Color mutedColor;
  final String placeholder;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedImage != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPickingImage ? null : onPick,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: hasImage ? 250 : 200,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: dividerColor),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: PickedImagePreview(
                    media: selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isPickingImage)
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 32,
                        color: mutedColor,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      isPickingImage ? 'Opening gallery…' : placeholder,
                      style: VyralTypography.inter(
                        fontSize: 14,
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
              if (hasImage)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.35),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(24, 24),
                      padding: EdgeInsets.zero,
                    ),
                    iconSize: 14,
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                  ),
                ),
            ],
          ),
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
  final VoidCallback? onTap;

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
