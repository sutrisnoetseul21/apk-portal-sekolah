import 'package:flutter/material.dart';

class SholatBulkModalHeader extends StatelessWidget {
  final String selectedClassName;
  final VoidCallback onClose;

  static const Color _emeraldPrimary = Color(0xFF059669);
  static const Color _tealDark = Color(0xFF0F766E);

  const SholatBulkModalHeader({
    super.key,
    required this.selectedClassName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_emeraldPrimary, _tealDark],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.playlist_add_check_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Input Presensi Sholat Dhuhur (1 Kelas)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Kelas $selectedClassName • Pencatatan Ibadah Berjamaah',
                  style: const TextStyle(
                    color: Color(0xFFD1FAE5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
