
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// A modern, production-ready reusable widget for empty/error states with retry option
class StatePlaceholder extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final String buttonText;
  final Future<void> Function() onRetry;
  final String? subMessage;

  const StatePlaceholder({
    super.key,
    required this.message,
    required this.icon,
    this.iconColor = Colors.grey,
    this.buttonText = 'Retry',
    required this.onRetry,
    this.subMessage,
  });

  /// Factory for empty state
  factory StatePlaceholder.empty({required Future<void> Function() onRetry}) {
    return StatePlaceholder(
      message: 'No media available',
      icon: Icons.photo_library_outlined,
      iconColor: Colors.grey.shade600,
      buttonText: 'Refresh',
      onRetry: onRetry,
      subMessage: 'Try taking a photo or check your gallery permissions.',
    );
  }

  /// Factory for error state
  factory StatePlaceholder.error({
    required String message,
    required Future<void> Function() onRetry,
  }) {
    return StatePlaceholder(
      message: message,
      icon: Icons.error_outline,
      iconColor: Colors.red.shade600,
      buttonText: 'Retry',
      onRetry: onRetry,
    );
  }

  @override
  State<StatePlaceholder> createState() => _StatePlaceholderState();
}

class _StatePlaceholderState extends State<StatePlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 12).animate(
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF0F4FF),
            Color(0xFFE3EBFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Card(
            elevation: 8,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(0, -_animation.value),
                        child: child,
                      );
                    },
                    child: Icon(
                      widget.icon,
                      size: 90,
                      color: widget.iconColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.subMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      widget.subMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async => await widget.onRetry(),
                      child: Text(widget.buttonText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
