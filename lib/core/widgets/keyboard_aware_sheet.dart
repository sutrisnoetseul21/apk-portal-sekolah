import 'package:flutter/material.dart';

/// Reusable wrapper for bottom sheets that cleanly handles virtual keyboard (IME)
/// appearance, preventing bottom content from being occluded while dynamically
/// clamping the maxHeight constraint to fit comfortably within the visible viewport.
class KeyboardAwareSheet extends StatelessWidget {
  final Widget child;
  final double maxHeightFactor;
  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final Clip clipBehavior;

  const KeyboardAwareSheet({
    super.key,
    required this.child,
    this.maxHeightFactor = 0.90,
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(24)),
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final insetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final totalHeight = MediaQuery.sizeOf(context).height;
    // Available height between screen top and software keyboard.
    final availableHeight = (totalHeight - insetsBottom).clamp(0.0, totalHeight);
    final targetMaxHeight = (totalHeight * maxHeightFactor).clamp(0.0, availableHeight);

    return Padding(
      padding: EdgeInsets.only(bottom: insetsBottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: targetMaxHeight,
        ),
        clipBehavior: clipBehavior,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

