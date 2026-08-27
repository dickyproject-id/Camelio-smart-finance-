import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Mintro vibe - Violet/Purple & Warm Orange)
  static const Color primary = Color(0xFF7B61FF); // Deep Violet
  static const Color secondary = Color(0xFFFF9B70); // Warm Orange/Peach
  static const Color accent = Color(0xFF9D84FF); // Light Purple Highlight

  // Light Mode Colors
  static const Color lightBackground = Color(
    0xFFF8F9FE,
  ); // Very light greyish blue
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1A1A2C); // Dark Blueish Black
  static const Color lightTextSecondary = Color(0xFF8E8E9F);

  // Dark Mode Colors
  static const Color darkBackground = Color(
    0xFF14141F,
  ); // Deep almost-black purple
  static const Color darkSurface = Color(0xFF1F1F30);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFA0A0B2);

  // Semantic Colors
  static const Color success = Color(0xFF00C48C);
  static const Color error = Color(0xFFFF647C);

  // Gradients for glassmorphism and stunning buttons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7B61FF), Color(0xFF9D84FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF9B70), Color(0xFFFFC085)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
