import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

class IjinStudentParentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final void Function(String phone) onWhatsAppTap;

  const IjinStudentParentCard({
    super.key,
    required this.student,
    required this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    final studentName = student['name']?.toString() ?? 'Siswa';
    final className = student['class_name']?.toString() ?? '-';
    final nisn = student['nisn']?.toString() ?? '-';
    final parentName = student['parent_name']?.toString() ?? 'Orang Tua';
    final parentPhone = student['parent_phone']?.toString();
    final parentPhoneClean = student['parent_phone_clean']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text(
            'Profil Siswa & Kontak Orang Tua',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildRow('Nama Siswa', studentName),
              _buildRow('NISN / NIS', '$nisn / ${student['nis'] ?? '-'}'),
              _buildRow('Kelas', 'Kelas $className'),
              _buildRow('Orang Tua / Wali', parentName),
              if (parentPhone != null && parentPhone.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'No. WhatsApp Ortu',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    if (parentPhoneClean != null)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => onWhatsAppTap(parentPhoneClean),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 12),
                        label: Text(
                          parentPhone,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      Text(
                        parentPhone,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
