import 'package:flutter/material.dart';

class AppColors {
  // ─── Cyberpunk Deep Space Canvas ─────────────────────────────────────────
  static const Color background = Color(0xFF040508);
  static const Color surface = Color(0xFF0A0C13);
  static const Color surfaceCard = Color(0xFF11141E);
  static const Color surfaceElevated = Color(0xFF181C2B);
  static const Color surfaceGlass = Color(0xCC11141E);
  static const Color surfaceGlassLight = Color(0x991E2336);

  // ─── High-Voltage Neon Accents ──────────────────────────────────────────
  static const Color neonEmerald = Color(0xFF00FFA3);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color cyberViolet = Color(0xFF8C7CFF);
  static const Color electricPurple = Color(0xFFB026FF);
  static const Color neonCrimson = Color(0xFFFF2A6D);
  static const Color electricAmber = Color(0xFFFFB703);
  static const Color hotPink = Color(0xFFFF007F);

  // ─── Metallic & Specular Highlights ─────────────────────────────────────
  static const Color metallicGold = Color(0xFFFFD166);
  static const Color metallicSilver = Color(0xFFE2E8F0);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBorderSubtle = Color(0x1AFFFFFF);
  static const Color glassBorderGlow = Color(0x4D8C7CFF);
  static const Color glassBorderEmerald = Color(0x4D00FFA3);
  static const Color glassBorderCyan = Color(0x4D00F0FF);

  // ─── Text Colors ────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textGlow = Color(0xFFE0E7FF);

  // ─── Dividers & Overlays ────────────────────────────────────────────────
  static const Color divider = Color(0x1FFFFFFF);
  static const Color overlayDark = Color(0xB3040508);

  // ─── Holographic & Cyber Gradients ──────────────────────────────────────
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [neonEmerald, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiMagicGradient = LinearGradient(
    colors: [cyberViolet, electricPurple, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient crimsonGlowGradient = LinearGradient(
    colors: [neonCrimson, Color(0xFFFF5E7E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldVaultGradient = LinearGradient(
    colors: [metallicGold, electricAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [
      Color(0x33202638),
      Color(0x1A141824),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient auraGlowViolet = RadialGradient(
    colors: [
      Color(0x4D8C7CFF),
      Color(0x008C7CFF),
    ],
    radius: 0.85,
  );

  static const RadialGradient auraGlowEmerald = RadialGradient(
    colors: [
      Color(0x4D00FFA3),
      Color(0x0000FFA3),
    ],
    radius: 0.85,
  );
}
