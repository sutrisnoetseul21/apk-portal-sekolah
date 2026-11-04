import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/services/ijin_kehadiran_service.dart';

/// Modal Bottom Sheet Detail Permohonan Izin & Bilah Keputusan Wali Kelas
class ModalDetailIjin extends StatefulWidget {
  final String recordId;
  final IjinKehadiranService service;
  final VoidCallback onStatusChanged;

  const ModalDetailIjin({
    super.key,
    required this.recordId,
    required this.service,
    required this.onStatusChanged,
  });

  static void show(
    BuildContext context, {
    required String recordId,
    required IjinKehadiranService service,
    required VoidCallback onStatusChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalDetailIjin(
        recordId: recordId,
        service: service,
        onStatusChanged: onStatusChanged,
      ),
    );
  }

  @override
  State<ModalDetailIjin> createState() => _ModalDetailIjinState();
}

class _ModalDetailIjinState extends State<ModalDetailIjin> {
  bool _isLoading = true;
  bool _isActionProcessing = false;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.service.getLeaveRequestDetail(widget.recordId);
      if (mounted) {
        setState(() {
          _detail = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleApprove() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Setujui Permohonan?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          'Presensi siswa pada tanggal KBM efektif sekolah akan otomatis terisi sebagai Izin/Sakit di tabel presensi.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Setujui'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionProcessing = true);
    try {
      final res = await widget.service.approveLeaveRequest(widget.recordId);
      _showToast(res['message']?.toString() ?? 'Izin berhasil disetujui.');
      widget.onStatusChanged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isActionProcessing = false);
    }
  }

  Future<void> _handleReject() async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Permohonan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mohon cantumkan alasan penolakan agar siswa dan orang tua memahami penyebabnya:',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      'Contoh: Surat dokter tidak valid / tidak ada cap...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 3) {
                    return 'Alasan penolakan minimal 3 karakter.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(ctx, reasonController.text.trim());
              }
            },
            child: const Text('Tolak Permohonan'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _isActionProcessing = true);
    try {
      final res =
          await widget.service.rejectLeaveRequest(widget.recordId, reason);
      _showToast(
          res['message']?.toString() ?? 'Permohonan berhasil ditolak.');
      widget.onStatusChanged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isActionProcessing = false);
    }
  }

  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kembalikan ke Pending?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          'Catatan presensi otomatis (jika ada) akan dicabut dan status kembali menjadi menunggu verifikasi.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF475569),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kembalikan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionProcessing = true);
    try {
      final res = await widget.service.resetLeaveRequest(widget.recordId);
      _showToast(res['message']?.toString() ?? 'Status berhasil dikembalikan.');
      widget.onStatusChanged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isActionProcessing = false);
    }
  }

  void _launchWhatsApp(String phone) async {
    final url = 'https://wa.me/$phone';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showToast('Tidak dapat membuka WhatsApp untuk nomor $phone',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 380,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(
          child: SpinKitFadingCircle(color: AppColors.primary, size: 40),
        ),
      );
    }

    final detail = _detail!;
    final student = (detail['student'] as Map<String, dynamic>? ?? {});
    final leave = (detail['leave'] as Map<String, dynamic>? ?? {});
    final authInfo = (detail['authorization'] as Map<String, dynamic>? ?? {});
    final attachments = (detail['attachments'] as List? ?? []);
    final logs = (detail['logs'] as List? ?? []);

    final bool canApprove = authInfo['can_approve_or_reject'] == true;
    final String? restrictionNotice =
        authInfo['restriction_notice']?.toString();

    final status = leave['status']?.toString() ?? 'pending';
    final isPending = status == 'pending';
    final isSakit = leave['type']?.toString() == 'sakit';

    final studentName = student['name']?.toString() ?? 'Siswa';
    final className = student['class_name']?.toString() ?? '-';
    final nisn = student['nisn']?.toString() ?? '-';
    final parentName = student['parent_name']?.toString() ?? 'Orang Tua';
    final parentPhone = student['parent_phone']?.toString();
    final parentPhoneClean = student['parent_phone_clean']?.toString();

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // Header Modal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Permohonan Izin',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '$studentName • Kelas $className',
                        style: const TextStyle(
                            fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Pemberitahuan Mode Pantau (Khusus Guru BK)
                  if (restrictionNotice != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFF2563EB), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              restrictionNotice,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF1E40AF),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // CARD 1: INFORMASI SISWA & ORTU
                  _buildSectionHeader('Profil Siswa & Kontak Orang Tua'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Nama Siswa', studentName),
                        _buildDetailRow(
                            'NISN / NIS', '$nisn / ${student['nis'] ?? '-'}'),
                        _buildDetailRow('Kelas', 'Kelas $className'),
                        _buildDetailRow('Orang Tua / Wali', parentName),
                        if (parentPhone != null && parentPhone.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'No. WhatsApp Ortu',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              if (parentPhoneClean != null)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF22C55E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  onPressed: () =>
                                      _launchWhatsApp(parentPhoneClean),
                                  icon: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 12),
                                  label: Text(
                                    parentPhone,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              else
                                Text(
                                  parentPhone,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 2: RINCIAN PERMOHONAN
                  _buildSectionHeader('Rincian Izin / Sakit'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Jenis Permohonan',
                          isSakit ? 'Sakit' : 'Izin',
                          valueColor: isSakit
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF16A34A),
                        ),
                        _buildDetailRow('Tanggal Mulai',
                            leave['start_date_formatted']?.toString() ?? '-'),
                        _buildDetailRow('Tanggal Selesai',
                            leave['end_date_formatted']?.toString() ?? '-'),
                        _buildDetailRow('Durasi Hari',
                            leave['duration_label']?.toString() ?? '-'),
                        _buildDetailRow('Status Saat Ini',
                            leave['status_label']?.toString() ?? '-'),
                        const SizedBox(height: 8),
                        const Text(
                          'Alasan / Keterangan:',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            leave['reason']?.toString() ?? '-',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E293B),
                                height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 3: BERKAS LAMPIRAN SURAT DOKTER / ORTU
                  _buildSectionHeader(
                      'Berkas Lampiran Bukti (${attachments.length})'),
                  if (attachments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'Tidak ada lampiran foto/berkas yang diunggah.',
                          style: TextStyle(
                              fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: attachments.length,
                      itemBuilder: (ctx, idx) {
                        final att = attachments[idx];
                        final isImg = att['is_image'] == true;
                        final url = att['url']?.toString() ?? '';
                        final name = att['name']?.toString() ?? 'Lampiran';

                        return GestureDetector(
                          onTap: () =>
                              _openAttachmentViewer(url, isImg, name),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: isImg
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Center(
                                            child: Icon(
                                                Icons.broken_image_rounded,
                                                color: Color(0xFF94A3B8)),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            color:
                                                Colors.black.withValues(alpha: 0.6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 4),
                                            child: Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                              Icons.picture_as_pdf_rounded,
                                              color: Color(0xFFDC2626),
                                              size: 32),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets
                                                .symmetric(horizontal: 6),
                                            child: Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 14),

                  // CARD 4: RIWAYAT AUDIT LOG
                  if (logs.isNotEmpty) ...[
                    _buildSectionHeader('Riwayat Log Persetujuan'),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: logs.map((lg) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${lg['action_label']} oleh ${lg['user_name']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (lg['reason'] != null &&
                                          lg['reason'].toString().isNotEmpty)
                                        Text(
                                          lg['reason'].toString(),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF475569)),
                                        ),
                                      Text(
                                        lg['created_at_formatted']
                                                ?.toString() ??
                                            '',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // BILAH AKSI KEPUTUSAN WALI KELAS (Bottom Bar)
          if (canApprove) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: _isActionProcessing
                  ? const Center(
                      child: SpinKitThreeBounce(
                          color: AppColors.primary, size: 24),
                    )
                  : Row(
                      children: [
                        if (isPending) ...[
                          // Tombol Tolak
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDC2626),
                                side: const BorderSide(
                                    color: Color(0xFFDC2626)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleReject,
                              icon: const Icon(Icons.cancel_outlined,
                                  size: 16),
                              label: const Text('Tolak',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Tombol Setujui
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleApprove,
                              icon: const Icon(Icons.check_circle_rounded,
                                  size: 16),
                              label: const Text(
                                'Setujui Permohonan',
                                style:
                                    TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Status sudah approved / rejected -> Tampilkan opsi Reset ke Pending
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF475569),
                                side: const BorderSide(
                                    color: Color(0xFF94A3B8)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleReset,
                              icon: const Icon(Icons.restart_alt_rounded,
                                  size: 16),
                              label: const Text(
                                'Kembalikan ke Status Menunggu (Reset)',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  void _openAttachmentViewer(String url, bool isImage, String title) {
    if (isImage) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.broken_image_rounded,
                              size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Gambar terhalang CORS browser atau file belum diexport ke storage.',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication),
                            icon: const Icon(Icons.open_in_new_rounded,
                                size: 16),
                            label: const Text('Buka di Tab Baru'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      child: IconButton(
                        icon: const Icon(Icons.open_in_new_rounded,
                            color: Colors.white, size: 18),
                        tooltip: 'Buka di Tab Baru',
                        onPressed: () => launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

