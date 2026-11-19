import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Palet utama Ungu - Biru
  static const Color primaryPurple = Color(0xFF6D28D9); // Ungu pekat
  static const Color primaryBlue = Color(0xFF2563EB); // Biru cerah
  static const Color accentViolet = Color(0xFF8B5CF6); // Ungu muda aksen
  static const Color softTint = Color(0xFFEDE9FE); // Latar badge/chip tipis

  // Latar & Teks
  static const Color background = Color(0xFFF5F3FF); // Putih keunguan lembut
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E1B4B); // Indigo gelap
  static const Color textSecondary = Color(0xFF64748B); // Abu-abu kebiruan
  static const Color error = Color(0xFFE11D48); // Merah rose

  // Gradien utama untuk AppBar & aksen
  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryPurple, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
