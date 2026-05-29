import 'package:flutter/material.dart';

class AppColors {
  final BuildContext _context;
  AppColors(this._context);

  bool get _isDark => Theme.of(_context).brightness == Brightness.dark;

  static const Color primary = Color(0xFF2cafff);
  static const Color accent = Color(0xFF2cafff);
  static const Color error = Colors.red;
  static const Color warning = Colors.amber;
  static const Color success = Colors.green;

  static const Color scaffoldLight = Color(0xFFF5F8FA);
  static const Color scaffoldDark = Color(0xFF15202B);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF15202B);

  Color get scaffoldBackground => _isDark ? scaffoldDark : scaffoldLight;
  Color get appBarBackground => _isDark ? surfaceDark : surfaceLight;
  Color get appBarForeground => _isDark ? Colors.white : Colors.black87;
  Color get cardBackground => _isDark ? const Color(0xFF192734) : Colors.white;
  Color get surfaceBackground => _isDark ? const Color(0xFF192734) : Colors.white;
  Color get divider => _isDark ? Colors.white10 : Colors.black12;
  
  Color get textPrimary => _isDark ? Colors.white : Colors.black87;
  Color get textSecondary => _isDark ? Colors.white70 : Colors.black54;
  Color get textTertiary => _isDark ? Colors.white38 : Colors.black38;
  Color get textDimmed => _isDark ? Colors.white60 : Colors.black54;

  Color get chipBackground => _isDark ? Colors.white10 : const Color(0xFFF0F3F6);
  Color get iconSecondary => _isDark ? Colors.white54 : Colors.black45;
  
  Color get bottomNavBackground => _isDark ? const Color(0xFF15202B) : Colors.white;
  Color get bottomNavUnselected => _isDark ? Colors.white60 : Colors.black54;

  Color get dialogBackground => _isDark ? const Color(0xFF15202B) : Colors.white;

  // Specifics
  Color get likeColor => Colors.red;
  Color get unlikeColor => Colors.white;
  
  static AppColors of(BuildContext context) => AppColors(context);
}
