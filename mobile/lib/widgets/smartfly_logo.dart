import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SmartFlyLogo extends StatelessWidget {
  const SmartFlyLogo({super.key, this.size = 40, this.showName = true});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            gradient: LinearGradient(
              colors: isDark ? AppColors.buttonGradientDark : AppColors.buttonGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBright.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.flight, color: Colors.white, size: size * 0.5),
        ),
        if (showName) ...[
          const SizedBox(width: 10),
          Text(
            'SmartFly',
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ],
    );
  }
}
