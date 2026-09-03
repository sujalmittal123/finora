import 'package:flutter/material.dart';

class AppColors {
  // ─── Core Backgrounds & Surfaces (Obsidian Void) ───────────────────────────
  static const Color background = Color(0xFF08090E);
  static const Color surface = Color(0xFF11141E);
  static const Color surfaceElevated = Color(0xFF181C2B);
  static const Color surfaceCard = Color(0xFF1E2336);
  static const Color surfaceHover = Color(0xFF272E44);

  // ─── Glass & Borders ────────────────────────────────────────────────────────
  static const Color glassBorder = Color(0x1FFFFFFF); // 12% white
  static const Color glassBorderSubtle = Color(0x0DFFFFFF); // 5% white
  static const Color glassFill = Color(0x0AFFFFFF); // 4% white
  static const Color divider = Color(0xFF1F2437);

  // ─── Gen-Z High-Contrast Neon Accents ───────────────────────────────────────
  static const Color neonEmerald = Color(0xFF00FFA3); // Safe to spend / Income / Growth
  static const Color emeraldDark = Color(0xFF00A86B);
  static const Color cyberViolet = Color(0xFF8C7CFF); // AI Assistant / Insights / Magic
  static const Color violetDark = Color(0xFF5A4AE3);
  static const Color neonCrimson = Color(0xFFFF4D6D); // Expense / Burn / Alert
  static const Color crimsonDark = Color(0xFFD61C4E);
  static const Color electricAmber = Color(0xFFFFB703); // Subscriptions due / Warnings
  static const Color neonCyan = Color(0xFF00E5FF); // Vaults / Savings

  // ─── Semantic Aliases ───────────────────────────────────────────────────────
  static const Color primary = neonEmerald;
  static const Color primaryDark = emeraldDark;
  static const Color secondary = cyberViolet;
  static const Color expense = neonCrimson;
  static const Color income = neonEmerald;
  static const Color warning = electricAmber;

  // ─── Text Colors ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9EA3B5);
  static const Color textMuted = Color(0xFF636A84);
  static const Color textDisabled = Color(0xFF3F465F);

  // ─── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient welcomeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF050608),
      Color(0xFF0C0E14),
      Color(0xFF160914),
      Color(0xFF240A18),
      Color(0xFF3A0D22),
    ],
    stops: [0.0, 0.35, 0.65, 0.85, 1.0],
  );

  static const LinearGradient emeraldGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00FFA3),
      Color(0xFF00B377),
    ],
  );

  static const LinearGradient aiMagicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8C7CFF),
      Color(0xFF5A4AE3),
      Color(0xFF00FFA3),
    ],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E2336),
      Color(0xFF141724),
    ],
  );
}
