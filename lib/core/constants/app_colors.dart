import 'package:flutter/cupertino.dart';

class AppColors {
  // ================= BRAND (Your Core Blues) =================

  /// Primary – Main Brand Blue
  /// Use: AppBar, Primary buttons, Icons
  static const Color primary = Color(0xFF2667FF); // Strong Royal Blue

  /// Secondary – Accent / CTA
  /// Use: Highlights, FAB, Active states
  static const Color secondary = Color(0xFF2176FF); // Action Blue

  /// Tertiary – Soft Accent
  /// Use: Chips, secondary buttons
  static const Color tertiary = Color(0xFF3F8EFC); // Sky Blue

  /// Deep Brand – Authority / Headers
  /// Use: Splash top, Headers, Dark sections
  static const Color brandDark = Color(0xFF3B28CC); // Deep Indigo Blue

  /// Light Brand – Background accents
  static const Color brandLight = Color(0xFF5465FF); // Soft Periwinkle Blue

  // ================= NEUTRAL =================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color background = Color(0xFFF6F8FF);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // ================= GRADIENTS (🔥 BEST PART) =================

  /// Main Brand Gradient (Splash / Auth / Headers)
  static const LinearGradient blueBrandGradient = LinearGradient(
    colors: [
      Color(0xFF3B28CC), // Deep start
      Color(0xFF2667FF), // Core brand
      Color(0xFF3F8EFC), // Sky finish
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Horizontal CTA Gradient (Buttons / Cards)
  static const LinearGradient blueActionGradient = LinearGradient(
    colors: [
      Color(0xFF2176FF),
      Color(0xFF5465FF),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Soft Background Gradient
  static const LinearGradient blueSoftGradient = LinearGradient(
    colors: [
      Color(0xFFF1F4FF),
      Color(0xFFE6ECFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ================= FEEDBACK =================

  static const Color success = Color(0xFF1ABC30);
  static const Color warning = Color(0xFFFACC15);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3F8EFC);

  // ================= OPACITY HELPERS =================

  static Color primaryOpacity(double o) => primary.withOpacity(o);
  static Color secondaryOpacity(double o) => secondary.withOpacity(o);
  static Color blackOpacity(double o) => black.withOpacity(o);
}
