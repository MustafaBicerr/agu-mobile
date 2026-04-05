import 'package:agu_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PageGradientBackground extends StatelessWidget {
  final Widget child;

  const PageGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.pageGradientLight,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
