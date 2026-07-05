import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const ink = Color(0xFF221C15);
  static const gold = Color(0xFFC2A14E);
  static const ivory = Color(0xFFFBF8F1);
  static const beige = Color(0xFFF0E8D8);
  static const copper = Color(0xFF8B5E3C);
  static const muted = Color(0x8D221C15);
  static const white = Color(0xFFFFFFFF);
  static const error = Color(0xFFD32F2F);
  static const success = Color(0xFF388E3C);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.ivory,
        colorScheme: ColorScheme.light(
          primary: AppColors.gold,
          onPrimary: AppColors.white,
          secondary: AppColors.copper,
          onSecondary: AppColors.white,
          surface: AppColors.ivory,
          onSurface: AppColors.ink,
          error: AppColors.error,
        ),
        textTheme: _textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.ivory,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: AppColors.gold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.beige,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gold),
          ),
          labelStyle: GoogleFonts.dmSans(color: AppColors.muted),
          hintStyle: GoogleFonts.dmSans(color: AppColors.muted),
        ),
        cardTheme: CardTheme(
          color: AppColors.beige,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.beige, thickness: 1),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.ivory,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.muted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );

  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.ink),
        displayMedium: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.ink),
        displaySmall: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.ink),
        headlineMedium: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
        headlineSmall: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink),
        titleLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
        titleMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
        bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: AppColors.ink),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: AppColors.ink),
        bodySmall: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted),
        labelLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
      );
}
