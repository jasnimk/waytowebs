import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ResendOtpSection extends StatelessWidget {
  final bool canResend;
  final bool isResending;
  final int remainingSeconds;
  final VoidCallback onResend;

  const ResendOtpSection({
    super.key,
    required this.canResend,
    required this.isResending,
    required this.remainingSeconds,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return canResend
        ? TextButton(
            onPressed: isResending ? null : onResend,
            child: isResending
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.primary,
                    ),
                  )
                : Text(
                    'Resend OTP',
                    style: AppTextStyles.labelLarge(
                      color: context.colors.primary,
                    ),
                  ),
          )
        : Text(
            'Resend OTP in $remainingSeconds seconds',
            style: AppTextStyles.bodyMedium(
              color: context.colors.grey,
            ),
          );
  }
}
