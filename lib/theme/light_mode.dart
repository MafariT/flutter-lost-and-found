import 'package:flutter/material.dart';

const Color brandYellow = Color(0xFFFFBB5C);
const Color brandOrange = Color(0xFFFF9B50);
const Color brandPrimary = Color(0xFFE25E3E);
const Color brandDanger = Color(0xFFC63D2F);

const Color backgroundWhite = Color(0xFFFAFAFA);
const Color surfaceWhite = Color(0xFFFFFFFF);
const Color textPrimary = Color(0xFF2D2D2D);
const Color textSecondary = Color(0xFF757575);

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: backgroundWhite,
  fontFamily: 'Poppins',

  colorScheme: const ColorScheme.light(
    surface: surfaceWhite,
    primary: brandPrimary,
    secondary: brandOrange,
    tertiary: brandYellow,
    error: brandDanger,
    inversePrimary: textPrimary,
    onSurface: textPrimary,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: backgroundWhite,
    elevation: 0,
    iconTheme: IconThemeData(color: textPrimary),
    titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
    centerTitle: true,
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: brandPrimary, width: 1.5),
    ),
    labelStyle: const TextStyle(color: textSecondary),
    hintStyle: TextStyle(color: Colors.grey.shade400),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: brandPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    ),
  ),
);
