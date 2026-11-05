import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/guru_wali_dashboard_model.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/services/guru_wali_service.dart';
import 'modals/jurnal_individu/jurnal_individu_summary_header.dart';
import 'modals/jurnal_individu/jurnal_individu_parameter_form.dart';
import 'modals/jurnal_individu/jurnal_individu_badge_card.dart';
import 'modals/jurnal_individu/jurnal_individu_rujukan_bk_card.dart';

/// Modal Bottomsheet untuk mencatat Jurnal Bimbingan Individu (Perorangan)
/// Sesuai Permendikdasmen No. 11/2025 dan Kepmendikdasmen No. 221/P/2025
class ModalJurnalIndividu extends StatefulWidget {
  final SiswaAsuhModel siswa;
  final GuruWaliService service;

  const ModalJurnalIndividu({
    super.key,
    required this.siswa,
    required this.service,
  });

  @override
  State<ModalJurnalIndividu> createState() => _ModalJurnalIndividuState();
}

class _ModalJurnalIndividuState extends State<ModalJurnalIndividu> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String _kategori = 'Karakter & Kedisiplinan';
  String _statusSesi = 'Tuntas / Selesai';
  final String _rujukanKolaborasi = 'Mandiri';
  String _sentimen = 'Positif';

  final TextEditingController _uraianController = TextEditingController();
  final TextEditingController _rtlController = TextEditingController();

  // Digital Badge Karakter
  bool _giveBadge = false;
  String _selectedBadge = 'Kedisiplinan';
  final TextEditingController _catatanApresiasiController = TextEditingController();

  // Rujuk ke Guru BK
  bool _rujukBk = false;
  String _urgensiBk = 'sedang';
  final TextEditingController _alasanBkController = TextEditingController();

  bool _isSubmitting = false;

  final List<String> _kategoriList = [
    'Karakter & Kedisiplinan',
    'Sosial & Psikologis',
    'Akademik',
    'Minat & Bakat / Ekskul',
  ];

  final List<String> _badgeOptions = [
    'Kedisiplinan',
    'Tanggung Jawab',
    'Kejujuran',
    'Santun & Beradab',
    'Kepedulian Sosial',
    'Inisiatif & Kreatif',
    'Ketekunan Belajar',
  ];

  @override
  void dispose() {
    _uraianController.dispose();
    _rtlController.dispose();
    _catatanApresiasiController.dispose();
    _alasanBkController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      helpText: 'Pilih Tanggal Bimbingan',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Pilih Waktu Bimbingan',
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  DateTime get _combinedDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final res = await widget.service.storeIndividualJurnal(
        studentId: widget.siswa.studentId,
        tanggalWaktu: _combinedDateTime,
        jenisPendampingan: 'Individu',
        kategoriPendampingan: _kategori,
        uraianPembahasan: _uraianController.text.trim(),
        statusSesi: _statusSesi,
        rujukanKolaborasi: _rujukBk ? 'Guru BK' : _rujukanKolaborasi,
        rencanaTindakLanjut: _rtlController.text.trim().isNotEmpty
            ? _rtlController.text.trim()
            : null,
        kategoriSentimen: _sentimen,
        isPublicNote: false,
        giveBadge: _giveBadge,
        namaBadge: _giveBadge ? _selectedBadge : null,
        catatanApresiasi: _giveBadge && _catatanApresiasiController.text.trim().isNotEmpty
            ? _catatanApresiasiController.text.trim()
            : null,
      );

      final createdId = res['data']?['id']?.toString();

      // Jika opsi eskalasi rujuk BK dipilih
      if (_rujukBk && createdId != null) {
        try {
          await widget.service.rujukBk(
            jurnalId: createdId,
            alasanRujukan: _alasanBkController.text.trim().isNotEmpty
                ? '(${_urgensiBk.toUpperCase()}) ${_alasanBkController.text.trim()}'
                : '(${_urgensiBk.toUpperCase()}) Eskalasi bimbingan guru wali untuk penanganan khusus.',
          );
        } catch (_) {}
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Jurnal bimbingan untuk ${widget.siswa.name} berhasil disimpan!${_giveBadge ? " ⭐ Badge dianugerahkan." : ""}',
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Catat Jurnal Individu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '${widget.siswa.name} • ${widget.siswa.kelasName}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
              JurnalIndividuSummaryHeader(
                siswa: widget.siswa,
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                onPickDate: _pickDate,
                onPickTime: _pickTime,
              ),
              const SizedBox(height: 18),
              JurnalIndividuParameterForm(
                kategori: _kategori,
                kategoriList: _kategoriList,
                onKategoriChanged: (val) {
                  if (val != null) setState(() => _kategori = val);
                },
                statusSesi: _statusSesi,
                onStatusSesiChanged: (val) {
                  if (val != null) setState(() => _statusSesi = val);
                },
                sentimen: _sentimen,
                onSentimenChanged: (val) {
                  if (val != null) setState(() => _sentimen = val);
                },
                uraianController: _uraianController,
                rtlController: _rtlController,
              ),
              const SizedBox(height: 20),
              JurnalIndividuBadgeCard(
                giveBadge: _giveBadge,
                onToggleBadge: (val) => setState(() => _giveBadge = val),
                selectedBadge: _selectedBadge,
                badgeOptions: _badgeOptions,
                onSelectBadge: (b) => setState(() => _selectedBadge = b),
                catatanApresiasiController: _catatanApresiasiController,
              ),
              const SizedBox(height: 16),
              JurnalIndividuRujukanBkCard(
                rujukBk: _rujukBk,
                onToggleRujukBk: (val) => setState(() => _rujukBk = val),
                urgensiBk: _urgensiBk,
                onSelectUrgensi: (u) => setState(() => _urgensiBk = u),
                alasanBkController: _alasanBkController,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                      : const Text(
                          'Simpan Jurnal Bimbingan',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

typedef FormJurnalIndividuScreen = ModalJurnalIndividu;
