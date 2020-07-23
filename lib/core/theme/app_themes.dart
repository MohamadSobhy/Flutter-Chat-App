import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTheme {
  dark,
  light,
}

final appThemes = {
  AppTheme.dark: ThemeData(
    primaryColor: Colors.deepOrange,
    accentColor: Colors.deepOrange,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.aBeeZee().fontFamily,
  ),
  AppTheme.light: ThemeData(
    primaryColor: Colors.deepOrange,
    splashColor: Color(0xDDFDEDF3),
    accentColor: Colors.deepOrange,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.aBeeZee().fontFamily,
  ),
};
