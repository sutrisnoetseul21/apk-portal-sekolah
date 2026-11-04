import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/leave_request_model.dart';

/// Kartu Item Permohonan Izin Siswa untuk Wali Kelas
class LeaveRequestCard extends StatelessWidget {
  final LeaveRequestItemModel item;
  final VoidCallback onTap;

  const LeaveRequestCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    String statusText;
    IconData statusIcon;

    if (item.isApproved) {
      statusColor = const Color(0xFF059669);
      statusBgColor = const Color(0xFFECFDF5);
      statusText = 'Disetujui';
      statusIcon = Icons.check_circle_rounded;
    } else if (item.isRejected) {
      statusColor = const Color(0xFFDC2626);
      statusBgColor = const Color(0xFFFEF2F2);
      statusText = 'Ditolak';
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = const Color(0xFFD97706);
      statusBgColor = const Color(0xFFFFFBEB);
      statusText = 'Menunggu Verifikasi';
      statusIcon = Icons.hourglass_top_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isPending
              ? const Color(0xFFFDE68A)
              : AppColors.border,
          width: item.isPending ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Kartu: Avatar Siswa, Nama, Kelas, Badge Jenis Izin
                Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: item.isSakit
                          ? const Color(0xFFFFE4E6)
                          : const Color(0xFFDCFCE7),
                      child: Text(
                        item.initials,
                        style: TextStyle(
                          color: item.isSakit
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF16A34A),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.studentName,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kelas ${item.className} • NISN: ${item.studentNisn}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge Jenis: Izin / Sakit
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.isSakit
                            ? const Color(0xFFFFE4E6)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.isSakit
                                ? Icons.medical_services_outlined
                                : Icons.event_note_rounded,
                            size: 11,
                            color: item.isSakit
                                ? const Color(0xFFE11D48)
                                : const Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.typeLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: item.isSakit
                                  ? const Color(0xFFE11D48)
                                  : const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Info Rentang Tanggal & Durasi
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 13, color: Color(0xFF475569)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.dateRange} (${item.durationLabel})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Cuplikan Alasan Izin
                Text(
                  item.reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                    height: 1.3,
                  ),
                ),

                // Pratinjau Thumbnail Lampiran (Jika Ada)
                if (item.attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_file_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        '${item.attachments.length} Berkas Lampiran',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                      if (item.thumbnailUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            item.thumbnailUrl!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_outlined,
                                size: 20),
                          ),
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Footer Status & Tombol Aksi
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.isPending && item.canApprove
                            ? AppColors.primary
                            : const Color(0xFFF1F5F9),
                        foregroundColor: item.isPending && item.canApprove
                            ? Colors.white
                            : const Color(0xFF334155),
                        elevation: item.isPending && item.canApprove ? 1 : 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onTap,
                      icon: Icon(
                        item.isPending && item.canApprove
                            ? Icons.gavel_rounded
                            : Icons.visibility_outlined,
                        size: 13,
                      ),
                      label: Text(
                        item.isPending && item.canApprove
                            ? 'Tinjau & Putuskan'
                            : 'Lihat Detail',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

