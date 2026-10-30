import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../models/guru_wali_dashboard_model.dart';
import '../../../services/guru_wali_service.dart';

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
  String _statusSesi = 'Tuntas / Selesai';
  String _rujukanKolaborasi = 'Mandiri';

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
    final allSelected = _selectedStudentIds.length == widget.siswaList.length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.groups_rounded, color: Color(0xFF2563EB), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catat Bimbingan Klasikal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
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
                    // Checklist Siswa Peserta Sesi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Siswa Peserta *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _toggleSelectAll,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: Icon(
                            allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
                            size: 16,
                          ),
                          label: Text(
                            allSelected ? 'Batal Semua' : 'Pilih Semua',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Kotak Daftar Siswa dengan Checkbox
                    Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.siswaList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        itemBuilder: (context, index) {
                          final s = widget.siswaList[index];
                          final isChecked = _selectedStudentIds.contains(s.studentId);
                          return CheckboxListTile(
                            dense: true,
                            value: isChecked,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            title: Text(
                              s.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            subtitle: Text(
                              '${s.kelasName} • NISN: ${s.nisn}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                            activeColor: const Color(0xFF2563EB),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedStudentIds.add(s.studentId);
                                } else {
                                  _selectedStudentIds.remove(s.studentId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Tanggal & Waktu Bimbingan
                    const Text(
                      'Tanggal & Waktu Sesi Klasikal',
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
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF2563EB)),
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
                                  const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF2563EB)),
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

                    // Jenis & Pilar Bimbingan
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bentuk Sesi',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _jenis,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Klasikal', child: Text('Klasikal', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'Kelompok Kecil', child: Text('Kelompok Kecil', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _jenis = val);
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
                                'Pilar Bimbingan',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _kategori,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                                items: _kategoriList.map((kat) {
                                  return DropdownMenuItem<String>(
                                    value: kat,
                                    child: Text(kat, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _kategori = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Uraian Pembahasan & Respon Kelompok
                    const Text(
                      'Materi & Respon Kelompok *',
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
                        hintText: 'Tuliskan topik bimbingan klasikal, materi sosialisasi, atau dinamika kelompok...',
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

                    // Rencana Tindak Lanjut Kelompok
                    const Text(
                      'Rencana Tindak Lanjut Kelompok',
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
                        hintText: 'Langkah monitoring atau tugas kelompok bersama...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
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
          ),
        ],
      ),
    );
  }
}
