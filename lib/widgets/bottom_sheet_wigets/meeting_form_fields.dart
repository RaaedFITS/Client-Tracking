import 'package:flutter/material.dart';

class RequiredLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const RequiredLabel({
    super.key,
    required this.label,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[200],
          fontWeight: FontWeight.w500,
        );

    if (!isRequired) {
      return Text(label, style: textStyle);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.redAccent),
          ),
          child: const Text(
            'Required',
            style: TextStyle(
              fontSize: 11,
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const DarkTextField({
    super.key,
    required this.controller,
    required this.enabled,
    this.hintText,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: const Color(0xFF020617),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF38BDF8),
            width: 1.4,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
