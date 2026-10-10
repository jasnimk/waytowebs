import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class OtpHeader extends StatelessWidget {
  final String phoneNumber;

  const OtpHeader({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify OTP',
          style: AppTextStyles.displayLarge(color: context.colors.black),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            text: 'Enter the 6-digit code sent to ',
            style: AppTextStyles.bodyMedium(color: context.colors.grey),
            children: [
              TextSpan(
                text: '+91$phoneNumber',
                style: AppTextStyles.bodyMedium(
                  color: context.colors.primary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
