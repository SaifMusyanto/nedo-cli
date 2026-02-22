import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/custom_colors.dart';


extension MediaQueryContextExtension on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
}

extension LocalizationExtension on BuildContext {
  AppLocalizations? get appLocalizations => AppLocalizations.of(this);
}

extension ThemeContextExtension on BuildContext {
  /// Provides convenient access to the app's `ThemeData`.
  ///
  /// Equivalent to `Theme.of(this)`.
  ThemeData get theme => Theme.of(this);

  /// Provides convenient access to the app's `ColorScheme`.
  ///
  /// Equivalent to `Theme.of(this).colorScheme`.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Provides convenient access to the app's `TextTheme`.
  ///
  /// Equivalent to `Theme.of(this).textTheme`.
  TextTheme get textTheme => theme.textTheme;

  /// Provides convenient, non-nullable access to the custom `CustomColors`
  /// theme extension.
  ///
  /// The `!` operator is used safely here, as we have ensured that the
  /// `CustomColors` extension is always attached to our app's themes
  /// in `app_theme.dart`.
  CustomColors get customColors => theme.extension<CustomColors>()!;
}

/// An extension on [num] to create vertical and horizontal spacing widgets.
extension SpacingExtension on num {
  /// Converts a numeric value to a vertical [SizedBox] with height equal to the value.
  Widget get vertical => SizedBox(height: toDouble());

  /// Converts a numeric value to a horizontal [SizedBox] with width equal to the value.
  Widget get horizontal => SizedBox(width: toDouble());
}