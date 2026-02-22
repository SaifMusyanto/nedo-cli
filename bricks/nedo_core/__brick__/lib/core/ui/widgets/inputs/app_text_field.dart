import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../config/constants/app_colors.dart';
import '../../../config/theme/app_styles.dart';
import '../../../utils/extensions/extensions.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppStyles.textTheme.bodyMedium?.copyWith(
              color: context.customColors.info,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: context.customColors.danger),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          cursorColor: AppColors.white,
          obscureText: isPassword ? obscureText : false,
          style: AppStyles.textTheme.bodyMedium?.copyWith(
            color: context.customColors.info,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.customColors.formBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.customColors.formBorder!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.customColors.formBorder!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Iconsax.eye_slash : Iconsax.eye,
                      color: context.customColors.formIcon,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
