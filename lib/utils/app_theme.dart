import 'package:flutter/material.dart';

/// Centralized theme constants for the SalonEase app.
/// Use these instead of hardcoding colors throughout the app.
class AppTheme {
  AppTheme._();

  // ── Primary Colors ──
  static const Color primaryColor = Color(0xff721c80);
  static const Color primaryLight = Color(0xFFC467A9); // Color.fromARGB(255, 196, 103, 169)
  static const Color primaryDark = Color(0xFF5A1566);

  // ── Accent / Secondary ──
  static const Color accentPink = Colors.pink;
  static const Color accentAmber = Colors.amber;

  // ── Neutrals ──
  static const Color textDark = Color(0xff2d2a2a);
  static const Color textGrey = Colors.grey;
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color white = Colors.white;
  static const Color dividerColor = Color.fromARGB(255, 220, 218, 218);

  // ── Status Colors ──
  static const Color statusPending = Colors.orange;
  static const Color statusConfirmed = Colors.green;
  static const Color statusCompleted = Colors.teal;
  static const Color statusCancelled = Colors.red;

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Text Styles ──
  static const TextStyle headingLarge = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 32,
  );

  static const TextStyle headingMedium = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  static const TextStyle headingSmall = TextStyle(
    color: textDark,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static const TextStyle bodyText = TextStyle(
    color: textDark,
    fontSize: 14,
  );

  static const TextStyle bodyTextGrey = TextStyle(
    color: textGrey,
    fontSize: 14,
  );

  static const TextStyle buttonText = TextStyle(
    color: white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle whiteTitle = TextStyle(
    color: white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // ── Decorations ──
  static BoxDecoration gradientDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: primaryGradient,
      borderRadius: borderRadius,
    );
  }

  static BoxDecoration cardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // ── Theme Data ──
  static ThemeData get themeData => ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
      );

  // ── Helper: status color ──
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return statusConfirmed;
      case 'completed':
        return statusCompleted;
      case 'cancelled':
      case 'canceled':
        return statusCancelled;
      case 'pending':
      default:
        return statusPending;
    }
  }

  // ── Helper: network image with error fallback ──
  static Widget networkImage({
    required String? url,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    IconData fallbackIcon = Icons.image_outlined,
    double fallbackIconSize = 40,
    BorderRadius? borderRadius,
  }) {
    Widget image;
    if (url == null || url.isEmpty) {
      image = Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        child: Icon(fallbackIcon, size: fallbackIconSize, color: Colors.grey),
      );
    } else {
      image = Image.network(
        url,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: Icon(fallbackIcon, size: fallbackIconSize, color: Colors.grey),
        ),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            ),
          );
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: image);
    }
    return image;
  }
}
