import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension TypographyExtension on BuildContext {
  TextTheme get typography => Theme.of(this).textTheme;
}

class AppTextStyles {
  /// Plus Jakarta Sans font with responsive sizing
  /// Usage: AppTextStyles.jakarta(fontSize: 16, fontWeight: FontWeight.bold)
  static TextStyle jakarta({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration ?? TextDecoration.none,
    );
  }

  // Pre-defined text styles using Jakarta Sans

  // Display Styles
  static TextStyle displayLarge({Color? color}) => jakarta(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.2,
      );

  static TextStyle displayMedium({Color? color}) => jakarta(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.2,
      );

  static TextStyle displaySmall({Color? color}) => jakarta(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.2,
      );

  // Headline Styles
  static TextStyle headlineMedium({Color? color}) => jakarta(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle headlineSmall({Color? color}) => jakarta(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  // Title Styles
  static TextStyle titleLarge({Color? color}) => jakarta(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle titleMedium({Color? color}) => jakarta(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle titleSmall({Color? color}) => jakarta(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  // Body Styles
  static TextStyle bodyLarge({Color? color}) => jakarta(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color}) => jakarta(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.5,
      );

  static TextStyle bodySmall({Color? color}) => jakarta(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.5,
      );

  // Label Styles
  static TextStyle labelLarge({Color? color}) => jakarta(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle labelMedium({Color? color}) => jakarta(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle labelSmall({Color? color}) => jakarta(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  // Special Styles
  static TextStyle buttonText({Color? color}) => jakarta(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  static TextStyle appBarTitle({Color? color}) => jakarta(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle caption({Color? color}) => jakarta(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.4,
      );

  static TextStyle overline({Color? color}) => jakarta(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.5,
        height: 1.6,
      );

  // Price Styles
  static TextStyle priceText({Color? color}) => jakarta(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle priceLarge({Color? color}) => jakarta(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      );
}
