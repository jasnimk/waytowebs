import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/inputs/phone_input_field.dart';

class PhoneFormSection extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneFormSection({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PhoneInputField(
      label: 'Phone Number',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
