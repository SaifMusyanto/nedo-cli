import 'package:flutter/material.dart';
import '../../../config/constants/app_colors.dart';
import '../../../utils/extensions/extensions.dart';

class BaseTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const BaseTitle({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: AppColors.orange, size: 20),
        ),
        const SizedBox(width: 12),
        if (subtitle == null) ...[
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ] else ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle!,
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
