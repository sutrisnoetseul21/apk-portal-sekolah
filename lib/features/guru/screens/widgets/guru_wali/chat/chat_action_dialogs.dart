import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/services/guru_wali_service.dart';

class ChatActionDialogs {
  static Future<bool> showJadwalkanDialog({
    required BuildContext context,
    required GuruWaliService service,
    required String konsultasiId,
  }) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    final catatanController = TextEditingController(
      text: 'Pertemuan tatap muka di ruang Guru Wali.',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Text(
                    'Jadwalkan Tatap Muka',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Waktu Pertemuan:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (picked != null) {
                                setDialogState(() => selectedDate = picked);
                              }
                            },
                            child: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setDialogState(() => selectedTime = picked);
                              }
                            },
                            child: Text(selectedTime.format(ctx)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pesan / Catatan untuk Murid:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: catatanController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Misal: Temui Bapak di ruang guru pada jam istirahat pertama...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Simpan Jadwal'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final combined = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      try {
        await service.jadwalkanKonsultasi(
          konsultasiId: konsultasiId,
          jadwalPasti: combined,
          tanggapan: catatanController.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jadwal pertemuan tatap muka berhasil ditetapkan.'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return true;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menetapkan jadwal: $e'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
    return false;
  }

  static Future<bool> showTolakDialog({
    required BuildContext context,
    required GuruWaliService service,
    required String konsultasiId,
  }) async {
    final alasanController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text('Tolak Permohonan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alasan Penolakan *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: alasanController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Jelaskan alasan penolakan bimbingan ini kepada murid...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (alasanController.text.trim().length >= 3) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await service.tolakKonsultasi(
          konsultasiId: konsultasiId,
          alasanPenolakan: alasanController.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permohonan konsultasi telah ditolak.'),
              backgroundColor: Color(0xFFE11D48),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return true;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menolak: $e'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
    return false;
  }

  static Future<bool> showKonversiJurnalDialog({
    required BuildContext context,
    required GuruWaliService service,
    required String konsultasiId,
  }) async {
    String statusSesi = 'Tuntas / Selesai';
    String rujukan = 'Mandiri';
    final rtlController = TextEditingController(
      text: 'Pemantauan berkala karakter dan kenyamanan belajar.',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.auto_stories_rounded, color: Color(0xFF16A34A)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '1-Klik Konversi ke Jurnal',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Percakapan cerita ini akan langsung disalin menjadi Catatan Jurnal Bimbingan resmi.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    const Text('Status Sesi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: statusSesi,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Tuntas / Selesai', child: Text('Tuntas / Selesai', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Dalam Pemantauan', child: Text('Dalam Pemantauan', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Bimbingan Lanjutan', child: Text('Bimbingan Lanjutan', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => statusSesi = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Rujukan Kolaborasi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: rujukan,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Mandiri', child: Text('Mandiri (Guru Wali)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Wali Kelas', child: Text('Wali Kelas', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Guru BK', child: Text('Guru BK', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Orang Tua / Wali', child: Text('Orang Tua / Wali', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => rujukan = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Rencana Tindak Lanjut:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: rtlController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Konversi Sekarang'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      try {
        await service.konversiKonsultasiKeJurnal(
          konsultasiId: konsultasiId,
          statusSesi: statusSesi,
          rujukanKolaborasi: rujukan,
          rencanaTindakLanjut: rtlController.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konsultasi berhasil dikonversi menjadi Jurnal Bimbingan resmi!'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return true;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal konversi ke jurnal: $e'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
    return false;
  }
}
