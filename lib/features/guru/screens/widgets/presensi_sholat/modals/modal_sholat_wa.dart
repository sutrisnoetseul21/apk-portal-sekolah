import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apk_portal_smpn1_sampang/core/config/app_config.dart';

/// Modal Kirim WhatsApp Sholat Dhuhur ke Orang Tua Siswa
class ModalSholatWa extends StatefulWidget {
  final Dio dio;
  final Map<String, dynamic> student;
  final String selectedClassName;

  const ModalSholatWa({
    super.key,
    required this.dio,
    required this.student,
    required this.selectedClassName,
  });

  static Future<void> show(
    BuildContext context, {
    required Dio dio,
    required Map<String, dynamic> student,
    required String selectedClassName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalSholatWa(
        dio: dio,
        student: student,
        selectedClassName: selectedClassName,
      ),
    );
  }

  @override
  State<ModalSholatWa> createState() => _ModalSholatWaState();
}

class _ModalSholatWaState extends State<ModalSholatWa> {
  static const Color _emeraldPrimary = Color(0xFF059669);
  static const Color _tealDark = Color(0xFF0F766E);

  late final TextEditingController _phoneCtrl;
  late final TextEditingController _msgCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    final today = student['today'] is Map
        ? Map<String, dynamic>.from(student['today'] as Map)
        : <String, dynamic>{};
    final originalText = today['wa_text']?.toString() ?? '';

    _phoneCtrl = TextEditingController(
      text: (student['phone_clean'] ?? student['phone_raw'] ?? '').toString(),
    );
    _msgCtrl = TextEditingController(text: originalText);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleDirectWa() async {
    String clean = _phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('0')) {
      clean = '62${clean.substring(1)}';
    }
    final uri = Uri.parse(
      'https://wa.me/$clean?text=${Uri.encodeComponent(_msgCtrl.text)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _handleGatewaySend() async {
    setState(() => _isSaving = true);
    final studentId = widget.student['id']?.toString() ?? '';

    try {
      final resp = await widget.dio.post(
        '${AppConfig.baseUrl}/guru/sholat-dhuhur/send-wa',
        data: {
          'student_id': studentId,
          'phone': _phoneCtrl.text.trim(),
          'message': _msgCtrl.text.trim(),
          'type': 'sholat_dhuhur',
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resp.data?['message']?.toString() ??
                  'Pesan WhatsApp terkirim!',
            ),
            backgroundColor: _emeraldPrimary,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data?['message']?.toString() ??
                  'Gagal mengirim via gateway.',
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.student['name']?.toString() ?? '-';
    final studentNisn = widget.student['nisn']?.toString() ?? '-';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_emeraldPrimary, _tealDark],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.chat_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Kirim WA Sholat Dhuhur ke Ortu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$studentName (Kelas ${widget.selectedClassName} • NISN: $studentNisn)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor WhatsApp Orang Tua',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _msgCtrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Isi Pesan WhatsApp',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _handleDirectWa,
                          icon: const Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                          ),
                          label: const Text('Buka Aplikasi WA'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _emeraldPrimary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _isSaving ? null : _handleGatewaySend,
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: Text(
                            _isSaving ? 'Mengirim...' : 'Kirim Gateway',
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
    );
  }
}

