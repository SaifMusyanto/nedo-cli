import 'package:flutter/material.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    // --- Success ---
    this.success,
    this.onSuccess,
    this.successContainer,
    this.onSuccessContainer,
    // --- Danger ---
    this.danger,
    this.onDanger,
    this.dangerContainer,
    this.onDangerContainer,
    // --- Warning ---
    this.warning,
    this.onWarning,
    this.warningContainer,
    this.onWarningContainer,
    // --- Info ---
    this.info,
    this.onInfo,
    this.infoContainer,
    this.onInfoContainer,
    this.formBackground,
    this.formBorder,
    this.formIcon,
    this.formIconLighter,
  });

  // --- Success ---
  /// The main color for success states (e.g., success buttons, icons).
  final Color? success;

  /// A color that has good contrast on [success] color (e.g., for text/icons).
  final Color? onSuccess;

  /// A container color for success states (e.g., backgrounds of success banners).
  final Color? successContainer;

  /// A color that has good contrast on [successContainer] color.
  final Color? onSuccessContainer;

  // --- Danger ---
  /// The main color for danger states that are not form validation errors.
  /// For form validation, prefer using `Theme.of(context).colorScheme.error`.
  final Color? danger;

  /// A color that has good contrast on [danger] color.
  final Color? onDanger;

  /// A container color for danger states for backgrounds.
  final Color? dangerContainer;

  /// A color that has good contrast on [dangerContainer] color.
  final Color? onDangerContainer;

  // --- Warning ---
  /// The main color for warning states.
  final Color? warning;

  /// A color that has good contrast on [warning] color.
  final Color? onWarning;

  /// A container color for warning states for backgrounds.
  final Color? warningContainer;

  /// A color that has good contrast on [warningContainer] color.
  final Color? onWarningContainer;

  // --- Info ---
  /// The main color for informational states.
  final Color? info;

  /// A color that has good contrast on [info] color.
  final Color? onInfo;

  /// A container color for informational states for backgrounds.
  final Color? infoContainer;

  /// A color that has good contrast on [infoContainer] color.
  final Color? onInfoContainer;

  final Color? formBackground;
  final Color? formBorder;
  final Color? formIcon;
  final Color? formIconLighter;

  /// Creates a copy of this object but with the given fields replaced with the new values.
  @override
  CustomColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? danger,
    Color? onDanger,
    Color? dangerContainer,
    Color? onDangerContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? formBackground,
    Color? formBorder,
    Color? formIcon,
    Color? formIconLighter,
  }) {
    return CustomColors(
      formIcon: formIcon ?? this.formIcon,
      formBorder: formBorder ?? this.formBorder,
      formBackground: formBackground ?? this.formBackground,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      onDangerContainer: onDangerContainer ?? this.onDangerContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      formIconLighter: formIconLighter ?? this.formIconLighter,
    );
  }

  /// Linearly interpolates from another [CustomColors] to `this`.
  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      formIcon: Color.lerp(formIcon, other.formIcon, t),
      formBorder: Color.lerp(formBorder, other.formBorder, t),
      formBackground: Color.lerp(formBackground, other.formBackground, t),
      success: Color.lerp(success, other.success, t),
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t),
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      ),
      danger: Color.lerp(danger, other.danger, t),
      onDanger: Color.lerp(onDanger, other.onDanger, t),
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t),
      onDangerContainer: Color.lerp(
        onDangerContainer,
        other.onDangerContainer,
        t,
      ),
      warning: Color.lerp(warning, other.warning, t),
      onWarning: Color.lerp(onWarning, other.onWarning, t),
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t),
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      ),
      info: Color.lerp(info, other.info, t),
      onInfo: Color.lerp(onInfo, other.onInfo, t),
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t),
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t),
    );
  }
}
