import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/controllers/auth_provider.dart';
import '../../cart/controllers/dealer_cart_controller.dart';
import '../controllers/dealer_order_controller.dart';
import '../models/dealer_payment_method.dart';

class DealerCheckoutScreen extends StatefulWidget {
  const DealerCheckoutScreen({super.key});

  @override
  State<DealerCheckoutScreen> createState() => _DealerCheckoutScreenState();
}

class _DealerCheckoutScreenState extends State<DealerCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _notesController = TextEditingController();

  DealerPaymentMethod _selectedPaymentMethod = DealerPaymentMethod.upfront;
  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final cartController = context.read<DealerCartController>();
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    // Validate credit availability
    if (_selectedPaymentMethod == DealerPaymentMethod.credit30Days &&
        user.credit30DaysEnabled != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('30-day credit not available for your account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == DealerPaymentMethod.credit90Days &&
        user.credit90DaysEnabled != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('90-day credit not available for your account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final orderController = DealerOrderController();

      final success = await orderController.placeOrder(
        userId: user.id,
        cartItems: cartController.items,
        shippingAddress: _addressController.text,
        shippingCity: _cityController.text,
        shippingState: _stateController.text,
        shippingPincode: _pincodeController.text,
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text,
      );

      if (success && mounted) {
        // Clear cart
        await cartController.clearCart();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<DealerCartController>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final total = cartController.subtotal;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Address Section
                    Text(
                      'Delivery Address',
                      style: AppTextStyles.titleLarge(color: context.colors.black),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Street Address',
                        hintText: 'Enter delivery address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stateController,
                            decoration: InputDecoration(
                              labelText: 'State',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _pincodeController,
                      decoration: InputDecoration(
                        labelText: 'Pincode',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pincode';
                        }
                        if (value.length != 6) {
                          return 'Pincode must be 6 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Payment Method Section
                    Text(
                      'Payment Method',
                      style: AppTextStyles.titleLarge(color: context.colors.black),
                    ),
                    const SizedBox(height: 16),

                    // Upfront Payment
                    _buildPaymentOption(
                      title: 'Upfront Payment',
                      subtitle: 'Pay now via online payment',
                      icon: Icons.payment,
                      value: DealerPaymentMethod.upfront,
                      color: context.colors.primary,
                      isAvailable: true,
                    ),

                    const SizedBox(height: 12),

                    // 30-Day Credit
                    _buildPaymentOption(
                      title: '30 Days Credit',
                      subtitle: user?.credit30DaysEnabled == true
                          ? 'Payment due in 30 days'
                          : 'Not available for your account',
                      icon: Icons.calendar_month,
                      value: DealerPaymentMethod.credit30Days,
                      color: const Color(0xFFFF9800),
                      isAvailable: user?.credit30DaysEnabled == true,
                    ),

                    const SizedBox(height: 12),

                    // 90-Day Credit
                    _buildPaymentOption(
                      title: '90 Days Credit',
                      subtitle: user?.credit90DaysEnabled == true
                          ? 'Payment due in 90 days'
                          : 'Not available for your account',
                      icon: Icons.calendar_today,
                      value: DealerPaymentMethod.credit90Days,
                      color: const Color(0xFF9B59B6),
                      isAvailable: user?.credit90DaysEnabled == true,
                    ),

                    const SizedBox(height: 24),

                    // Order Notes
                    Text(
                      'Order Notes (Optional)',
                      style: AppTextStyles.titleMedium(color: context.colors.black),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Any special instructions?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Total & Place Order
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: AppTextStyles.titleLarge(color: context.colors.black),
                      ),
                      Text(
                        'Rs ${total.toStringAsFixed(0)}',
                        style: AppTextStyles.titleLarge(color: context.colors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Place Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required DealerPaymentMethod value,
    required Color color,
    required bool isAvailable,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: isAvailable
          ? () => setState(() => _selectedPaymentMethod = value)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : isAvailable
                    ? context.colors.mist
                    : context.colors.mist.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isAvailable ? color : context.colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium(
                      color: isAvailable ? context.colors.black : context.colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(
                      color: isAvailable ? context.colors.grey : context.colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Radio<DealerPaymentMethod>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: isAvailable
                  ? (val) => setState(() => _selectedPaymentMethod = val!)
                  : null,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
