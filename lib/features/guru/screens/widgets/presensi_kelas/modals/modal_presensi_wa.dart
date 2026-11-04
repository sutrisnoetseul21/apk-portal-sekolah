import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/config/app_config.dart';
import '../../../../../../core/constants/app_colors.dart';

/// Modal Kirim Pesan WhatsApp Ortu (Telat / Belum Presensi)
class ModalPresensiWa extends StatefulWidget {
  final Dio dio;
  final Map<String, dynamic> student;
  final String type;
  final String selectedClassName;
  final String? selectedClassId;

  const ModalPresensiWa({
    super.key,
    required this.dio,
    required this.student,
    required this.type,
    required this.selectedClassName,
    required this.selectedClassId,
  });

  static Future<void> show(
    BuildContext context, {
    required Dio dio,
    required Map<String, dynamic> student,
    required String type,
    required String selectedClassName,
    required String? selectedClassId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalPresensiWa(
        dio: dio,
        student: student,
        type: type,
        selectedClassName: selectedClassName,
        selectedClassId: selectedClassId,
      ),
    );
  }

  @override
  State<ModalPresensiWa> createState() => _ModalPresensiWaState();
}

class _ModalPresensiWaState extends State<ModalPresensiWa> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _msgCtrl;
  late final String _originalMessage;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    final initialPhone = student['clean_phone']?.toString().isNotEmpty == true
        ? student['clean_phone'].toString()
        : (student['phone']?.toString() ?? '');
    _originalMessage = widget.type == 'telat'
        ? (student['wa_text_telat']?.toString() ?? '')
        : (student['wa_text_belum']?.toString() ?? '');

    _phoneCtrl = TextEditingController(text: initialPhone);
    _msgCtrl = TextEditingController(text: _originalMessage);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    setState(() => _isSending = true);
    final studentId = widget.student['id']?.toString() ?? '';
    try {
      final res = await widget.dio.post(
        '${AppConfig.baseUrl}/guru/presensi/send-wa',
        data: {
          'student_id': studentId,
          'phone': _phoneCtrl.text.trim(),
          'message': _msgCtrl.text.trim(),
          'type': widget.type,
          'class_id': widget.selectedClassId,
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.data['message']?.toString() ?? 'Pesan WhatsApp terkirim!',
            ),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    } catch (_) {
      // Fallback buka wa.me langsung jika gateway sedang offline
      final clean = _phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      final url = Uri.parse(
        'https://wa.me/$clean?text=${Uri.encodeComponent(_msgCtrl.text)}',
      );
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final studentName = student['name']?.toString() ?? '-';
    final nisn = student['nisn']?.toString() ?? '-';
    final isTelat = widget.type == 'telat';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Modal WA
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF0D9488)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kirim Pesan WhatsApp Ortu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kirim langsung dari sistem gateway aplikasi sekolah',
                            style: TextStyle(
                              color: Color(0xFFD1FAE5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Siswa Target
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PENERIMA (SISWA)',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Kelas ${widget.selectedClassName} • NISN: $nisn',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isTelat
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isTelat ? 'Terlambat' : 'Belum Presensi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isTelat
                                    ? const Color(0xFF92400E)
                                    : const Color(0xFF9F1239),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'NOMOR WHATSAPP ORANG TUA / WALI',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 08123456789 atau 628123456789',
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          size: 18,
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ISI PESAN WHATSAPP',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _msgCtrl.text = _originalMessage,
                          child: const Text(
                            'Reset Format Asli',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _msgCtrl,
                      maxLines: 6,
                      style: const TextStyle(fontSize: 12.5),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isSending ? null : _handleSend,
                            icon: const Icon(
                              Icons.send_rounded,
                              size: 16,
                            ),
                            label: Text(
                              _isSending
                                  ? 'Mengirim...'
                                  : 'Kirim Sekarang (via Sistem)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

