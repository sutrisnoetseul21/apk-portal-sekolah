import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/spikap_models.dart';
import '../services/spikap_service.dart';
import 'widgets/spikap/detail/spikap_detail_student_card.dart';
import 'widgets/spikap/detail/spikap_detail_kronologi_card.dart';
import 'widgets/spikap/detail/spikap_detail_lampiran_card.dart';
import 'widgets/spikap/detail/spikap_detail_update_status_card.dart';
import 'widgets/spikap/detail/spikap_detail_audit_trail_card.dart';

/// Halaman Detail Investigasi Kasus SPIKAP Guru
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

    // Konfirmasi eksplisit saat menandai kasus sebagai 'selesai'
    if (_selectedStatus == 'selesai' && _laporan!.status != 'selesai') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF059669),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Selesaikan Kasus?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin kasus perundungan ini telah selesai diinvestigasi dan dimediasi dengan tuntas? Status laporan akan ditandai sebagai "Selesai".',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Ya, Selesaikan'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
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

  Future<void> _openWhatsApp(String phone, String studentName, {bool isSiswa = false}) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedPhone = cleanPhone.startsWith('08')
        ? '628${cleanPhone.substring(2)}'
        : cleanPhone;

    final targetLabel = isSiswa ? 'Siswa Ananda $studentName' : 'Bapak/Ibu Wali Murid dari $studentName';
    final message = Uri.encodeComponent(
      'Halo $targetLabel, kami dari tim penanganan sekolah (${widget.schoolName}) terkait laporan SPIKAP #${widget.ticketNumber}. Mohon waktu untuk konfirmasi.',
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

  Future<void> _openVideo(SpikapLampiranItem lampiran) async {
    final uri = Uri.parse(lampiran.url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat memutar berkas video';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka video: $e'),
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
          SpikapDetailStudentCard(
            laporan: lap,
            onOpenWhatsApp: _openWhatsApp,
          ),
          const SizedBox(height: 14),

          // Card Kronologi & Uraian Kejadian
          SpikapDetailKronologiCard(
            laporan: lap,
          ),
          const SizedBox(height: 14),

          // Galeri Lampiran Bukti
          if (lap.lampiran.isNotEmpty) ...[
            SpikapDetailLampiranCard(
              lampiran: lap.lampiran,
              onImageTap: _showImagePreview,
              onVideoTap: _openVideo,
            ),
            const SizedBox(height: 14),
          ],

          // Form Ubah Status Investigasi (Jika memiliki izin update)
          if (lap.canUpdateStatus) ...[
            SpikapDetailUpdateStatusCard(
              selectedStatus: _selectedStatus,
              onStatusChanged: (val) => setState(() => _selectedStatus = val),
              catatanController: _catatanController,
              notifyWa: _notifyWa,
              onNotifyWaChanged: (val) => setState(() => _notifyWa = val),
              isSubmitting: _isSubmitting,
              onSubmit: _handleUpdateStatus,
            ),
            const SizedBox(height: 14),
          ],

          // Audit Trail Log Status
          SpikapDetailAuditTrailCard(
            auditLogs: lap.auditLogs,
          ),
          const SizedBox(height: 24),
        ],
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
}
