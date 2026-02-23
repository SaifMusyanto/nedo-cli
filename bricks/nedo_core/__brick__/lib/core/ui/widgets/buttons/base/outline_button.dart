import 'package:flutter/material.dart';
import '../../../../config/theme/app_styles.dart';

class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const OutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    final button = SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor:
              textColor ?? theme.colorScheme.onSurface.withAlpha(200),
          disabledForegroundColor: theme.colorScheme.onSurface.withAlpha(100),
          side: BorderSide(
            color: textColor ?? theme.colorScheme.onSurface.withAlpha(200),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? theme.colorScheme.onSurface.withAlpha(200),
                  ),
                ),
              )
            : Text(
                label,
                style: AppStyles.textTheme.titleMedium?.copyWith(
                  color:
                      textColor ?? theme.colorScheme.onSurface.withAlpha(200),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
