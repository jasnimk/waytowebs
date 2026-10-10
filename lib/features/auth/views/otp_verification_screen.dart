import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/presentation/widgets/buttons/primary_button.dart';
import '../../../shared/presentation/widgets/common/app_snackbar.dart';
import '../controllers/auth_provider.dart';
import '../widgets/otp_header.dart';
import '../widgets/otp_input_section.dart';
import '../widgets/resend_otp_section.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp(String otp) async {
    print('🔵 [OTP] Starting OTP verification...');
    setState(() => _isVerifying = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(otp);

    print('🔵 [OTP] Verification completed. Success: $success, Mounted: $mounted');

    if (!mounted) {
      print('⚠️ [OTP] Widget not mounted, cannot show error');
      return;
    }

    setState(() => _isVerifying = false);

    if (success) {
      print('✅ [OTP] Success - navigation handled by router');
      // Navigation handled by router's redirect logic
    } else {
      print('❌ [OTP] Failed - showing error snackbar');
      print('🔵 [OTP] Error message: ${authProvider.errorMessage ?? 'Invalid OTP'}');
      _pinController.clear();
      AppSnackbar.error(
        context,
        authProvider.errorMessage ?? 'Invalid OTP',
      );
      print('🔵 [OTP] Snackbar shown');
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    final authProvider = context.read<AuthProvider>();

    if (authProvider.phoneNumber == null) {
      context.pop();
      return;
    }

    final success = await authProvider.sendOtp(authProvider.phoneNumber!);

    if (!mounted) return;

    setState(() => _isResending = false);

    if (success) {
      AppSnackbar.success(context, 'OTP resent successfully');
      _startTimer();
    } else {
      AppSnackbar.error(
        context,
        authProvider.errorMessage ?? 'Failed to resend OTP',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = context.read<AuthProvider>().phoneNumber ?? '';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: context.colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                OtpHeader(phoneNumber: phoneNumber),

                const SizedBox(height: 40),

                // OTP Input
                Center(
                  child: OtpInputSection(
                    controller: _pinController,
                    focusNode: _focusNode,
                    onCompleted: _verifyOtp,
                  ),
                ),

                const SizedBox(height: 32),

                // Resend OTP
                Center(
                  child: ResendOtpSection(
                    canResend: _canResend,
                    isResending: _isResending,
                    remainingSeconds: _remainingSeconds,
                    onResend: _resendOtp,
                  ),
                ),

                const SizedBox(height: 200),

                // Verify Button
                PrimaryButton(
                  text: 'Verify & Continue',
                  onPressed: _pinController.text.length == 6
                      ? () => _verifyOtp(_pinController.text)
                      : null,
                  isLoading: _isVerifying,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
