import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.opacity = 0.5,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (color ?? AppColors.surface).withOpacity(opacity),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
