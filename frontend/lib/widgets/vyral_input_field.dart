import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';

class VyralInputField extends StatelessWidget {
  const VyralInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: VyralTypography.inter(fontSize: 14, color: VyralColors.white),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: VyralColors.surface,
          labelText: label,
          labelStyle: VyralTypography.inter(fontSize: 11, color: VyralColors.dustyRose),
          floatingLabelStyle: VyralTypography.inter(fontSize: 11, color: VyralColors.dustyRose),
          hintText: hint,
          hintStyle: VyralTypography.inter(fontSize: 14, color: VyralColors.mutedText),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: VyralColors.blueGray, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: VyralColors.blueGray, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: VyralColors.softPink, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: VyralColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: VyralColors.error, width: 1.5),
          ),
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        ),
      ),
    );
  }
}
