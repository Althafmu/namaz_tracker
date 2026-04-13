import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// A reusable Neo-brutalist card widget.
///
/// Replicates the CSS design:
/// - border: 2px solid [borderColor] (default theme border)
/// - box-shadow: 4px 4px 0px 0px [borderColor]
/// - border-radius: 16px
class NeoCard extends StatefulWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double shadowOffset;
  final double borderWidth;

  const NeoCard({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.borderRadius = 16.0,
    this.padding,
    this.onTap,
    this.shadowOffset = 4.0,
    this.borderWidth = 2.0,
  });

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isTappable = widget.onTap != null;
    final c = AppColors.of(context);
    final effectiveColor = widget.color ?? c.surface;
    final effectiveBorderColor = widget.borderColor ?? c.border;

    return GestureDetector(
      onTapDown: isTappable
          ? (_) {
              HapticFeedback.lightImpact();
              setState(() => _isPressed = true);
            }
          : null,
      onTapUp: isTappable
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isTappable ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          _isPressed ? widget.shadowOffset : 0.0,
          _isPressed ? widget.shadowOffset : 0.0,
          0.0,
        ),
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: effectiveBorderColor,
            width: widget.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: effectiveBorderColor,
              offset: Offset(
                _isPressed ? 0.0 : widget.shadowOffset,
                _isPressed ? 0.0 : widget.shadowOffset,
              ),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: widget.padding != null
            ? Padding(padding: widget.padding!, child: widget.child)
            : widget.child,
      ),
    );
  }
}
