import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../models/guru_wali_dashboard_model.dart';
import '../../../services/guru_wali_service.dart';

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
  String _rujukanKolaborasi = 'Mandiri';
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
            id: createdId,
            alasanRujukan: _alasanBkController.text.trim().isNotEmpty
                ? _alasanBkController.text.trim()
                : 'Eskalasi bimbingan guru wali untuk penanganan khusus.',
            urgensi: _urgensiBk,
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
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  backgroundImage: widget.siswa.avatarUrl != null
                      ? NetworkImage(widget.siswa.avatarUrl!)
                      : null,
                  child: widget.siswa.avatarUrl == null
                      ? Text(
                          widget.siswa.name.isNotEmpty
                              ? widget.siswa.name[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catat Jurnal Individu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${widget.siswa.name} • ${widget.siswa.kelasName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Form Scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal & Waktu Bimbingan
                    const Text(
                      'Tanggal & Waktu Sesi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: Color(0xFF2563EB),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: Color(0xFF2563EB),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedTime.format(context),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Kategori Pendampingan (4 Pilar)
                    const Text(
                      'Pilar Bimbingan (Permendikdasmen 11/2025)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _kategori,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                      items: _kategoriList.map((kat) {
                        return DropdownMenuItem<String>(
                          value: kat,
                          child: Text(kat, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _kategori = val);
                      },
                    ),

                    const SizedBox(height: 18),

                    // Status Sesi & Rujukan Kolaborasi
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Sesi',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _statusSesi,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Tuntas / Selesai', child: Text('Tuntas', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'Dalam Pemantauan', child: Text('Pemantauan', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'Bimbingan Lanjutan', child: Text('Lanjutan', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _statusSesi = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sentimen Emosional',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _sentimen,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Positif', child: Text('🟢 Positif', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'Netral', child: Text('⚪ Netral', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'Negatif', child: Text('🔴 Cemas/Negatif', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _sentimen = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Uraian Masalah / Pembahasan
                    const Text(
                      'Uraian Pembahasan & Masalah *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _uraianController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan topik, dinamika perkembangan, atau hal yang dibahas...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 5) {
                          return 'Uraian bimbingan minimal 5 karakter.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Rencana Tindak Lanjut
                    const Text(
                      'Rencana Tindak Lanjut (RTL)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _rtlController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Langkah nyata yang disepakati untuk bimbingan berikutnya...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Digital Badge Karakter (Card Interaktif)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7).withValues(alpha: 0.35),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 22),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Apresiasi Digital Badge Karakter',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                              Switch(
                                value: _giveBadge,
                                activeColor: const Color(0xFFD97706),
                                onChanged: (val) => setState(() => _giveBadge = val),
                              ),
                            ],
                          ),
                          if (_giveBadge) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Pilih Karakter Terpuji:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _badgeOptions.map((b) {
                                final isSelected = _selectedBadge == b;
                                return ChoiceChip(
                                  label: Text(b, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : const Color(0xFF78350F))),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFFD97706),
                                  backgroundColor: Colors.white,
                                  onSelected: (_) => setState(() => _selectedBadge = b),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _catatanApresiasiController,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Pesan apresiasi penyemangat siswa...',
                                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFFDE68A)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Opsi Eskalasi Rujukan BK
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _rujukBk
                            ? const Color(0xFFFEE2E2).withValues(alpha: 0.5)
                            : const Color(0xFFF8FAFC),
                        border: Border.all(
                          color: _rujukBk ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.health_and_safety_rounded,
                                color: _rujukBk ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Eskalasi ke Guru BK (Kasus Khusus)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _rujukBk ? const Color(0xFF991B1B) : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                              Switch(
                                value: _rujukBk,
                                activeColor: const Color(0xFFDC2626),
                                onChanged: (val) => setState(() => _rujukBk = val),
                              ),
                            ],
                          ),
                          if (_rujukBk) ...[
                            const SizedBox(height: 10),
                            const Text(
                              'Tingkat Urgensi:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Rendah', style: TextStyle(fontSize: 11)),
                                  selected: _urgensiBk == 'rendah',
                                  onSelected: (_) => setState(() => _urgensiBk = 'rendah'),
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  label: const Text('Sedang', style: TextStyle(fontSize: 11)),
                                  selected: _urgensiBk == 'sedang',
                                  onSelected: (_) => setState(() => _urgensiBk = 'sedang'),
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  label: const Text('Darurat', style: TextStyle(fontSize: 11, color: Colors.white)),
                                  selected: _urgensiBk == 'darurat',
                                  selectedColor: const Color(0xFFDC2626),
                                  onSelected: (_) => setState(() => _urgensiBk = 'darurat'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _alasanBkController,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Alasan dan latar belakang rujukan ke BK...',
                                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tombol Submit
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
          ),
        ],
      ),
    );
  }
}
