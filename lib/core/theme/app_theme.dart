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
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.4),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: AppColors.ink, width: 1),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.4),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.gold,
            textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.beige,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.ink.withOpacity(0.14)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.gold, width: 1.5),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.error, width: 1.5),
          ),
          labelStyle: GoogleFonts.dmSans(color: AppColors.muted),
          hintStyle: GoogleFonts.dmSans(color: AppColors.muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        cardTheme: const CardTheme(
          color: AppColors.beige,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.beige, thickness: 1),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          contentTextStyle: GoogleFonts.dmSans(color: AppColors.white, fontSize: 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        chipTheme: ChipThemeData(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: AppColors.beige,
          selectedColor: AppColors.gold,
          labelStyle: GoogleFonts.dmSans(fontSize: 13),
          side: BorderSide(color: AppColors.ink.withOpacity(0.2)),
        ),
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
