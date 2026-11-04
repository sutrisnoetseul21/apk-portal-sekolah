import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/siswa_ijin_model.dart';
import '../components/ijin_status_badge.dart';

/// Modal bottom sheet detail permohonan izin siswa
class SheetDetailIjinSiswa extends StatelessWidget {
  final SiswaIjinItem item;
  final void Function(SiswaIjinItem) onCancel;

  const SheetDetailIjinSiswa({
    super.key,
    required this.item,
    required this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required SiswaIjinItem item,
    required void Function(SiswaIjinItem) onCancel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SheetDetailIjinSiswa(item: item, onCancel: onCancel),
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return MergeSemantics(
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Permohonan ${item.typeLabel}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Tutup',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Tipe Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: item.type == 'sakit' ? const Color(0xFFEFF6FF) : const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.type == 'sakit' ? Icons.medical_services_rounded : Icons.mail_rounded,
                            color: item.type == 'sakit' ? const Color(0xFF2563EB) : const Color(0xFF7C3AED),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.typeLabel,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.durationDays} Hari (${item.formattedRange})',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IjinStatusBadge(status: item.status, label: item.statusLabel),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info Rentang Tanggal
                  _buildInfoSection(
                    title: 'Jadwal & Waktu',
                    children: [
                      _buildDetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Tanggal Mulai',
                        value: item.formattedStartDate,
                      ),
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.event_available_rounded,
                        label: 'Tanggal Selesai',
                        value: item.formattedEndDate,
                      ),
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.timelapse_rounded,
                        label: 'Durasi Total',
                        value: '${item.durationDays} Hari',
                      ),
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.access_time_rounded,
                        label: 'Diajukan Pada',
                        value: item.formattedCreatedAt,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Alasan Izin
                  _buildInfoSection(
                    title: 'Alasan / Keterangan',
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          item.reason.isNotEmpty ? item.reason : 'Tidak ada keterangan tertulis.',
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Catatan Verifikasi Wali Kelas
                  if (item.status != 'pending') ...[
                    _buildInfoSection(
                      title: 'Verifikasi Wali Kelas / Guru',
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.status == 'approved' ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: item.status == 'approved' ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    item.status == 'approved' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                    size: 18,
                                    color: item.status == 'approved' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.status == 'approved' ? 'Disetujui' : 'Ditolak',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: item.status == 'approved' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                  if (item.approvedAt != null) ...[
                                    const Spacer(),
                                    Text(
                                      item.approvedAt!,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ],
                              ),
                              if (item.verificationNote != null && item.verificationNote!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  item.verificationNote!,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                ),
                              ],
                              if (item.approverName != null && item.approverName!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Petugas: ${item.approverName}',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Pratinjau Lampiran Foto / Surat
                  _buildInfoSection(
                    title: 'Lampiran Berkas / Surat (${item.attachmentsCount})',
                    children: [
                      if (item.attachments.isEmpty)
                        const Text(
                          'Tidak ada lampiran berkas yang diunggah.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                        )
                      else
                        ...item.attachments.map((att) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      att.isImage ? Icons.image_rounded : Icons.description_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        att.fileName.isNotEmpty ? att.fileName : 'Berkas Lampiran #${att.index + 1}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (att.isImage && att.url.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: att.url,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 200,
                                      placeholder: (context, url) => Container(
                                        height: 200,
                                        color: Colors.grey.shade100,
                                        child: const Center(child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        height: 120,
                                        color: Colors.grey.shade100,
                                        child: const Center(
                                          child: Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tombol Batalkan jika Cancellable
                  if (item.isCancellable) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Batalkan Permohonan Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);
                          onCancel(item);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Tombol Tutup
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

