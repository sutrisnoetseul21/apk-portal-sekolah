import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card pembaruan status & tindak lanjut investigasi SPIKAP oleh guru
class SpikapDetailUpdateStatusCard extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final TextEditingController catatanController;
  final bool notifyWa;
  final ValueChanged<bool> onNotifyWaChanged;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const SpikapDetailUpdateStatusCard({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.catatanController,
    required this.notifyWa,
    required this.onNotifyWaChanged,
    required this.isSubmitting,
    required this.onSubmit,
  });

  Widget _buildStatusOption({
    required String key,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = selectedStatus == key;
    return Expanded(
      child: InkWell(
        onTap: () => onStatusChanged(key),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.12) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 8),
              Text(
                'Tindak Lanjut & Pembaruan Status',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pilihan Status
          Text(
            'Ubah Status Kasus:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusOption(
                key: 'diterima',
                label: 'Diterima',
                activeColor: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              _buildStatusOption(
                key: 'dalam_investigasi',
                label: 'Investigasi',
                activeColor: const Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              _buildStatusOption(
                key: 'selesai',
                label: 'Selesai',
                activeColor: const Color(0xFF059669),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Catatan Penanganan
          Text(
            'Catatan Investigasi / Perkembangan Kasus:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: catatanController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Contoh: Korban dan pelaku sudah dipanggil ke ruang BK, mediasi kekeluargaan dilakukan...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
              fillColor: const Color(0xFFF8FAFC),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 10),

          // Checkbox Notifikasi WA
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: notifyWa,
                  onChanged: (val) => onNotifyWaChanged(val ?? true),
                  activeColor: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kirim notifikasi otomatis via WhatsApp ke siswa & wali murid',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(
                isSubmitting
                    ? 'Menyimpan Perubahan...'
                    : 'Simpan Pembaruan Kasus',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

