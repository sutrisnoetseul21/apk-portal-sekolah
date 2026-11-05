import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/guru_wali_dashboard_model.dart';

/// Card checklist pemilihan siswa peserta bimbingan klasikal
class KlasikalStudentSelectorCard extends StatelessWidget {
  final List<SiswaAsuhModel> siswaList;
  final Set<String> selectedStudentIds;
  final VoidCallback onToggleSelectAll;
  final void Function(String studentId, bool selected) onStudentToggled;

  const KlasikalStudentSelectorCard({
    super.key,
    required this.siswaList,
    required this.selectedStudentIds,
    required this.onToggleSelectAll,
    required this.onStudentToggled,
  });

  @override
  Widget build(BuildContext context) {
    final allSelected = selectedStudentIds.length == siswaList.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              onPressed: onToggleSelectAll,
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
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF8FAFC),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: siswaList.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final s = siswaList[index];
              final isChecked = selectedStudentIds.contains(s.studentId);
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
                  onStudentToggled(s.studentId, val == true);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
