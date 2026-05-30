import 'package:flutter/material.dart';

abstract final class VyralAnimations {
  static const Curve easeOutExpo = Cubic(0.16, 1.0, 0.3, 1.0);
  static const Curve easeOutQuart = Cubic(0.25, 1.0, 0.5, 1.0);

  static const int _staggerMaxItems = 8;
  static const int _staggerStepMs = 75;

  /// Returns a staggered delay for list items. Items beyond [_staggerMaxItems]
  /// get Duration.zero so they appear instantly while scrolling.
  static Duration staggerDelay(int index) {
    if (index >= _staggerMaxItems) return Duration.zero;
    return Duration(milliseconds: index * _staggerStepMs);
  }
}

/// Fades and translates a widget in from [slideOffset] when first mounted.
/// Use [delay] to stagger multiple siblings.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.slideOffset = const Offset(0, 22),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: widget.slideOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: VyralAnimations.easeOutExpo),
    );

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(offset: _slide.value, child: child),
      ),
      child: widget.child,
    );
  }
}

/// Plays a quick scale-pop (1 → 1.35 → 0.9 → 1) when [trigger] changes value.
/// Wrap an icon with this to get satisfying like/save feedback.
class PopAnimation extends StatefulWidget {
  const PopAnimation({super.key, required this.child, required this.trigger});

  final Widget child;
  final Object trigger;

  @override
  State<PopAnimation> createState() => _PopAnimationState();
}

class _PopAnimationState extends State<PopAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 310),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.38), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.38, end: 0.88), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(PopAnimation old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: widget.child,
    );
  }
}

/// Wraps any widget with a subtle scale-down on press using a [Listener]
/// so it does NOT absorb the tap — buttons inside still receive onPressed.
class AnimatedPressable extends StatefulWidget {
  const AnimatedPressable({
    super.key,
    required this.child,
    this.enabled = true,
    this.scaleFactor = 0.96,
  });

  final Widget child;
  final bool enabled;
  final double scaleFactor;

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed && widget.enabled ? widget.scaleFactor : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Gently oscillates opacity between [minOpacity] and 1.0 on repeat.
/// Good for sparkle/idle pulse effects.
class PulseAnimation extends StatefulWidget {
  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2200),
    this.minOpacity = 0.35,
  });

  final Widget child;
  final Duration duration;
  final double minOpacity;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _opacity = Tween(begin: widget.minOpacity, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, child) => Opacity(opacity: _opacity.value, child: child),
      child: widget.child,
    );
  }
}
