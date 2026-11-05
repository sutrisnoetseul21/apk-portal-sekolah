import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/services/ijin_kehadiran_service.dart';
import 'detail/ijin_attachment_grid.dart';
import 'detail/ijin_audit_log_card.dart';
import 'detail/ijin_detail_bottom_action_bar.dart';
import 'detail/ijin_leave_details_card.dart';
import 'detail/ijin_student_parent_card.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Setujui Permohonan?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Tolak Permohonan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
                  hintText: 'Contoh: Surat dokter tidak valid / tidak ada cap...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      final res = await widget.service.rejectLeaveRequest(widget.recordId, reason);
      _showToast(res['message']?.toString() ?? 'Permohonan berhasil ditolak.');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Kembalikan ke Pending?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
      _showToast('Tidak dapat membuka WhatsApp untuk nomor $phone', isError: true);
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
    final String? restrictionNotice = authInfo['restriction_notice']?.toString();

    final status = leave['status']?.toString() ?? 'pending';
    final isPending = status == 'pending';

    final studentName = student['name']?.toString() ?? 'Siswa';
    final className = student['class_name']?.toString() ?? '-';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '$studentName • Kelas $className',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
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
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
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
                  IjinStudentParentCard(
                    student: student,
                    onWhatsAppTap: _launchWhatsApp,
                  ),

                  const SizedBox(height: 14),

                  // CARD 2: RINCIAN PERMOHONAN
                  IjinLeaveDetailsCard(leave: leave),

                  const SizedBox(height: 14),

                  // CARD 3: BERKAS LAMPIRAN SURAT DOKTER / ORTU
                  IjinAttachmentGrid(attachments: attachments),

                  const SizedBox(height: 14),

                  // CARD 4: RIWAYAT AUDIT LOG
                  IjinAuditLogCard(logs: logs),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // BILAH AKSI KEPUTUSAN WALI KELAS (Bottom Bar)
          if (canApprove)
            IjinDetailBottomActionBar(
              isActionProcessing: _isActionProcessing,
              isPending: isPending,
              onApprove: _handleApprove,
              onReject: _handleReject,
              onReset: _handleReset,
            ),
        ],
      ),
    );
  }
}
