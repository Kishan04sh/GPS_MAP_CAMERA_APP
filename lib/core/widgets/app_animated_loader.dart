
import 'package:flutter/material.dart';
import 'package:gps_map_camera/core/constants/app_colors.dart';

class AppAnimatedLoader extends StatefulWidget {
  final String? message;
  final bool barrierDismissible;

  const AppAnimatedLoader({
    super.key,
    this.message,
    this.barrierDismissible = false,
  });

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppAnimatedLoader(message: message),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  State<AppAnimatedLoader> createState() => _AppAnimatedLoaderState();
}

class _AppAnimatedLoaderState extends State<AppAnimatedLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.1416).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => widget.barrierDismissible,
      child: Material(
        color: Colors.black45,
        child: Center(
          child: Container(
            width: mq.width * 0.65,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.blueSoftGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  ),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.blueBrandGradient,
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.grey300,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        width: 1.5,
                        color: Colors.transparent,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Multi-color circular border
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _GradientCircleBorderPainter(),
                          ),
                        ),
                        const Center(
                          child: Icon(Icons.gps_fixed, color: AppColors.white, size: 36),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.message != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.brandDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for multi-color circular border
class _GradientCircleBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [Colors.blue, Colors.lightBlueAccent, Colors.blueAccent, Colors.cyan, Colors.blue],
        startAngle: 0.0,
        endAngle: 6.2832, // 2*PI
        tileMode: TileMode.clamp,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final radius = size.width / 2 - 2;
    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
