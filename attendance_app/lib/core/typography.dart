import 'package:flutter/material.dart';

class AppTextStyles {
  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.25,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );
}

class AppText {
  // Headline widgets
  static Widget headlineLarge(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.headlineLarge.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  static Widget headlineMedium(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.headlineMedium.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  static Widget headlineSmall(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.headlineSmall.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  // Title widgets
  static Widget titleLarge(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.titleLarge.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  static Widget titleMedium(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.titleMedium.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  static Widget titleSmall(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.titleSmall.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  // Body widgets
  static Widget bodyLarge(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.bodyLarge.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  static Widget bodyMedium(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  static Widget bodySmall(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  // Label widgets
  static Widget labelLarge(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  static Widget labelMedium(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  static Widget labelSmall(String text, {Color? color, TextAlign? textAlign}) {
    return Text(
      text,
      style: AppTextStyles.labelSmall.copyWith(color: color),
      textAlign: textAlign,
    );
  }
}

// Extension for easy text styling
extension TextStyleExtension on TextStyle {
  TextStyle withColor(Color color) {
    return copyWith(color: color);
  }

  TextStyle withSize(double size) {
    return copyWith(fontSize: size);
  }

  TextStyle withWeight(FontWeight weight) {
    return copyWith(fontWeight: weight);
  }

  TextStyle withHeight(double height) {
    return copyWith(height: height);
  }

  TextStyle withDecoration(TextDecoration decoration) {
    return copyWith(decoration: decoration);
  }
}