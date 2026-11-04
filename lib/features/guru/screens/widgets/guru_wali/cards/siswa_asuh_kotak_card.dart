import 'package:flutter/material.dart';
import '../../../models/guru_wali_dashboard_model.dart';

/// Kartu Siswa Asuh Model Kotak (Grid 2 Kolom)
class SiswaAsuhKotakCard extends StatelessWidget {
  final SiswaAsuhModel siswa;
  final void Function(String studentId, String studentName) onBukaDetailPresensi;
  final VoidCallback onBukaCeritaTab;
  final ValueChanged<SiswaAsuhModel> onTambahJurnal;
  final ValueChanged<SiswaAsuhModel> onLihatRiwayat;

  const SiswaAsuhKotakCard({
    super.key,
    required this.siswa,
    required this.onBukaDetailPresensi,
    required this.onBukaCeritaTab,
    required this.onTambahJurnal,
    required this.onLihatRiwayat,
  });

  @override
  Widget build(BuildContext context) {
    final hasBimbingan = siswa.hasBimbingan;
    final ringColor =
        hasBimbingan ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar dengan Ring Status & Rombel
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar dengan Ring Status (Klik untuk Detail Presensi)
              GestureDetector(
                onTap: () =>
                    onBukaDetailPresensi(siswa.studentId, siswa.name),
                child: Tooltip(
                  message: 'Lihat Detail Presensi ${siswa.name}',
                  child: Stack(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ringColor, width: 2),
                        ),
                        child: ClipOval(
                          child: siswa.avatarUrl != null &&
                                  siswa.avatarUrl!.isNotEmpty
                              ? Image.network(
                                  siswa.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildAvatarFallback(siswa),
                                )
                              : _buildAvatarFallback(siswa),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: ringColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Rombel & Badge Cerita
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        siswa.kelasName,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    if (siswa.hasActiveKonsultasi) ...[
                      const SizedBox(height: 3),
                      GestureDetector(
                        onTap: onBukaCeritaTab,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            siswa.unreadKonsultasiCount > 0
                                ? '💬 ${siswa.unreadKonsultasiCount}'
                                : '💬 Cerita',
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Nama Siswa & NISN (Klik untuk Buka Detail Presensi Siswa)
          InkWell(
            onTap: () =>
                onBukaDetailPresensi(siswa.studentId, siswa.name),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          siswa.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'NISN: ${siswa.nisn}',
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Status Dampingan Bulan Ini
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: hasBimbingan
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasBimbingan
                    ? const Color(0xFFA7F3D0)
                    : const Color(0xFFFDE68A),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasBimbingan
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 11,
                      color: hasBimbingan
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hasBimbingan
                            ? 'Didampingi (${siswa.bimbinganCount}x)'
                            : 'Belum Dampingan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: hasBimbingan
                              ? const Color(0xFF065F46)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasBimbingan &&
                    siswa.lastBimbinganDateFormatted != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${siswa.lastBimbinganDateFormatted} • ${siswa.lastKategori ?? ""}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Spacer(),

          // Action Buttons: [+ Jurnal] & [Riwayat]
          Row(
            children: [
              Expanded(
                flex: 5,
                child: InkWell(
                  onTap: () => onTambahJurnal(siswa),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '+ Jurnal',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: () => onLihatRiwayat(siswa),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(SiswaAsuhModel siswa) {
    final initial =
        siswa.name.isNotEmpty ? siswa.name[0].toUpperCase() : 'S';
    return Container(
      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}

