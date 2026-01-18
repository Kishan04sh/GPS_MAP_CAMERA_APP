import 'package:flutter/material.dart';
import 'package:gps_map_camera/core/constants/app_colors.dart';

class InlineAnimatedLoader extends StatefulWidget {
  final double size;

  const InlineAnimatedLoader({super.key, this.size = 24.0});

  @override
  State<InlineAnimatedLoader> createState() => _InlineAnimatedLoaderState();
}

class _InlineAnimatedLoaderState extends State<InlineAnimatedLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.2).animate(
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
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: child,
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.blueBrandGradient
          // gradient: LinearGradient(
          //   colors: [Color(0xFF3A6DB0), Color(0xFF1B2C59)],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
        ),
        child: const Center(
          child: Icon(Icons.gps_fixed, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
