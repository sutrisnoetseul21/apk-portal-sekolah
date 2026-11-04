import 'package:flutter/material.dart';

/// Reusable status badge untuk Ijin Kehadiran Siswa
class IjinStatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const IjinStatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color dotColor;
    IconData icon;

    switch (status) {
      case 'approved':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF047857);
        dotColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFB91C1C);
        dotColor = const Color(0xFFEF4444);
        icon = Icons.cancel_rounded;
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFB45309);
        dotColor = const Color(0xFFF59E0B);
        icon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dotColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: dotColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

