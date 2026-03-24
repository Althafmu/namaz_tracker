import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A Neo-brutalist button with press animation.
///
/// Replicates the CSS:
/// - Normal: box-shadow: 4px 4px 0px 0px #2B2D42
/// - Active: box-shadow: 0px; transform: translate(4px, 4px)
class NeoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final double borderRadius;
  final double height;
  final bool isFullWidth;

  const NeoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = AppColors.primary,
    this.textColor = AppColors.surface,
    this.icon,
    this.borderRadius = 16.0,
    this.height = 56.0,
    this.isFullWidth = true,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          _isPressed ? 4.0 : 0.0,
          _isPressed ? 4.0 : 0.0,
          0.0,
        ),
        width: widget.isFullWidth ? double.infinity : null,
        height: widget.height,
        padding: EdgeInsets.symmetric(horizontal: widget.isFullWidth ? 0 : 20.0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: AppColors.border,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.border,
              offset: Offset(
                _isPressed ? 0.0 : 4.0,
                _isPressed ? 0.0 : 4.0,
              ),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize:
              widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: AppTextStyles.bodyLarge.copyWith(
                color: widget.textColor,
                letterSpacing: 0.5,
              ),
            ),
            if (widget.icon != null) ...[
              const SizedBox(width: 8),
              Icon(widget.icon, color: widget.textColor, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}
