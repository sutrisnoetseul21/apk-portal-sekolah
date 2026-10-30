import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../models/spikap_models.dart';
import '../services/spikap_service.dart';

/// Halaman Detail Investigasi Kasus SPIKAP
class SpikapDetailScreen extends StatefulWidget {
  final int laporanId;
  final String ticketNumber;
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;

  const SpikapDetailScreen({
    super.key,
    required this.laporanId,
    required this.ticketNumber,
    required this.teacherName,
    this.token,
    this.identifier,
    required this.schoolName,
  });

  @override
  State<SpikapDetailScreen> createState() => _SpikapDetailScreenState();
}

class _SpikapDetailScreenState extends State<SpikapDetailScreen> {
  late final SpikapService _spikapService;

  bool _isLoading = true;
  String? _errorMessage;
  SpikapDetailLaporan? _laporan;

  // Form State
  String _selectedStatus = 'dalam_investigasi';
  final TextEditingController _catatanController = TextEditingController();
  bool _notifyWa = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _spikapService = SpikapService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
    _loadDetail();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _spikapService.getDetail(widget.laporanId);
      if (mounted) {
        setState(() {
          _laporan = detail;
          _selectedStatus = detail.status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleUpdateStatus() async {
    if (_laporan == null) return;

    final catatan = _catatanController.text.trim();
    if (_selectedStatus == _laporan!.status && catatan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada perubahan status atau catatan baru.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _spikapService.updateStatus(
        _laporan!.id,
        statusBaru: _selectedStatus,
        catatan: catatan.isNotEmpty ? catatan : null,
        notifyWa: _notifyWa,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status kasus #${widget.ticketNumber} berhasil diperbarui.',
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _catatanController.clear();
        await _loadDetail();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _openWhatsApp(String phone, String studentName) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedPhone = cleanPhone.startsWith('08')
        ? '628${cleanPhone.substring(2)}'
        : cleanPhone;

    final message = Uri.encodeComponent(
      'Halo Bapak/Ibu Wali Murid dari $studentName, kami dari tim penanganan sekolah (${widget.schoolName}) terkait laporan SPIKAP #${widget.ticketNumber}. Mohon waktu untuk konfirmasi.',
    );

    final waUrl = Uri.parse('https://wa.me/$formattedPhone?text=$message');
    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka aplikasi WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka WhatsApp: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImagePreview(SpikapLampiranItem lampiran) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: lampiran.url,
                  placeholder: (context, url) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: Colors.white60,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investigasi ${widget.ticketNumber}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.schoolName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: _loadDetail,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal Memuat Detail Kasus',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDetail,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final lap = _laporan!;

    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Status Darurat jika ada
          if (lap.isDarurat) ...[
            _buildDaruratBanner(),
            const SizedBox(height: 14),
          ],

          // Card Identitas Siswa & Kontak Ortu
          _buildStudentCard(lap),
          const SizedBox(height: 14),

          // Card Kronologi & Uraian Kejadian
          _buildKronologiCard(lap),
          const SizedBox(height: 14),

          // Galeri Lampiran Bukti
          if (lap.lampiran.isNotEmpty) ...[
            _buildLampiranCard(lap),
            const SizedBox(height: 14),
          ],

          // Form Ubah Status Investigasi (Jika memiliki izin update)
          if (lap.canUpdateStatus) ...[
            _buildUpdateStatusCard(lap),
            const SizedBox(height: 14),
          ],

          // Audit Trail Log Status
          _buildAuditTrailCard(lap),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDaruratBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚨 LAPORAN DARURAT (Kritis)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kasus ini membutuhkan respons dan pendampingan segera dari tim penanganan sekolah.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(SpikapDetailLaporan lap) {
    final s = lap.student;
    final hasWa = s.noHpOrtu != null && s.noHpOrtu!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_rounded,
                size: 16,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 6),
              Text(
                'Identitas Siswa & Kontak',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
              const Spacer(),
              _buildStatusChip(lap.status, lap.statusLabel),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEFF6FF),
                backgroundImage: s.photoUrl != null
                    ? CachedNetworkImageProvider(s.photoUrl!)
                    : null,
                child: s.photoUrl == null
                    ? Text(
                        s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NISN: ${s.nisn} • Kelas: ${s.className}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    if (s.namaAyah != null || s.namaIbu != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Ortu: ${s.namaAyah ?? s.namaIbu ?? '-'}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (hasWa) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor HP / WA Wali:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        s.noHpOrtu!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.chat_rounded, size: 15),
                  label: const Text(
                    'Hubungi WA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _openWhatsApp(s.noHpOrtu!, s.name),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKronologiCard(SpikapDetailLaporan lap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 16,
                color: Color(0xFF7C3AED),
              ),
              const SizedBox(width: 6),
              Text(
                'Kronologi & Uraian Kejadian',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Metadata Kejadian
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaTag(
                icon: Icons.category_outlined,
                label: lap.jenisLabel,
                color: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF5F3FF),
              ),
              _buildMetaTag(
                icon: Icons.location_on_outlined,
                label: lap.lokasiKejadian,
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
              ),
              if (lap.waktuKejadian != null)
                _buildMetaTag(
                  icon: Icons.access_time_rounded,
                  label: lap.waktuKejadian!,
                  color: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFEF3C7),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Teks Uraian Kejadian
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              lap.uraianKejadian,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.6,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Diterima sistem: ${lap.createdAt ?? '-'}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              if (lap.lastHandledByName != null)
                Text(
                  'Penangan: ${lap.lastHandledByName}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLampiranCard(SpikapDetailLaporan lap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.attach_file_rounded,
                size: 16,
                color: Color(0xFF059669),
              ),
              const SizedBox(width: 6),
              Text(
                'Lampiran Bukti (${lap.lampiran.length} Berkas)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: lap.lampiran.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final lamp = lap.lampiran[index];
                final isFoto = lamp.tipeFile == 'foto';
                return InkWell(
                  onTap: () {
                    if (isFoto) {
                      _showImagePreview(lamp);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (isFoto)
                          CachedNetworkImage(
                            imageUrl: lamp.url,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (_, __) => const Icon(
                              Icons.image_outlined,
                              color: Color(0xFF94A3B8),
                            ),
                          )
                        else
                          const Center(
                            child: Icon(
                              Icons.videocam_rounded,
                              size: 32,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              lamp.ukuranLabel,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '* Ketuk foto untuk memperbesar',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateStatusCard(SpikapDetailLaporan lap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 8),
              Text(
                'Tindak Lanjut & Pembaruan Status',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pilihan Status
          Text(
            'Ubah Status Kasus:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusOption(
                key: 'diterima',
                label: 'Diterima',
                activeColor: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              _buildStatusOption(
                key: 'dalam_investigasi',
                label: 'Investigasi',
                activeColor: const Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              _buildStatusOption(
                key: 'selesai',
                label: 'Selesai',
                activeColor: const Color(0xFF059669),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Catatan Penanganan
          Text(
            'Catatan Investigasi / Perkembangan Kasus:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _catatanController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Contoh: Korban dan pelaku sudah dipanggil ke ruang BK, mediasi kekeluargaan dilakukan...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
              fillColor: const Color(0xFFF8FAFC),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 10),

          // Checkbox Notifikasi WA
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _notifyWa,
                  onChanged: (val) {
                    setState(() {
                      _notifyWa = val ?? true;
                    });
                  },
                  activeColor: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kirim notifikasi otomatis via WhatsApp ke siswa & wali murid',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmitting ? null : _handleUpdateStatus,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(
                _isSubmitting
                    ? 'Menyimpan Perubahan...'
                    : 'Simpan Pembaruan Kasus',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required String key,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = _selectedStatus == key;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStatus = key;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.12) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuditTrailCard(SpikapDetailLaporan lap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                size: 16,
                color: Color(0xFF475569),
              ),
              const SizedBox(width: 6),
              Text(
                'Riwayat Penanganan (Audit Trail)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (lap.auditLogs.isEmpty)
            Text(
              'Belum ada riwayat perubahan status.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            )
          else
            ...lap.auditLogs.map((log) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${log.statusLamaLabel} → ${log.statusBaruLabel}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                log.createdAtFormatted,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            log.catatan,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Oleh: ${log.changedByName}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    Color bg;
    Color fg;
    switch (status) {
      case 'diterima':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
      case 'dalam_investigasi':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case 'selesai':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF047857);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
