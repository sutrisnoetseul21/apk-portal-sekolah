/// Data Simulasi Fallback untuk Presensi Sholat Dhuhur jika server lokal belum merespons
class PresensiSholatDemoData {
  static Map<String, dynamic> getFallbackData() {
    return {
      'academic_years': [
        {'id': 'ay-1', 'name': '2026/2027', 'is_active': true, 'is_locked': true},
      ],
      'selected_academic_year_id': 'ay-1',
      'selected_academic_year_name': '2026/2027',
      'classes': [
        {
          'id': 'cls-7a',
          'name': 'Kelas 7A',
          'access_type': 'wali_kelas',
          'access_label': 'Wali Kelas',
        },
      ],
      'selected_class_id': 'cls-7a',
      'selected_class_name': 'Kelas 7A',
      'selected_class_access_label': 'Wali Kelas',
      'available_months': [
        {'key': '10-2026', 'label': 'Oktober 2026'},
      ],
      'selected_month_year': '10-2026',
      'selected_month_label': 'Oktober 2026',
      'koordinators': [
        {'id': 'guru-pai-1', 'name': 'Drs. H. Asis, M.Pd.I', 'group': 'Guru PAI'},
      ],
      'selected_koordinator_id': 'guru-pai-1',
      'selected_daily_date': '2026-10-29',
      'today_date_label': 'Kamis, 29 Oktober 2026',
      'days_in_month': 31,
      'today_stats': {
        'hadir': 2,
        'ijin': 1,
        'tidak_hadir': 0,
        'belum': 1,
        'total': 4,
        'total_all': 4,
        'non_muslim_count': 0,
        'persentase_hadir': 50,
        'is_holiday': false,
      },
      'class_monthly_stats': {
        'hadir': 68,
        'ijin': 8,
        'tidak_hadir': 2,
        'effective_days': 20,
        'max_possible': 80,
        'total_students': 4,
        'class_percentage': 87.2,
      },
      'students': [
        {
          'id': 'st-1',
          'name': 'Ahmad Fauzi Pratama',
          'initials': 'AF',
          'nisn': '0098123401',
          'gender': 'L',
          'religion': 'Islam',
          'is_non_muslim': false,
          'phone_raw': '081234567801',
          'phone_clean': '6281234567801',
          'today': {
            'status': 'hadir',
            'ui_status': 'hadir',
            'is_halangan': false,
            'keterangan': null,
            'time': '12:14',
            'wa_text': '',
          },
          'monthly': {
            'hadir': 18,
            'ijin': 1,
            'tidak_hadir': 0,
            'persentase': 90,
            'is_non_muslim': false,
            'daily': {'1': 'H', '2': 'H', '3': 'L'},
          },
        },
        {
          'id': 'st-2',
          'name': 'Siti Aisyah Putri',
          'initials': 'SA',
          'nisn': '0098123402',
          'gender': 'P',
          'religion': 'Islam',
          'is_non_muslim': false,
          'phone_raw': '081234567802',
          'phone_clean': '6281234567802',
          'today': {
            'status': 'ijin',
            'ui_status': 'haid',
            'is_halangan': true,
            'keterangan': 'Halangan / Haid',
            'time': null,
            'wa_text': '',
          },
          'monthly': {
            'hadir': 15,
            'ijin': 4,
            'tidak_hadir': 0,
            'persentase': 75,
            'is_non_muslim': false,
            'daily': {'1': 'H', '2': 'I', '3': 'L'},
          },
        },
      ],
    };
  }
}

