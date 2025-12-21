import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1E293B); // Dark Slate Blue
  static const Color secondary = Color(0xFF10B981); // Emerald Green
  
  // Variations
  static const Color primaryLight = Color(0xFF334155);
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Main BG
  static const Color surface = Colors.white; // Card BG
  static const Color surfaceAlt = Color(0xFFF1F5F9); 

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Very dark slate (Headings)
  static const Color textSecondary = Color(0xFF64748B); // Slate Gray (Body)
  static const Color textLight = Color(0xFF94A3B8); // Lighter gray

  // Status / Functional
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  
  // Charts
  static const Color chartBlue = Color(0xFF1E3A8A);
  static const Color chartTeal = Color(0xFF14B8A6);
  static const Color chartLightBlue = Color(0xFF60A5FA);
  static const Color chartOrange = Color(0xFFF97316);
  
  // Legacy/Compatibility
  static const Color accent = Color(0xFFF97316); // Mapped to Orange for consistency
}
