import 'app_styles.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_colors.dart';

/// Centralized theme class for the application.
///
/// This class consumes the static palette from `AppColors` and maps it
/// to the dynamic `ThemeData` for both light and dark modes. It correctly
/// populates the standard `ColorScheme` and the app-specific `CustomColors`
/// theme extension.
class AppTheme {
  // Private constructor to prevent instantiation.
  AppTheme._();

  /// The primary seed color derived from the brand palette.
  static const _seedColor = AppColors.primary50;

  /// Light theme custom color palette.
  static const _lightCustomColors = CustomColors(
    success: AppColors.success50,
    onSuccess: AppColors.white,
    successContainer: AppColors.success10,
    onSuccessContainer: AppColors.success90,
    danger: AppColors.danger50,
    onDanger: AppColors.white,
    dangerContainer: AppColors.danger10,
    onDangerContainer: AppColors.danger90,
    infoContainer: AppColors.info10,
    onInfoContainer: AppColors.grey70,
    formBackground: AppColors.neutral30,
    formBorder: AppColors.secondary10,
    formIcon: AppColors.grey50,
    formIconLighter: AppColors.grey90,
  );

  /// --- Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.neutral30,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary50,
      onPrimary: AppColors.white,
      surface: AppColors.grey05,
      onSurface: AppColors.text50,
      error: AppColors.danger50,
      onError: AppColors.white,
      outline: AppColors.grey10,
      outlineVariant: AppColors.grey100,
      secondary: AppColors.secondary50,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      _lightCustomColors,
    ],
    iconTheme: IconThemeData(
      color: AppColors.grey50
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.grey05,
      foregroundColor: AppColors.text50,
      scrolledUnderElevation: 0,
    ),
    dividerColor: AppColors.grey100,
    dividerTheme: DividerThemeData(
      color: AppColors.grey100,
      thickness: 2,
    ),
    textTheme: AppStyles.textTheme.apply(
      bodyColor: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light).onSurface,
      displayColor: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light).onSurface,
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: AppStyles.textTheme.titleMedium,
      unselectedLabelStyle: AppStyles.textTheme.titleMedium,
      labelColor: AppColors.text50,
      unselectedLabelColor: AppColors.text50,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.white,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme:  WidgetStateProperty<IconThemeData>.fromMap(
        {
          WidgetState.selected: IconThemeData(
            color: AppColors.primary50,
            size: 20
          ),
          WidgetState.focused: IconThemeData(
            color: AppColors.primary50,
            size: 20
          ),
          WidgetState.any: IconThemeData(
            color: AppColors.grey30,
            size: 20
          )
        },
      ),
      labelTextStyle: WidgetStateProperty<TextStyle>.fromMap(
          {
            WidgetState.selected: AppStyles.textTheme.titleMedium!,
            WidgetState.focused: AppStyles.textTheme.titleMedium!,
            WidgetState.any: AppStyles.textTheme.titleMedium!.copyWith(
              color: AppColors.grey30,
              fontWeight: FontWeight.w500,
            ),
          },
      ),
    )
  );
}