/// Model Filter, Opsi Kelas & Statistik Rombel untuk Menu 6 Data Siswa

class AcademicYearOption {
  final String id;
  final String name;
  final String semester;
  final bool isActive;

  AcademicYearOption({
    required this.id,
    required this.name,
    this.semester = '',
    required this.isActive,
  });

  factory AcademicYearOption.fromJson(Map<String, dynamic> json) {
    return AcademicYearOption(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      semester: (json['semester'] ?? '').toString(),
      isActive: json['is_active'] == true,
    );
  }
}

class ClassOption {
  final String id;
  final String name;
  final String fullName;
  final String? academicYearId;
  final bool isWaliKelas;

  ClassOption({
    required this.id,
    required this.name,
    required this.fullName,
    this.academicYearId,
    required this.isWaliKelas,
  });

  factory ClassOption.fromJson(Map<String, dynamic> json) {
    final accessType = json['access_type']?.toString();
    final isWali = accessType == 'wali_kelas' || json['is_wali_kelas'] == true;
    return ClassOption(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      fullName: (json['access_label'] ?? json['full_name'] ?? json['name'] ?? '').toString(),
      academicYearId: json['academic_year_id']?.toString(),
      isWaliKelas: isWali,
    );
  }
}

class StudentRombelStats {
  final int totalStudents;
  final int lakiLaki;
  final int perempuan;
  final int berbarcode;
  final int belumBarcode;
  final int lengkapNohp;
  final num persenBerbarcode;

  StudentRombelStats({
    required this.totalStudents,
    required this.lakiLaki,
    required this.perempuan,
    required this.berbarcode,
    required this.belumBarcode,
    required this.lengkapNohp,
    required this.persenBerbarcode,
  });

  factory StudentRombelStats.fromJson(Map<String, dynamic> json) {
    final total = (json['total'] ?? json['total_students'] as num?)?.toInt() ?? 0;
    final laki = (json['laki'] ?? json['laki_laki'] as num?)?.toInt() ?? 0;
    final peremp = (json['perempuan'] as num?)?.toInt() ?? 0;
    final berbc = (json['berbarcode'] as num?)?.toInt() ?? 0;
    final belumBc = (json['belum_barcode'] as num?)?.toInt() ?? (total - berbc);
    final lkpNohp = (json['lengkap_nohp'] as num?)?.toInt() ?? 0;
    final persen = (json['persen_berbarcode'] as num?) ?? (total > 0 ? ((berbc / total) * 100).round() : 0);

    return StudentRombelStats(
      totalStudents: total,
      lakiLaki: laki,
      perempuan: peremp,
      berbarcode: berbc,
      belumBarcode: belumBc,
      lengkapNohp: lkpNohp,
      persenBerbarcode: persen,
    );
  }
}

class DataSiswaOptionsModel {
  final Map<String, dynamic>? guru;
  final List<AcademicYearOption> academicYears;
  final List<ClassOption> classes;
  final String? activeAcademicYearId;
  final String? defaultClassId;

  DataSiswaOptionsModel({
    this.guru,
    required this.academicYears,
    required this.classes,
    this.activeAcademicYearId,
    this.defaultClassId,
  });

  factory DataSiswaOptionsModel.fromJson(Map<String, dynamic> json) {
    final ayList = (json['academic_years'] as List<dynamic>?)
            ?.map((e) => AcademicYearOption.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final cList = (json['classes'] as List<dynamic>?)
            ?.map((e) => ClassOption.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final defaultAy = (json['selected_academic_year_id'] ?? json['active_academic_year_id'])?.toString();
    final defaultC = (json['selected_class_id'] ?? json['default_class_id'])?.toString();

    return DataSiswaOptionsModel(
      guru: (json['teacher'] ?? json['guru']) as Map<String, dynamic>?,
      academicYears: ayList,
      classes: cList,
      activeAcademicYearId: defaultAy,
      defaultClassId: defaultC,
    );
  }
}
