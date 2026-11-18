import 'package:flutter/material.dart';

/// Reusable, restrained motion primitives shared across features.
/// Everything is opacity + small offsets with ease-out curves — no bouncy
/// spring effects, no scale tricks — so the app feels alive but calm.

/// Fades/slides a child in when it first mounts. Stagger with [index] and
/// [staggerMs] for list and section entrances.
class RevealOnMount extends StatefulWidget {
  const RevealOnMount({
    super.key,
    required this.child,
    this.index = 0,
    this.staggerMs = 70,
    this.baseDelayMs = 40,
  });

  final Widget child;
  final int index;
  final int staggerMs;
  final int baseDelayMs;

  @override
  State<RevealOnMount> createState() => _RevealOnMountState();
}

class _RevealOnMountState extends State<RevealOnMount> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(
        milliseconds: widget.baseDelayMs + widget.index * widget.staggerMs,
      ),
      () {
        if (mounted) setState(() => _shown = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _shown ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _shown ? Offset.zero : const Offset(0, 0.04),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Integer label that animates toward its new value instead of snapping.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 350),
  });

  final int value;
  final TextStyle? style;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return Text('${animated.round()}$suffix', style: style);
      },
    );
  }
}

/// Standard press feedback: shrinks slightly while pressed and springs
/// back on release. Used on compact interactive elements (nav button,
/// chips, overview rows).
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
