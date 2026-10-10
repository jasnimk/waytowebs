import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final double borderRadius;

  const AuthLogo({
    super.key,
    this.size = 80,
    this.iconSize = 40,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.water_drop,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}
