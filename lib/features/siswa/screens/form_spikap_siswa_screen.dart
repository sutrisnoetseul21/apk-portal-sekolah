import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_compress_util.dart';
import '../services/siswa_spikap_service.dart';
import 'widgets/form_spikap/sections/spikap_notice_banner.dart';
import 'widgets/form_spikap/sections/spikap_sifat_tujuan_selector.dart';
import 'widgets/form_spikap/sections/spikap_jenis_perundungan_selector.dart';
import 'widgets/form_spikap/sections/spikap_evidence_photo_uploader.dart';

/// Layar Formulir Lapor Pengaduan Baru SPIKAP Portal Siswa
class FormSpikapSiswaScreen extends StatefulWidget {
  final String identifier;
  final String studentName;
  final String schoolName;
  final String? token;

  const FormSpikapSiswaScreen({
    super.key,
    required this.identifier,
    required this.studentName,
    this.schoolName = '',
    this.token,
  });

  @override
  State<FormSpikapSiswaScreen> createState() => _FormSpikapSiswaScreenState();
}

class _FormSpikapSiswaScreenState extends State<FormSpikapSiswaScreen> {
  final _formKey = GlobalKey<FormState>();
  late SiswaSpikapService _service;

  // Form State
  String _sifatLaporan = 'biasa'; // 'biasa' | 'darurat'
  String _tujuanPenerima = 'guru_bk'; // 'guru_bk' | 'wali_kelas'
  String _jenisPerundungan = 'fisik'; // 'fisik', 'verbal', 'sosial', 'digital', 'lainnya'

  final TextEditingController _uraianController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  DateTime? _waktuKejadianDate;
  TimeOfDay? _waktuKejadianTime;

  // Lampiran Foto Terkompresi (Maks 5)
  final List<CompressedImageResult> _fotoAttachments = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _service = SiswaSpikapService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
  }

  @override
  void dispose() {
    _uraianController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _pickWaktuKejadian() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _waktuKejadianDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      helpText: 'Pilih Tanggal Kejadian',
      confirmText: 'Lanjut',
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _waktuKejadianTime ?? TimeOfDay.fromDateTime(now),
        helpText: 'Pilih Perkiraan Jam Kejadian',
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _waktuKejadianDate = pickedDate;
          _waktuKejadianTime = pickedTime;
        });
      }
    }
  }

  void _showFotoSourcePicker() {
    if (_fotoAttachments.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal lampiran 5 foto bukti.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Lampirkan Foto Bukti',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Foto akan dikompres otomatis hemat kuota (ala WhatsApp)',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB)),
                  ),
                  title: const Text('Ambil Foto Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Potret langsung bukti kejadian'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndCompressPhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF059669)),
                  ),
                  title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Ambil dari tangkapan layar / galeri'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndCompressPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndCompressPhoto(ImageSource source) async {
    final result = await ImageCompressUtil.pickAndCompressImage(source: source);
    if (result != null && mounted) {
      setState(() {
        _fotoAttachments.add(result);
      });
    }
  }

  void _confirmAndSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _sifatLaporan == 'darurat' ? Icons.warning_amber_rounded : Icons.shield_rounded,
              color: _sifatLaporan == 'darurat' ? const Color(0xFFE11D48) : const Color(0xFF2563EB),
            ),
            const SizedBox(width: 8),
            const Text('Kirim Pengaduan?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pastikan informasi yang Anda berikan adalah benar dan dapat dipertanggungjawabkan.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sifat: ${_sifatLaporan == 'darurat' ? '🚨 Darurat' : 'Biasa'}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Kategori: $_jenisPerundungan', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    'Penerima: ${_sifatLaporan == 'darurat' ? 'Kepala Sekolah & Tim TPPK' : (_tujuanPenerima == 'guru_bk' ? 'Guru BK' : 'Wali Kelas')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '🔒 Identitas Anda terlindungi dan kerahasiaan kasus ini dijamin penuh oleh pihak sekolah.',
              style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Periksa Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _sifatLaporan == 'darurat' ? const Color(0xFFE11D48) : const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _submitReport();
            },
            child: const Text('Ya, Kirim Laporan'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);

    String? waktuKejadianStr;
    if (_waktuKejadianDate != null && _waktuKejadianTime != null) {
      final dt = DateTime(
        _waktuKejadianDate!.year,
        _waktuKejadianDate!.month,
        _waktuKejadianDate!.day,
        _waktuKejadianTime!.hour,
        _waktuKejadianTime!.minute,
      );
      waktuKejadianStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    }

    try {
      final fotoXFiles = _fotoAttachments.map((e) => e.file).toList();

      await _service.submitLaporan(
        sifatLaporan: _sifatLaporan,
        jenisPerundungan: _jenisPerundungan,
        uraianKejadian: _uraianController.text.trim(),
        lokasiKejadian: _lokasiController.text.trim(),
        waktuKejadian: waktuKejadianStr,
        tujuanPenerima: _sifatLaporan == 'biasa' ? _tujuanPenerima : null,
        fotoBukti: fotoXFiles,
        videoBukti: null,
        identifier: widget.identifier,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan pengaduan Anda berhasil dikirim dan tersimpan dengan aman.'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text('*', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }

  Widget _buildLokasiField() {
    return TextFormField(
      controller: _lokasiController,
      decoration: InputDecoration(
        labelText: 'Lokasi Kejadian (Opsional)',
        hintText: 'Contoh: Kantin Belakang, Lorong Kelas 8, Lapangan Basket...',
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF64748B)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
    );
  }

  Widget _buildWaktuField() {
    String formatted = 'Pilih perkiraan tanggal & waktu kejadian...';
    if (_waktuKejadianDate != null && _waktuKejadianTime != null) {
      final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_waktuKejadianDate!);
      final timeStr =
          '${_waktuKejadianTime!.hour.toString().padLeft(2, '0')}:${_waktuKejadianTime!.minute.toString().padLeft(2, '0')} WIB';
      formatted = '$dateStr, $timeStr';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _pickWaktuKejadian,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                formatted,
                style: TextStyle(
                  fontSize: 13,
                  color: _waktuKejadianDate != null ? AppColors.textPrimary : Colors.grey.shade600,
                ),
              ),
            ),
            if (_waktuKejadianDate != null)
              IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                tooltip: 'Hapus Waktu',
                onPressed: () {
                  setState(() {
                    _waktuKejadianDate = null;
                    _waktuKejadianTime = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUraianField() {
    return TextFormField(
      controller: _uraianController,
      maxLines: 5,
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Uraian kejadian wajib diisi.';
        }
        if (val.trim().length < 20) {
          return 'Tuliskan uraian minimal 20 karakter agar jelas dan dapat ditindaklanjuti.';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Tuliskan secara jelas kronologi apa yang terjadi, siapa pihak yang terlibat, dan bagaimana kronologisnya...',
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Buat Laporan SPIKAP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Banner
              const SpikapNoticeBanner(),
              const SizedBox(height: 20),

              // 1. Sifat Laporan & Tujuan
              SpikapSifatTujuanSelector(
                sifatLaporan: _sifatLaporan,
                onSifatChanged: (sifat) => setState(() => _sifatLaporan = sifat),
                tujuanPenerima: _tujuanPenerima,
                onTujuanChanged: (tujuan) => setState(() => _tujuanPenerima = tujuan),
              ),
              const SizedBox(height: 20),

              // 2. Jenis Perundungan
              _buildSectionTitle(
                _sifatLaporan == 'biasa' ? '3. Jenis Perundungan' : '2. Jenis Perundungan',
                isRequired: true,
              ),
              const SizedBox(height: 8),
              SpikapJenisPerundunganSelector(
                selectedJenis: _jenisPerundungan,
                onJenisChanged: (jenis) => setState(() => _jenisPerundungan = jenis),
              ),
              const SizedBox(height: 20),

              // 3. Lokasi & Waktu
              _buildSectionTitle(
                _sifatLaporan == 'biasa' ? '4. Tempat & Waktu Kejadian' : '3. Tempat & Waktu Kejadian',
              ),
              const SizedBox(height: 8),
              _buildLokasiField(),
              const SizedBox(height: 12),
              _buildWaktuField(),
              const SizedBox(height: 20),

              // 4. Uraian Kejadian
              _buildSectionTitle(
                _sifatLaporan == 'biasa' ? '5. Ceritakan Kejadian' : '4. Ceritakan Kejadian',
                isRequired: true,
              ),
              const SizedBox(height: 8),
              _buildUraianField(),
              const SizedBox(height: 20),

              // 5. Lampiran Foto
              _buildSectionTitle(
                _sifatLaporan == 'biasa' ? '6. Bukti Foto (Opsional)' : '5. Bukti Foto (Opsional)',
              ),
              const SizedBox(height: 4),
              const Text(
                'Maksimal 5 foto bukti (kompresi otomatis ala WhatsApp, hemat ~95% kuota data). Upload video dinonaktifkan demi efisiensi kuota.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              SpikapEvidencePhotoUploader(
                fotoAttachments: _fotoAttachments,
                onAddPhoto: _showFotoSourcePicker,
                onRemovePhoto: (index) => setState(() => _fotoAttachments.removeAt(index)),
              ),
              const SizedBox(height: 30),

              // Tombol Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sifatLaporan == 'darurat' ? const Color(0xFFE11D48) : const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSubmitting ? null : _confirmAndSubmit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isSubmitting
                        ? 'Mengirim Laporan...'
                        : (_sifatLaporan == 'darurat' ? 'Kirim Laporan Darurat 🚨' : 'Kirim Laporan Pengaduan'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
