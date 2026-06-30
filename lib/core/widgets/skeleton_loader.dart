import 'package:flutter/material.dart';

/// A shimmer-style skeleton placeholder used while content is loading.
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
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
    final color = Theme.of(context).colorScheme.onSurface;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08 * _animation.value + 0.04),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Skeleton for the home quote card
class QuoteCardSkeleton extends StatelessWidget {
  const QuoteCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonLoader(width: 48, height: 48, borderRadius: 24),
          SizedBox(height: 24),
          SkeletonLoader(height: 20),
          SizedBox(height: 8),
          SkeletonLoader(height: 20),
          SizedBox(height: 8),
          SkeletonLoader(width: 200, height: 20),
          SizedBox(height: 32),
          SkeletonLoader(width: 120, height: 16, borderRadius: 20),
        ],
      ),
    );
  }
}

/// Skeleton for a list tile in history/favorites
class QuoteListTileSkeleton extends StatelessWidget {
  const QuoteListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 14),
          SizedBox(height: 8),
          SkeletonLoader(width: 220, height: 14),
          SizedBox(height: 12),
          SkeletonLoader(width: 100, height: 12, borderRadius: 12),
        ],
      ),
    );
  }
}
