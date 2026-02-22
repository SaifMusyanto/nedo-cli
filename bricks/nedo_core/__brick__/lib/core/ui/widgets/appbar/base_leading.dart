import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../config/constants/app_colors.dart';

class BaseLeading extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const BaseLeading({
    super.key,
    required this.onTap,
    this.icon = Iconsax.arrow_left_2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 0, 8),
        decoration: BoxDecoration(
          color: AppColors.black40,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.black30, width: 1),
        ),
        child: Icon(icon, color: AppColors.text50, size: 20),
      ),
    );
  }
}
