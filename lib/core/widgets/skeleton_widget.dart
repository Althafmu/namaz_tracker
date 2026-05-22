import 'package:flutter/material.dart';

class SkeletonBoxWidget extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonBoxWidget({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  State<SkeletonBoxWidget> createState() => _SkeletonBoxWidgetState();
}

class _SkeletonBoxWidgetState extends State<SkeletonBoxWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonLineWidget extends StatelessWidget {
  final double? width;

  const SkeletonLineWidget({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return SkeletonBoxWidget(
      height: 16,
      width: width ?? double.infinity,
      borderRadius: 4,
    );
  }
}

class SkeletonCircleWidget extends StatelessWidget {
  final double size;

  const SkeletonCircleWidget({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
