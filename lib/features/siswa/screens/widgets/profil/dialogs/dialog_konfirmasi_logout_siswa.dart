import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog konfirmasi keluar / logout akun portal siswa
class DialogKonfirmasiLogoutSiswa extends StatelessWidget {
  const DialogKonfirmasiLogoutSiswa({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => const DialogKonfirmasiLogoutSiswa(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFE11D48),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Keluar dari Akun?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      content: Text(
        'Apakah Anda yakin ingin keluar dari akun portal siswa? Anda perlu login kembali untuk mengakses data.',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: const Color(0xFF64748B),
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Batal',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Ya, Keluar',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
