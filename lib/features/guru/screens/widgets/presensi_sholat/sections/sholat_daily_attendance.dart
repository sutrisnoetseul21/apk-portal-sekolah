import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/screens/detail_presensi_siswa_screen.dart';

/// Seksi Daftar Presensi Siswa Harian:
/// - Search Bar (Cari nama / NISN)
/// - Filter Chips horizontal (Semua, Belum, Hadir, Ijin, Tidak Hadir, Non-Muslim)
/// - Banner Tuntas jika tidak ada siswa yang belum absen
/// - Kartu individual siswa dengan status, waktu sholat, opsi WA ortu & edit modal
class SholatDailyAttendance extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final int total;
  final int belum;
  final int hadir;
  final int ijin;
  final int tidakHadir;
  final int nonMuslimCount;
  final String dailyFilter;
  final ValueChanged<String> onDailyFilterChanged;
  final List<Map<String, dynamic>> filteredStudents;
  final bool isNotifSholatActive;
  final String? token;
  final String? identifier;
  final ValueChanged<Map<String, dynamic>> onOpenWaModal;
  final ValueChanged<Map<String, dynamic>> onOpenSingleStudentModal;

  const SholatDailyAttendance({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.total,
    required this.belum,
    required this.hadir,
    required this.ijin,
    required this.tidakHadir,
    required this.nonMuslimCount,
    required this.dailyFilter,
    required this.onDailyFilterChanged,
    required this.filteredStudents,
    required this.isNotifSholatActive,
    this.token,
    this.identifier,
    required this.onOpenWaModal,
    required this.onOpenSingleStudentModal,
  });

  static const Color _emeraldPrimary = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kolom Pencarian Nama / NISN
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Cari nama siswa atau NISN...',
            hintStyle: const TextStyle(fontSize: 12.5),
            prefixIcon: const Icon(Icons.search_rounded, size: 19),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: onClearSearch,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Filter Chips Horizontal
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Semua',
                count: total,
                filterKey: 'all',
                activeColor: const Color(0xFF1E293B),
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                label: 'Belum Sholat',
                count: belum,
                filterKey: 'belum',
                activeColor: const Color(0xFF4F46E5),
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                label: 'Hadir Berjamaah',
                count: hadir,
                filterKey: 'hadir',
                activeColor: _emeraldPrimary,
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                label: 'Ijin / Halangan',
                count: ijin,
                filterKey: 'ijin',
                activeColor: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 6),
              _buildFilterChip(
                label: 'Tidak Hadir',
                count: tidakHadir,
                filterKey: 'tidak_hadir',
                activeColor: const Color(0xFFE11D48),
              ),
              if (nonMuslimCount > 0) ...[
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Non-Muslim',
                  count: nonMuslimCount,
                  filterKey: 'non_muslim',
                  activeColor: const Color(0xFF6366F1),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Banner Spesial jika Filter 'belum' dipilih & belum == 0
        if (dailyFilter == 'belum' && belum == 0)
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Colors.white, Color(0xFFF0FDFA)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _emeraldPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Alhamdulillah! Seluruh Siswa Sudah Terdata',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seluruh $total siswa wajib sholat telah tercatat statusnya pada tanggal ini.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _emeraldPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => onDailyFilterChanged('all'),
                  child: const Text(
                    'Tampilkan Semua Siswa',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),

        // Daftar Kartu Siswa Harian
        if (filteredStudents.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'Tidak ada siswa yang sesuai dengan saringan ini.',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...filteredStudents.map((st) => _buildStudentDailyCard(context, st)),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required String filterKey,
    required Color activeColor,
  }) {
    final isSelected = dailyFilter == filterKey;
    return GestureDetector(
      onTap: () {
        onDailyFilterChanged(
          (dailyFilter == filterKey && filterKey != 'all') ? 'all' : filterKey,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDailyCard(BuildContext context, Map<String, dynamic> student) {
    final id = student['id']?.toString() ?? '';
    final name = student['name']?.toString() ?? '-';
    final initials = student['initials']?.toString() ??
        (name.length >= 2
            ? name.substring(0, 2).toUpperCase()
            : name.toUpperCase());
    final nisn = student['nisn']?.toString() ?? '-';
    final gender = student['gender']?.toString() ?? 'L';
    final isNonMuslim = student['is_non_muslim'] == true;

    final today = student['today'] is Map
        ? Map<String, dynamic>.from(student['today'] as Map)
        : <String, dynamic>{};
    final status =
        isNonMuslim ? 'non_muslim' : (today['status'] ?? 'belum').toString();
    final isHalangan = today['is_halangan'] == true ||
        (today['keterangan']?.toString().toLowerCase().contains('haid') ??
            false) ||
        (today['keterangan']?.toString().toLowerCase().contains('halangan') ??
            false);
    final keterangan = today['keterangan']?.toString();
    final time = today['time']?.toString();

    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    if (status == 'non_muslim') {
      badgeBg = const Color(0xFFE0E7FF);
      badgeText = const Color(0xFF4338CA);
      badgeLabel = 'Non-Muslim';
    } else if (status == 'hadir') {
      badgeBg = const Color(0xFFD1FAE5);
      badgeText = const Color(0xFF065F46);
      badgeLabel = time != null && time.isNotEmpty
          ? 'Hadir ($time)'
          : 'Hadir Berjamaah';
    } else if (status == 'ijin') {
      badgeBg = isHalangan ? const Color(0xFFFCE7F3) : const Color(0xFFDBEAFE);
      badgeText =
          isHalangan ? const Color(0xFF9D174D) : const Color(0xFF1E40AF);
      badgeLabel = isHalangan ? 'Halangan / Haid' : 'Ijin / Sakit';
    } else if (status == 'tidak_hadir') {
      badgeBg = const Color(0xFFFFE4E6);
      badgeText = const Color(0xFF9F1239);
      badgeLabel = 'Tidak Hadir';
    } else {
      badgeBg = const Color(0xFFF1F5F9);
      badgeText = const Color(0xFF475569);
      badgeLabel = 'Belum Sholat';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Inisial
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: badgeText,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'NISN: $nisn',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          gender == 'P' ? 'Perempuan' : 'Laki-laki',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: gender == 'P'
                                ? const Color(0xFFDB2777)
                                : const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),

          // Keterangan jika ada (misal: Halangan / Haid, Izin di presensi pagi)
          if (keterangan != null && keterangan.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Text(
                'Keterangan: $keterangan',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Footer Aksi Cepat: Detail Siswa | WA Ortu + Input Presensi (Pop-up 1 Siswa)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (id.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailPresensiSiswaScreen(
                          studentId: id,
                          studentName: name,
                          token: token,
                          identifier: identifier,
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      Text(
                        'Detail Siswa',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (isNonMuslim)
                const Text(
                  'Tidak Wajib Sholat',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                )
              else
                Row(
                  children: [
                    if ((status == 'belum' || status == 'tidak_hadir') &&
                        isNotifSholatActive) ...[
                      InkWell(
                        onTap: () => onOpenWaModal(student),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 13,
                                color: Color(0xFF047857),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'WA Ortu',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Tombol Input Presensi / Ubah -> Membuka Pop-Up Khusus 1 Siswa Ini Saja!
                    InkWell(
                      onTap: () => onOpenSingleStudentModal(student),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (status == 'belum' || status == 'tidak_hadir')
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                (status == 'belum' || status == 'tidak_hadir')
                                    ? const Color(0xFF6EE7B7)
                                    : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          (status == 'belum' || status == 'tidak_hadir')
                              ? 'Input Presensi'
                              : 'Ubah',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color:
                                (status == 'belum' || status == 'tidak_hadir')
                                    ? const Color(0xFF065F46)
                                    : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

