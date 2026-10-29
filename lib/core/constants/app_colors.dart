import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Palet Warna Baku Material 3 Aplikasi
class AppColors {
  // Warna Primer Dinamis (Sesuai Injeksi Sekolah)
  static const Color primary = Color(AppConfig.primaryColorHex);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);

  // Status Presensi
  static const Color hadir = Color(0xFF16A34A);     // Hijau
  static const Color terlambat = Color(0xFFD97706); // Kuning / Amber
  static const Color sakit = Color(0xFF0284C7);     // Biru Muda
  static const Color izin = Color(0xFF7C3AED);      // Ungu
  static const Color alpa = Color(0xFFDC2626);      // Merah

  // Netral & Background
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
}

