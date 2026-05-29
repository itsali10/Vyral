import 'package:flutter/material.dart';

/// Centers content on wide screens (tablet / desktop Chrome) for readable layouts.
class VyralResponsiveBody extends StatelessWidget {
  const VyralResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = 520,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
