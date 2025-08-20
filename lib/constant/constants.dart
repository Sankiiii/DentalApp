import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF1E5F9B);
const Color kBackgroundColor = Colors.white;
const Color kTextColor = Colors.black;
const double kBorderRadius = 14.0;

class AppConstants {
  // Colors
  static const Color primaryBlue = kPrimaryColor;
  static const Color lightBlue = Color(0xFFB3D9FF);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFE6F3FF);
  static const Color whiteColor = kBackgroundColor;
  static const Color greyColor = Color(0xFF666666);
  static const Color lightGreyColor = Color(0xFFE0E0E0);
  static const Color darkGreyColor = kTextColor;
  
  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: kTextColor,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: greyColor,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: whiteColor,
  );
  
  static const TextStyle cardValueStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: whiteColor,
  );
  
  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Border Radius
  static const double defaultRadius = kBorderRadius;
  static const double buttonRadius = kBorderRadius;
  
  // Sizes
  static const double buttonHeight = 50.0;
  static const double cardHeight = 45.0;
}