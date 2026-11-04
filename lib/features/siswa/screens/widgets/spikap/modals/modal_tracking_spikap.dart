import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import '../../models/siswa_spikap_model.dart';
import '../../services/siswa_spikap_service.dart';

/// Modal BottomSheet Detail Laporan & Timeline Alur Investigasi SPIKAP Siswa
class ModalTrackingSpikap extends StatefulWidget {
  final SiswaSpikapLaporanItem laporanItem;
  final SiswaSpikapService service;
  final String identifier;

  const ModalTrackingSpikap({
    super.key,
    required this.laporanItem,
    required this.service,
    required this.identifier,
  });

  static Future<void> show(
    BuildContext context, {
    required SiswaSpikapLaporanItem laporanItem,
    required SiswaSpikapService service,
    required String identifier,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalTrackingSpikap(
        laporanItem: laporanItem,
        service: service,
        identifier: identifier,
      ),
    );
  }

  @override
  State<ModalTrackingSpikap> createState() => _ModalTrackingSpikapState();
}

class _ModalTrackingSpikapState extends State<ModalTrackingSpikap> {
  bool _isLoading = true;
  SiswaSpikapDetailResponse? _detailData;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final detail = await widget.service.getLaporanDetail(
        widget.laporanItem.id,
        identifier: widget.identifier,
      );
      if (mounted) {
        setState(() {
          _detailData = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _showImageDialog(String url, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                tooltip: 'Tutup Foto',
                onPressed: () => Navigator.pop(context),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (context, url) => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: const Text('Gagal memuat pratinjau gambar.'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemMeta(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(SiswaSpikapLaporanItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildItemMeta('Jenis Perundungan', item.labelJenis),
              ),
              Expanded(
                child: _buildItemMeta('Sifat Laporan', item.labelSifat),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildItemMeta('Tujuan', item.labelTujuan),
              ),
              Expanded(
                child: _buildItemMeta('Status Kasus', item.labelStatus),
              ),
            ],
          ),
          if (item.lokasiKejadian != null && item.lokasiKejadian!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildItemMeta('Lokasi Kejadian', item.lokasiKejadian!),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLampiranTile(SiswaSpikapLampiranItem lamp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            lamp.isFoto ? Icons.image_rounded : Icons.videocam_rounded,
            color: lamp.isFoto ? const Color(0xFF2563EB) : const Color(0xFFE11D48),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lamp.namaAsli,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  lamp.ukuranLabel,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (lamp.isFoto)
            TextButton.icon(
              icon: const Icon(Icons.visibility_rounded, size: 16),
              label: const Text('Lihat'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => _showImageDialog(lamp.url, lamp.namaAsli),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(SiswaSpikapTrackingLog log, {required bool isLast}) {
    Color stepColor = const Color(0xFF2563EB);
    IconData stepIcon = Icons.hourglass_top_rounded;

    if (log.statusBaru == 'selesai') {
      stepColor = const Color(0xFF059669);
      stepIcon = Icons.check_circle_rounded;
    } else if (log.statusBaru == 'dalam_investigasi') {
      stepColor = const Color(0xFF0284C7);
      stepIcon = Icons.search_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: stepColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: stepColor, width: 1.5),
              ),
              child: Icon(stepIcon, color: stepColor, size: 14),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.labelStatusBaru,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: stepColor,
                      ),
                    ),
                    Text(
                      log.createdAtFormatted ?? '',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Oleh: ${log.petugas.nama} (${log.petugas.peran})',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  log.catatan,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _detailData?.laporan ?? widget.laporanItem;
    final logs = _detailData?.trackingLogs ?? [];
    final lampiranList = _detailData?.lampiran ?? [];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Modal
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan #${item.id} (${item.labelSifat})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        item.createdAtFormatted ?? '',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMsg != null
                    ? Center(
                        child: Text(_errorMsg!, style: const TextStyle(color: Color(0xFFE11D48))),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info Ringkas
                            _buildSummaryCard(item),
                            const SizedBox(height: 20),

                            // Uraian Kejadian
                            const Text(
                              'Uraian Kejadian Dilaporkan:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                item.uraianKejadian,
                                style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Lampiran Bukti
                            if (lampiranList.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.attach_file_rounded, size: 18, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Berkas Bukti Terlampir (${lampiranList.length}):',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...lampiranList.map((lamp) => _buildLampiranTile(lamp)),
                              const SizedBox(height: 20),
                            ],

                            // Alur Tracking Investigasi
                            Row(
                              children: const [
                                Icon(Icons.timeline_rounded, size: 18, color: Color(0xFFE11D48)),
                                SizedBox(width: 6),
                                Text(
                                  'Perkembangan Penanganan Kasus:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            if (logs.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Laporan telah diterima sistem dan sedang menunggu tinjauan dari Guru / Tim TPPK.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  return _buildTimelineStep(
                                    logs[index],
                                    isLast: index == logs.length - 1,
                                  );
                                },
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

