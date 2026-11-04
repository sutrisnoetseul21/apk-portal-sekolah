import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/siswa_guru_wali_service.dart';

/// Layar Formulir Mulai Bercerita / Konsultasi ke Guru Wali (Portal Siswa)
/// Dibuat model layar penuh (Scaffold) seperti SPIKAP agar penulisan leluasa
/// dan terbebas dari masalah input tertutup virtual keyboard.
class FormCurhatSiswaScreen extends StatefulWidget {
  final SiswaGuruWaliService service;
  final String identifier;

  const FormCurhatSiswaScreen({
    super.key,
    required this.service,
    required this.identifier,
  });

  @override
  State<FormCurhatSiswaScreen> createState() => _FormCurhatSiswaScreenState();
}

class _FormCurhatSiswaScreenState extends State<FormCurhatSiswaScreen> {
  final _formKey = GlobalKey<FormState>();

  String _kategori = 'Akademik';
  String _mode = 'Tatap Muka';
  final TextEditingController _topikController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  DateTime? _usulanWaktu;
  bool _isSubmitting = false;

  final List<String> _kategoriOptions = const [
    'Akademik',
    'Karakter & Kedisiplinan',
    'Minat & Bakat / Ekskul',
    'Sosial & Psikologis',
  ];

  @override
  void dispose() {
    _topikController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
      );

      if (time != null && mounted) {
        setState(() {
          _usulanWaktu = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.service.createKonsultasi(
        kategori: _kategori,
        mode: _mode,
        topik: _topikController.text.trim(),
        detail: _detailController.text.trim(),
        usulanTanggalWaktu: _usulanWaktu?.toIso8601String(),
        identifier: widget.identifier,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Mulai Bercerita ke Guru Wali',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Banner (Ruang Aman Cerita)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.security_rounded,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ruang Aman & Terlindungi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Pesan dan curahan hati Anda hanya bisa dibaca oleh Guru Wali asuh Anda. Jangan ragu untuk berbagi cerita secara jujur dan terbuka.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF1E3A8A),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Pilihan Kategori (4 Pilar)
              const Text(
                '1. Pilih Kategori Masalah',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kategoriOptions.map((cat) {
                  final isSel = _kategori == cat;
                  return ChoiceChip(
                    selected: isSel,
                    showCheckmark: false,
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        color: isSel ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSel
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFCBD5E1),
                    ),
                    onSelected: (_) => setState(() => _kategori = cat),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Pilihan Mode Konsultasi
              const Text(
                '2. Mode Konsultasi yang Diinginkan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _mode = 'Tatap Muka'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _mode == 'Tatap Muka'
                              ? const Color(0xFFEFF6FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _mode == 'Tatap Muka'
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFCBD5E1),
                            width: _mode == 'Tatap Muka' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              size: 20,
                              color: _mode == 'Tatap Muka'
                                  ? const Color(0xFF2563EB)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tatap Muka',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _mode == 'Tatap Muka'
                                    ? const Color(0xFF2563EB)
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _mode = 'Pesan Portal'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _mode == 'Pesan Portal'
                              ? const Color(0xFFEFF6FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _mode == 'Pesan Portal'
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFCBD5E1),
                            width: _mode == 'Pesan Portal' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_rounded,
                              size: 20,
                              color: _mode == 'Pesan Portal'
                                  ? const Color(0xFF2563EB)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Pesan Portal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _mode == 'Pesan Portal'
                                    ? const Color(0xFF2563EB)
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Topik Konsultasi
              const Text(
                '3. Topik / Garis Besar Masalah',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _topikController,
                scrollPadding: const EdgeInsets.only(bottom: 120),
                decoration: InputDecoration(
                  hintText: 'Misal: Kesulitan pelajaran matematika, bingung ekskul...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return 'Topik terlalu singkat (minimal 3 karakter).';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Detail Permasalahan
              const Text(
                '4. Ceritakan Kendala / Hal yang Ingin Dikonsultasikan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _detailController,
                maxLines: 5,
                scrollPadding: const EdgeInsets.only(bottom: 120),
                decoration: InputDecoration(
                  hintText: 'Tuliskan secara terbuka dan jujur. Apa yang kamu rasakan atau alami akhir-akhir ini...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 10) {
                    return 'Ceritakan lebih detail (minimal 10 karakter).';
                  }
                  return null;
                },
              ),

              // Usulan Waktu Tatap Muka
              if (_mode == 'Tatap Muka') ...[
                const SizedBox(height: 20),
                const Text(
                  '5. Usulan Waktu Pertemuan (Opsional)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _pickDateTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _usulanWaktu != null
                                ? '${_usulanWaktu!.day}/${_usulanWaktu!.month}/${_usulanWaktu!.year} jam ${_usulanWaktu!.hour.toString().padLeft(2, '0')}:${_usulanWaktu!.minute.toString().padLeft(2, '0')} WIB'
                                : 'Pilih usulan tanggal & jam pertemuan...',
                            style: TextStyle(
                              fontSize: 13,
                              color: _usulanWaktu != null
                                  ? AppColors.textPrimary
                                  : const Color(0xFF94A3B8),
                              fontWeight: _usulanWaktu != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (_usulanWaktu != null)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() => _usulanWaktu = null),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox.shrink()
                      : const Icon(Icons.send_rounded, size: 18),
                  label: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Kirim Cerita ke Guru Wali',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

