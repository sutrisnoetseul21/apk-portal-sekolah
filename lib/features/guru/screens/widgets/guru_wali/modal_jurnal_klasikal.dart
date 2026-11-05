import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/guru_wali_dashboard_model.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/services/guru_wali_service.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/screens/widgets/guru_wali/modals/jurnal_klasikal/klasikal_student_selector_card.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/screens/widgets/guru_wali/modals/jurnal_klasikal/klasikal_datetime_picker_row.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/screens/widgets/guru_wali/modals/jurnal_klasikal/klasikal_parameter_form.dart';

/// Modal Bottomsheet untuk mencatat Bimbingan Klasikal (Kelompok Besar / Massal)
/// Sesuai Permendikdasmen No. 11/2025
class ModalJurnalKlasikal extends StatefulWidget {
  final List<SiswaAsuhModel> siswaList;
  final GuruWaliService service;

  const ModalJurnalKlasikal({
    super.key,
    required this.siswaList,
    required this.service,
  });

  @override
  State<ModalJurnalKlasikal> createState() => _ModalJurnalKlasikalState();
}

class _ModalJurnalKlasikalState extends State<ModalJurnalKlasikal> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String _jenis = 'Klasikal';
  String _kategori = 'Karakter & Kedisiplinan';
  final String _statusSesi = 'Tuntas / Selesai';
  final String _rujukanKolaborasi = 'Mandiri';

  final TextEditingController _uraianController = TextEditingController();
  final TextEditingController _rtlController = TextEditingController();

  final Set<String> _selectedStudentIds = {};
  bool _isSubmitting = false;

  final List<String> _kategoriList = [
    'Karakter & Kedisiplinan',
    'Sosial & Psikologis',
    'Akademik',
    'Minat & Bakat / Ekskul',
  ];

  @override
  void initState() {
    super.initState();
    // Default: seluruh siswa aktif terpilih untuk bimbingan klasikal
    for (final s in widget.siswaList) {
      _selectedStudentIds.add(s.studentId);
    }
  }

  @override
  void dispose() {
    _uraianController.dispose();
    _rtlController.dispose();
    super.dispose();
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedStudentIds.length == widget.siswaList.length) {
        _selectedStudentIds.clear();
      } else {
        _selectedStudentIds.clear();
        for (final s in widget.siswaList) {
          _selectedStudentIds.add(s.studentId);
        }
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      helpText: 'Pilih Tanggal Sesi Klasikal',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Pilih Waktu Sesi Klasikal',
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
    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu siswa peserta bimbingan klasikal.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.service.storeKlasikalJurnal(
        tanggalWaktu: _combinedDateTime,
        jenisPendampingan: _jenis,
        kategoriPendampingan: _kategori,
        uraianPembahasan: _uraianController.text.trim(),
        rujukanKolaborasi: _rujukanKolaborasi,
        studentIds: _selectedStudentIds.toList(),
        rencanaTindakLanjut: _rtlController.text.trim().isNotEmpty
            ? _rtlController.text.trim()
            : null,
        statusSesi: _statusSesi,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bimbingan klasikal untuk ${_selectedStudentIds.length} siswa berhasil disimpan!',
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
              'Catat Bimbingan Klasikal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '${_selectedStudentIds.length} dari ${widget.siswaList.length} siswa terpilih',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
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
              KlasikalStudentSelectorCard(
                siswaList: widget.siswaList,
                selectedStudentIds: _selectedStudentIds,
                onToggleSelectAll: _toggleSelectAll,
                onStudentToggled: (studentId, selected) {
                  setState(() {
                    if (selected) {
                      _selectedStudentIds.add(studentId);
                    } else {
                      _selectedStudentIds.remove(studentId);
                    }
                  });
                },
              ),
              const SizedBox(height: 18),
              KlasikalDatetimePickerRow(
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                onPickDate: _pickDate,
                onPickTime: _pickTime,
              ),
              const SizedBox(height: 18),
              KlasikalParameterForm(
                jenis: _jenis,
                kategori: _kategori,
                kategoriList: _kategoriList,
                onJenisChanged: (val) {
                  if (val != null) setState(() => _jenis = val);
                },
                onKategoriChanged: (val) {
                  if (val != null) setState(() => _kategori = val);
                },
                uraianController: _uraianController,
                rtlController: _rtlController,
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
                      : Text(
                          'Simpan Bimbingan Klasikal (${_selectedStudentIds.length} Siswa)',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

typedef FormJurnalKlasikalScreen = ModalJurnalKlasikal;
