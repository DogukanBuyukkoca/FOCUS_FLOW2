import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFFF6B6B);
  static const Color secondaryColor = Color(0xFF4ECDC4);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkSurface = Color(0xFF242424);
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  // Success & Error Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE91E63);
  static const Color warningColor = Color(0xFFFFA726);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  
  // Border Radius
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;
  
  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 120);
  static const Duration animBase = Duration(milliseconds: 200);
  static const Duration animSlow = Duration(milliseconds: 320);
  
  // Text Styles
  static TextStyle _interTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightSurface,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkBackground,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: lightBackground,
      foregroundColor: darkBackground,
      centerTitle: true,
      titleTextStyle: _interTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkBackground,
      ),
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: _interTextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkBackground,
        height: 1.2,
      ),
      displayMedium: _interTextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkBackground,
        height: 1.2,
      ),
      displaySmall: _interTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkBackground,
        height: 1.3,
      ),
      headlineLarge: _interTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkBackground,
        height: 1.3,
      ),
      headlineMedium: _interTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkBackground,
        height: 1.3,
      ),
      headlineSmall: _interTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkBackground,
        height: 1.4,
      ),
      bodyLarge: _interTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkBackground,
        height: 1.5,
      ),
      bodyMedium: _interTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkBackground,
        height: 1.5,
      ),
      bodySmall: _interTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: darkBackground.withOpacity(0.7),
        height: 1.5,
      ),
      labelLarge: _interTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkBackground,
        letterSpacing: 0.5,
      ),
      labelMedium: _interTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkBackground,
        letterSpacing: 0.5,
      ),
      labelSmall: _interTextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: darkBackground.withOpacity(0.7),
        letterSpacing: 0.5,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
        textStyle: _interTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius16),
      ),
      margin: const EdgeInsets.all(spacing8),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: darkBackground,
      size: 24,
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkBackground.withOpacity(0.5),
      selectedLabelStyle: _interTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      unselectedLabelStyle: _interTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: darkBackground.withOpacity(0.5),
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
  
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurface,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: darkBackground,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: _interTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: _interTextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      displayMedium: _interTextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      displaySmall: _interTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.3,
      ),
      headlineLarge: _interTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.3,
      ),
      headlineMedium: _interTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.3,
      ),
      headlineSmall: _interTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.4,
      ),
      bodyLarge: _interTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white,
        height: 1.5,
      ),
      bodyMedium: _interTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white,
        height: 1.5,
      ),
      bodySmall: _interTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.white.withOpacity(0.7),
        height: 1.5,
      ),
      labelLarge: _interTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      labelMedium: _interTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      labelSmall: _interTextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.7),
        letterSpacing: 0.5,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
        textStyle: _interTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius16),
      ),
      margin: const EdgeInsets.all(spacing8),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.white.withOpacity(0.5),
      selectedLabelStyle: _interTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      unselectedLabelStyle: _interTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.white.withOpacity(0.5),
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}