import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../models/student_model.dart';
import '../../../services/data_siswa_service.dart';

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
        text: widget.student.childOrder?.toString() ?? '');

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
    DateTime initial = DateTime.tryParse(controller.text) ?? DateTime(2010, 1, 1);
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
          // Drag handle
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
                    color: const Color(0xFF2563EB).withOpacity(0.1),
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
                _buildTabIdentitas(),
                _buildTabSekolah(),
                _buildTabOrangTua(),
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

  // TAB 1: IDENTITAS & FOTO
  Widget _buildTabIdentitas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Profil Siswa Section
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade50,
                        border: Border.all(
                            color: const Color(0xFF2563EB), width: 2),
                      ),
                      child: ClipOval(
                        child: _isUploadingFoto
                            ? const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : (_currentFotoUrl != null &&
                                    _currentFotoUrl!.isNotEmpty)
                                ? Image.network(
                                    _currentFotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.person,
                                            size: 50, color: Colors.blue),
                                  )
                                : const Icon(Icons.person,
                                    size: 50, color: Colors.blue),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickAndUploadPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: _pickAndUploadPhoto,
                  icon: const Icon(Icons.photo_library, size: 16),
                  label: Text(
                    'Ganti Foto Siswa',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Nama Siswa
          _buildFieldLabel('Nama Lengkap Siswa *'),
          _buildTextField(_namaController, 'Nama lengkap...'),

          const SizedBox(height: 14),

          // Jenis Kelamin
          _buildFieldLabel('Jenis Kelamin *'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Laki-laki', style: TextStyle(fontSize: 13)),
                  value: 'L',
                  groupValue: _gender,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _gender = val!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Perempuan', style: TextStyle(fontSize: 13)),
                  value: 'P',
                  groupValue: _gender,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _gender = val!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Agama
          _buildFieldLabel('Agama *'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _religion,
                isExpanded: true,
                items: _religionOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _religion = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Tempat & Tanggal Lahir
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Tempat Lahir'),
                    _buildTextField(_birthPlaceController, 'Kota kelahiran...'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Tanggal Lahir'),
                    TextField(
                      controller: _birthDateController,
                      readOnly: true,
                      onTap: () => _selectDate(_birthDateController),
                      decoration: InputDecoration(
                        hintText: 'YYYY-MM-DD',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        suffixIcon: const Icon(Icons.calendar_today, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Alamat
          _buildFieldLabel('Alamat Tempat Tinggal'),
          TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Dusun, Desa, RT/RW, Kecamatan...',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: SEKOLAH & KELUARGA
  Widget _buildTabSekolah() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Sekolah Asal (SD / MI)'),
          _buildTextField(_previousSchoolController, 'Contoh: SDN 1 Kedungreja'),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Tanggal Masuk'),
                    TextField(
                      controller: _admissionDateController,
                      readOnly: true,
                      onTap: () => _selectDate(_admissionDateController),
                      decoration: InputDecoration(
                        hintText: 'YYYY-MM-DD',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        suffixIcon: const Icon(Icons.calendar_month, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Diterima di Kelas'),
                    _buildTextField(_admissionClassController, 'Contoh: 7A'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Status dalam Keluarga'),
                    _buildTextField(
                        _familyStatusController, 'Anak Kandung/Tiri...'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Anak Ke-'),
                    _buildTextField(_childOrderController, '1',
                        keyboardType: TextInputType.number),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 3: ORANG TUA / WALI & KONTAK
  Widget _buildTabOrangTua() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Nama Ayah Kandung'),
          _buildTextField(_namaAyahController, 'Nama Ayah...'),

          const SizedBox(height: 10),

          _buildFieldLabel('Pekerjaan Ayah'),
          _buildTextField(_pekerjaanAyahController, 'Pekerjaan Ayah...'),

          const SizedBox(height: 16),

          _buildFieldLabel('Nama Ibu Kandung'),
          _buildTextField(_namaIbuController, 'Nama Ibu...'),

          const SizedBox(height: 10),

          _buildFieldLabel('Pekerjaan Ibu'),
          _buildTextField(_pekerjaanIbuController, 'Pekerjaan Ibu...'),

          const SizedBox(height: 16),

          _buildFieldLabel('Nama Wali (Jika Ada)'),
          _buildTextField(_namaWaliController, 'Nama Wali...'),

          const SizedBox(height: 10),

          _buildFieldLabel('Pekerjaan Wali'),
          _buildTextField(_pekerjaanWaliController, 'Pekerjaan Wali...'),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          _buildFieldLabel('Nomor HP / WhatsApp Orang Tua'),
          _buildTextField(_noHpOrtuController, '08xxxxxxxxxx',
              keyboardType: TextInputType.phone),

          const SizedBox(height: 12),

          _buildFieldLabel('Nomor HP / WhatsApp Siswa'),
          _buildTextField(_noHpController, '08xxxxxxxxxx',
              keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF94A3B8),
          fontSize: 13,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }
}
