import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_compress_util.dart';
import '../models/siswa_ijin_model.dart';
import '../services/siswa_ijin_service.dart';
import 'widgets/form_ijin/sections/form_ijin_type_selector.dart';
import 'widgets/form_ijin/sections/form_ijin_date_picker_section.dart';
import 'widgets/form_ijin/sections/form_ijin_holiday_notice.dart';
import 'widgets/form_ijin/sections/form_ijin_photo_uploader.dart';

/// Layar Menu 2: Formulir Pengajuan Ijin Kehadiran Siswa
class FormIjinSiswaScreen extends StatefulWidget {
  final String identifier;
  final String studentName;
  final String schoolName;
  final String? token;

  const FormIjinSiswaScreen({
    super.key,
    required this.identifier,
    required this.studentName,
    this.schoolName = '',
    this.token,
  });

  @override
  State<FormIjinSiswaScreen> createState() => _FormIjinSiswaScreenState();
}

class _FormIjinSiswaScreenState extends State<FormIjinSiswaScreen> {
  final _formKey = GlobalKey<FormState>();
  late SiswaIjinService _service;

  // Form State
  String _selectedType = 'sakit'; // 'sakit' | 'ijin'
  DateTime _startDate = DateTime.now();
  int _durationDays = 1;
  final TextEditingController _reasonController = TextEditingController();

  // Lampiran terkompresi
  final List<CompressedImageResult> _compressedAttachments = [];

  // Pengecekan Hari Libur
  bool _isCheckingHolidays = false;
  SiswaHolidaysCheckResult? _holidayCheckResult;

  // Loading Submission
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _service = SiswaIjinService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
    _performHolidayCheck();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  DateTime get _endDate => _startDate.add(Duration(days: _durationDays - 1));

  String _formatDateIndo(DateTime date) {
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final dayName = days[date.weekday - 1];
      final monthName = months[date.month - 1];
      return '$dayName, ${date.day} $monthName ${date.year}';
    }
  }

  Future<void> _performHolidayCheck() async {
    setState(() {
      _isCheckingHolidays = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final res = await _service.checkHolidays(
        startDate: dateStr,
        durationDays: _durationDays,
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _holidayCheckResult = res;
          _isCheckingHolidays = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCheckingHolidays = false;
        });
      }
    }
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final firstDate = now.subtract(const Duration(days: 7));
    final lastDate = now.add(const Duration(days: 7));

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(firstDate)
          ? firstDate
          : (_startDate.isAfter(lastDate) ? lastDate : _startDate),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'PILIH TANGGAL MULAI IZIN',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _performHolidayCheck();
    }
  }

  void _updateDuration(int delta) {
    final next = _durationDays + delta;
    if (next >= 1 && next <= 30) {
      setState(() {
        _durationDays = next;
      });
      _performHolidayCheck();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_compressedAttachments.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batas maksimal 5 lampiran berkas.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final result = await ImageCompressUtil.pickAndCompressImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 70,
    );

    if (result != null && mounted) {
      setState(() {
        _compressedAttachments.add(result);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.note,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == 'sakit' && _compressedAttachments.isEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text('Lampiran Surat Dokter'),
            ],
          ),
          content: const Text(
            'Anda memilih permohonan Sakit tetapi belum mengunggah foto surat dokter/orang tua. Apakah Anda tetap ingin mengirimkan permohonan ini?',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal & Unggah Foto', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tetap Kirim'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final xfiles = _compressedAttachments.map((e) => e.file).toList();

      await _service.submitLeaveRequest(
        type: _selectedType,
        startDate: startDateStr,
        durationDays: _durationDays,
        reason: _reasonController.text.trim(),
        attachments: xfiles,
        identifier: widget.identifier,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permohonan izin berhasil diajukan.'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildReasonField() {
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
          const Text(
            'Alasan / Keterangan (Maks. 200 Karakter)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _reasonController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: _selectedType == 'sakit'
                  ? 'Contoh: Mengalami demam tinggi dan flu, beristirahat sesuai anjuran dokter.'
                  : 'Contoh: Menghadiri acara pernikahan saudara kandung di luar kota.',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Alasan izin wajib diisi.';
              }
              if (value.trim().length < 3) {
                return 'Alasan minimal 3 karakter.';
              }
              if (value.trim().length > 200) {
                return 'Alasan tidak boleh lebih dari 200 karakter.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form Pengajuan Ijin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Portal Siswa Terpadu',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Selector Tipe Permohonan (Sakit vs Ijin)
              FormIjinTypeSelector(
                selectedType: _selectedType,
                onTypeChanged: (type) => setState(() => _selectedType = type),
              ),

              const SizedBox(height: 18),

              // 2. Pemilih Tanggal & Durasi Hari
              FormIjinDatePickerSection(
                formattedStartDate: _formatDateIndo(_startDate),
                formattedEndDate: _formatDateIndo(_endDate),
                durationDays: _durationDays,
                onSelectStartDate: _selectStartDate,
                onUpdateDuration: _updateDuration,
              ),

              const SizedBox(height: 14),

              // 3. Banner Pengecekan Hari Libur Sekolah
              FormIjinHolidayNotice(
                isCheckingHolidays: _isCheckingHolidays,
                holidayCheckResult: _holidayCheckResult,
              ),

              const SizedBox(height: 18),

              // 4. Input Alasan / Keterangan
              _buildReasonField(),

              const SizedBox(height: 18),

              // 5. Upload Foto dengan Kompresi Otomatis Ala WhatsApp
              FormIjinPhotoUploader(
                attachments: _compressedAttachments,
                onPickImage: _pickImage,
                onRemoveAttachment: (index) => setState(() => _compressedAttachments.removeAt(index)),
              ),

              const SizedBox(height: 28),

              // 6. Tombol Submit Permohonan
              Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Mengirim Permohonan...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Kirim Pengajuan Ijin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
