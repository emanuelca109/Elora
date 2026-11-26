import 'package:flutter/material.dart';

class AppTheme {
  // Brand Palette - Luxury Perfumery (Elora)
  static const Color primaryGold = Color(0xFFC5A059);
  static const Color darkGold = Color(0xFF996515);
  static const Color deepBronze = Color(0xFF704A10);
  static const Color lightGold = Color(0xFFEADBBE);
  static const Color goldAccent = Color(0xFFD4AF37);

  static const Color backgroundLight = Color(0xFFFAF7F2);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color warmBorder = Color(0xFFECE3D4);

  static const Color textDark = Color(0xFF221A15);
  static const Color textMuted = Color(0xFF7B7269);
  static const Color textLight = Color(0xFFB5ADA4);

  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningOrange = Color(0xFFE65100);
  static const Color dangerRed = Color(0xFFC62828);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFC5A059), Color(0xFF996515)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGoldGradient = LinearGradient(
    colors: [Color(0xFFF9F4EB), Color(0xFFFAF7F2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF2C241E), Color(0xFF1E1813)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Currency Formatter: $ 450.000
  static String formatPrice(double amount) {
    final integerPart = amount.round().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      buffer.write(integerPart[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return '\$ ${buffer.toString().split('').reversed.join('')}';
  }

  // ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryGold,
        secondary: darkGold,
        surface: surfaceCard,
        error: dangerRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 2,
        shadowColor: primaryGold.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: warmBorder, width: 0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkGold,
          side: const BorderSide(color: primaryGold, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: warmBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: warmBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGold, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dangerRed),
        ),
        hintStyle: const TextStyle(color: textLight, fontSize: 14),
        prefixIconColor: primaryGold,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: darkGold,
        unselectedItemColor: textLight,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
