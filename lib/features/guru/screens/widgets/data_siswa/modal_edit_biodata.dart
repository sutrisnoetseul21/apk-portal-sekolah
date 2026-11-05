import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/student_model.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/services/data_siswa_service.dart';
import 'edit_biodata/tab_edit_identitas.dart';
import 'edit_biodata/tab_edit_sekolah_keluarga.dart';
import 'edit_biodata/tab_edit_orang_tua.dart';

/// Modal Form Lengkap Edit Biodata Siswa dan Penggantian Foto
class ModalEditBiodataSheet extends StatefulWidget {
  final StudentModel student;
  final DataSiswaService service;
  final Function(StudentModel updatedStudent) onSuccess;

  const ModalEditBiodataSheet({
    super.key,
    required this.student,
    required this.service,
    required this.onSuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required StudentModel student,
    required DataSiswaService service,
    required Function(StudentModel updatedStudent) onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: ModalEditBiodataSheet(
          student: student,
          service: service,
          onSuccess: onSuccess,
        ),
      ),
    );
  }

  @override
  State<ModalEditBiodataSheet> createState() => _ModalEditBiodataSheetState();
}

class _ModalEditBiodataSheetState extends State<ModalEditBiodataSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isUploadingFoto = false;
  String? _errorMessage;
  String? _currentFotoUrl;

  // Controllers Identitas
  late final TextEditingController _namaController;
  late String _gender;
  late String _religion;
  late final TextEditingController _birthPlaceController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _addressController;

  // Controllers Sekolah & Keluarga
  late final TextEditingController _previousSchoolController;
  late final TextEditingController _admissionDateController;
  late final TextEditingController _admissionClassController;
  late final TextEditingController _familyStatusController;
  late final TextEditingController _childOrderController;

  // Controllers Orang Tua
  late final TextEditingController _namaAyahController;
  late final TextEditingController _pekerjaanAyahController;
  late final TextEditingController _namaIbuController;
  late final TextEditingController _pekerjaanIbuController;
  late final TextEditingController _namaWaliController;
  late final TextEditingController _pekerjaanWaliController;
  late final TextEditingController _noHpController;
  late final TextEditingController _noHpOrtuController;

  final List<String> _religionOptions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Khonghucu',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentFotoUrl = widget.student.fotoUrl;

    // Inisialisasi Identitas
    _namaController = TextEditingController(text: widget.student.nama);
    _gender = (widget.student.gender.toUpperCase() == 'P') ? 'P' : 'L';
    _religion = _religionOptions.contains(widget.student.religion)
        ? widget.student.religion
        : 'Islam';
    _birthPlaceController =
        TextEditingController(text: widget.student.birthPlace ?? '');
    _birthDateController =
        TextEditingController(text: widget.student.birthDate ?? '');
    _addressController =
        TextEditingController(text: widget.student.address ?? '');

    // Inisialisasi Sekolah & Keluarga
    _previousSchoolController =
        TextEditingController(text: widget.student.previousSchool ?? '');
    _admissionDateController =
        TextEditingController(text: widget.student.admissionDate ?? '');
    _admissionClassController =
        TextEditingController(text: widget.student.admissionClass ?? '');
    _familyStatusController =
        TextEditingController(text: widget.student.familyStatus ?? '');
    _childOrderController = TextEditingController(
      text: widget.student.childOrder?.toString() ?? '',
    );

    // Inisialisasi Ortu
    _namaAyahController =
        TextEditingController(text: widget.student.namaAyah ?? '');
    _pekerjaanAyahController =
        TextEditingController(text: widget.student.pekerjaanAyah ?? '');
    _namaIbuController =
        TextEditingController(text: widget.student.namaIbu ?? '');
    _pekerjaanIbuController =
        TextEditingController(text: widget.student.pekerjaanIbu ?? '');
    _namaWaliController =
        TextEditingController(text: widget.student.namaWali ?? '');
    _pekerjaanWaliController =
        TextEditingController(text: widget.student.pekerjaanWali ?? '');
    _noHpController = TextEditingController(text: widget.student.noHp ?? '');
    _noHpOrtuController =
        TextEditingController(text: widget.student.noHpOrangTua ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _namaController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _previousSchoolController.dispose();
    _admissionDateController.dispose();
    _admissionClassController.dispose();
    _familyStatusController.dispose();
    _childOrderController.dispose();
    _namaAyahController.dispose();
    _pekerjaanAyahController.dispose();
    _namaIbuController.dispose();
    _pekerjaanIbuController.dispose();
    _namaWaliController.dispose();
    _pekerjaanWaliController.dispose();
    _noHpController.dispose();
    _noHpOrtuController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploadingFoto = true;
      });

      final Uint8List bytes = await image.readAsBytes();
      final newUrl = await widget.service.uploadFoto(
        widget.student.id,
        bytes,
        image.name,
      );

      if (!mounted) return;
      setState(() {
        _currentFotoUrl = newUrl;
        _isUploadingFoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil siswa berhasil diperbarui'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploadingFoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime initial =
        DateTime.tryParse(controller.text) ?? DateTime(2010, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _handleSave() async {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      setState(() {
        _errorMessage = 'Nama lengkap siswa wajib diisi';
      });
      _tabController.animateTo(0);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payload = {
        'nama': nama,
        'gender': _gender,
        'religion': _religion,
        'birth_place': _birthPlaceController.text.trim(),
        'birth_date': _birthDateController.text.trim(),
        'address': _addressController.text.trim(),
        'previous_school': _previousSchoolController.text.trim(),
        'admission_date': _admissionDateController.text.trim(),
        'admission_class': _admissionClassController.text.trim(),
        'family_status': _familyStatusController.text.trim(),
        'child_order': int.tryParse(_childOrderController.text.trim()),
        'nama_ayah': _namaAyahController.text.trim(),
        'pekerjaan_ayah': _pekerjaanAyahController.text.trim(),
        'nama_ibu': _namaIbuController.text.trim(),
        'pekerjaan_ibu': _pekerjaanIbuController.text.trim(),
        'nama_wali': _namaWaliController.text.trim(),
        'pekerjaan_wali': _pekerjaanWaliController.text.trim(),
        'no_hp': _noHpController.text.trim(),
        'no_hp_orang_tua': _noHpOrtuController.text.trim(),
      };

      final updated = await widget.service.updateBiodata(
        widget.student.id,
        payload,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      widget.onSuccess(updated.copyWith(fotoUrl: _currentFotoUrl));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biodata siswa berhasil diperbarui'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    color: Color(0xFF2563EB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Biodata Siswa',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'NISN: ${widget.student.nisn} • NIS: ${widget.student.nis}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF2563EB),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Identitas'),
              Tab(text: 'Sekolah'),
              Tab(text: 'Orang Tua'),
            ],
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Tab View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TabEditIdentitas(
                  currentFotoUrl: _currentFotoUrl,
                  isUploadingFoto: _isUploadingFoto,
                  onPickAndUploadPhoto: _pickAndUploadPhoto,
                  namaController: _namaController,
                  gender: _gender,
                  onGenderChanged: (val) => setState(() => _gender = val),
                  religion: _religion,
                  religionOptions: _religionOptions,
                  onReligionChanged: (val) => setState(() => _religion = val),
                  birthPlaceController: _birthPlaceController,
                  birthDateController: _birthDateController,
                  onSelectBirthDate: () => _selectDate(_birthDateController),
                  addressController: _addressController,
                ),
                TabEditSekolahKeluarga(
                  previousSchoolController: _previousSchoolController,
                  admissionDateController: _admissionDateController,
                  onSelectAdmissionDate: () =>
                      _selectDate(_admissionDateController),
                  admissionClassController: _admissionClassController,
                  familyStatusController: _familyStatusController,
                  childOrderController: _childOrderController,
                ),
                TabEditOrangTua(
                  namaAyahController: _namaAyahController,
                  pekerjaanAyahController: _pekerjaanAyahController,
                  namaIbuController: _namaIbuController,
                  pekerjaanIbuController: _pekerjaanIbuController,
                  namaWaliController: _namaWaliController,
                  pekerjaanWaliController: _pekerjaanWaliController,
                  noHpOrtuController: _noHpOrtuController,
                  noHpController: _noHpController,
                ),
              ],
            ),
          ),

          // Bottom Bar Simpan
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Simpan Perubahan Biodata',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
