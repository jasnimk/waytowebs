import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/presentation/widgets/buttons/primary_button.dart';
import '../../../shared/presentation/widgets/common/app_snackbar.dart';
import '../controllers/auth_provider.dart';
import '../widgets/auth_logo.dart';
import '../widgets/phone_form_section.dart';
import '../widgets/terms_text.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'customer';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter valid phone number';
    }
    return null;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phoneNumber = _phoneController.text.trim();

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.sendOtp(phoneNumber);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        context.go('/auth/otp');
      } else {
        AppSnackbar.error(context, authProvider.errorMessage ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildRoleChip(String value, String label, IconData icon) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.mist,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : context.colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium(
                  color: isSelected ? Colors.white : context.colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),

                        // Logo - Smaller
                        const Center(
                          child: SizedBox(
                            height: 60,
                            child: AuthLogo(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Header - Compact
                        Text(
                          'Welcome Back',
                          style: AppTextStyles.displaySmall(color: context.colors.black),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue',
                          style: AppTextStyles.bodyLarge(color: context.colors.grey),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Role Selection - 2 per row
                        Text(
                          'Login As',
                          style: AppTextStyles.titleMedium(color: context.colors.black),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(child: _buildRoleChip('customer', 'Customer', Icons.person_outline)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildRoleChip('dealer', 'Dealer', Icons.business_outlined)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildRoleChip('plumber', 'Plumber', Icons.build_outlined)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildRoleChip('admin', 'Admin', Icons.admin_panel_settings_outlined)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Phone Input
                        PhoneFormSection(
                          controller: _phoneController,
                          validator: _validatePhone,
                          onChanged: (value) {
                            if (value.length == 10) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // Terms
                        const TermsText(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Send OTP Button - Fixed at bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PrimaryButton(
                    text: 'Send OTP',
                    onPressed: _isLoading ? null : _sendOtp,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
