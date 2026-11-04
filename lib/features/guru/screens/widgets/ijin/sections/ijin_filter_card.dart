import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Kartu Filter Kelas, Bulan Pengajuan, dan Pencarian Siswa
class IjinFilterCard extends StatelessWidget {
  final List<Map<String, dynamic>> accessibleClasses;
  final String? selectedClassId;
  final ValueChanged<String?> onClassChanged;
  final List<Map<String, dynamic>> availableMonths;
  final String? selectedMonthKey;
  final ValueChanged<String?> onMonthChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchCleared;

  const IjinFilterCard({
    super.key,
    required this.accessibleClasses,
    required this.selectedClassId,
    required this.onClassChanged,
    required this.availableMonths,
    required this.selectedMonthKey,
    required this.onMonthChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchSubmitted,
    required this.onSearchCleared,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasMultipleClasses = accessibleClasses.length > 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 1. Filter Kelas
              Expanded(
                child: hasMultipleClasses
                    ? DropdownButtonFormField<String>(
                        value: (selectedClassId != null &&
                                accessibleClasses.any((c) =>
                                    c['id']?.toString() == selectedClassId))
                            ? selectedClassId
                            : '',
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'PILIH KELAS',
                          labelStyle: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                          prefixIcon:
                              const Icon(Icons.class_rounded, size: 16),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('Semua Kelas',
                                style: TextStyle(fontSize: 12)),
                          ),
                          ...accessibleClasses.map(
                            (c) => DropdownMenuItem<String>(
                              value: c['id']?.toString() ?? '',
                              child: Text(
                                'Kelas ${c['name'] ?? ''} (${c['access_label'] ?? 'Kelas'})',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: onClassChanged,
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.class_rounded,
                                size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'KELAS BINAAN',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF64748B)),
                                  ),
                                  Text(
                                    accessibleClasses.isNotEmpty
                                        ? 'Kelas ${accessibleClasses.first['name'] ?? '-'} (${accessibleClasses.first['access_label'] ?? 'Kelas'})'
                                        : 'Belum Ada Kelas',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(width: 10),

              // 2. Filter Bulan
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedMonthKey,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'BULAN PENGAJUAN',
                    labelStyle: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                    prefixIcon:
                        const Icon(Icons.calendar_month_rounded, size: 16),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: availableMonths
                      .map(
                        (m) => DropdownMenuItem<String>(
                          value: m['key']?.toString(),
                          child: Text(
                            m['label']?.toString() ?? '',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onMonthChanged,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3. Kolom Pencarian Siswa
          TextField(
            controller: searchController,
            style: const TextStyle(fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'Cari nama siswa atau NISN...',
              hintStyle:
                  const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: onSearchCleared,
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onSubmitted: onSearchSubmitted,
          ),
        ],
      ),
    );
  }
}

