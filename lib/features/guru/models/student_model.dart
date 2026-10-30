/// Model Data Siswa untuk Menu 6 Data Siswa
class StudentModel {
  final String id;
  final String nisn;
  final String nis;
  final String nama;
  final String gender;
  final String genderLabel;
  final String religion;
  final String? birthPlace;
  final String? birthDate;
  final String birthInfo;
  final String? address;
  final String? previousSchool;
  final String? admissionDate;
  final String? admissionClass;
  final String? familyStatus;
  final int? childOrder;
  final String? namaAyah;
  final String? pekerjaanAyah;
  final String? namaIbu;
  final String? pekerjaanIbu;
  final String? namaWali;
  final String? pekerjaanWali;
  final String? noHp;
  final String? noHpOrangTua;
  final String? waHpSiswa;
  final String? waHpOrtu;
  final String? barcodeCode;
  final bool barcodeActive;
  final String barcodeStatus;
  final int? userId;
  final bool hasUserAccount;
  final String? userEmail;
  final String? fotoUrl;

  StudentModel({
    required this.id,
    required this.nisn,
    required this.nis,
    required this.nama,
    required this.gender,
    required this.genderLabel,
    required this.religion,
    this.birthPlace,
    this.birthDate,
    required this.birthInfo,
    this.address,
    this.previousSchool,
    this.admissionDate,
    this.admissionClass,
    this.familyStatus,
    this.childOrder,
    this.namaAyah,
    this.pekerjaanAyah,
    this.namaIbu,
    this.pekerjaanIbu,
    this.namaWali,
    this.pekerjaanWali,
    this.noHp,
    this.noHpOrangTua,
    this.waHpSiswa,
    this.waHpOrtu,
    this.barcodeCode,
    required this.barcodeActive,
    required this.barcodeStatus,
    this.userId,
    required this.hasUserAccount,
    this.userEmail,
    this.fotoUrl,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final g = (json['gender'] ?? '').toString();
    final gLabel = (json['gender_label'] ?? (g.toUpperCase() == 'L' ? 'Laki-laki' : (g.toUpperCase() == 'P' ? 'Perempuan' : ''))).toString();
    final bPlace = json['birth_place']?.toString();
    final bDate = json['birth_date']?.toString();
    var bInfo = (json['birth_info'] ?? '').toString();
    if (bInfo.isEmpty && (bPlace != null || bDate != null)) {
      bInfo = [bPlace, bDate].where((e) => e != null && e.isNotEmpty).join(', ');
    }

    final rawNoHp = json['no_hp']?.toString();
    final rawNoHpOrtu = json['no_hp_orang_tua']?.toString();

    String? sanitizeWa(String? raw) {
      if (raw == null || raw.trim().isEmpty) return null;
      var clean = raw.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.startsWith('08')) {
        clean = '628${clean.substring(2)}';
      }
      return clean.isNotEmpty ? clean : null;
    }

    final waSiswa = json['wa_hp_siswa']?.toString() ?? sanitizeWa(rawNoHp);
    final waOrtu = json['wa_hp_ortu']?.toString() ?? sanitizeWa(rawNoHpOrtu);

    return StudentModel(
      id: (json['id'] ?? '').toString(),
      nisn: (json['nisn'] ?? '').toString(),
      nis: (json['nis'] ?? '').toString(),
      nama: (json['name'] ?? json['nama'] ?? '').toString(),
      gender: g,
      genderLabel: gLabel,
      religion: (json['religion'] ?? '').toString(),
      birthPlace: bPlace,
      birthDate: bDate,
      birthInfo: bInfo,
      address: json['address']?.toString(),
      previousSchool: json['previous_school']?.toString(),
      admissionDate: json['admission_date']?.toString(),
      admissionClass: json['admission_class']?.toString(),
      familyStatus: json['family_status']?.toString(),
      childOrder: (json['child_order'] as num?)?.toInt(),
      namaAyah: json['nama_ayah']?.toString(),
      pekerjaanAyah: json['pekerjaan_ayah']?.toString(),
      namaIbu: json['nama_ibu']?.toString(),
      pekerjaanIbu: json['pekerjaan_ibu']?.toString(),
      namaWali: json['nama_wali']?.toString(),
      pekerjaanWali: json['pekerjaan_wali']?.toString(),
      noHp: rawNoHp,
      noHpOrangTua: rawNoHpOrtu,
      waHpSiswa: waSiswa,
      waHpOrtu: waOrtu,
      barcodeCode: json['barcode_code']?.toString(),
      barcodeActive: json['barcode_active'] == true,
      barcodeStatus: (json['barcode_status'] ?? (json['barcode_active'] == true ? 'Aktif' : 'Belum Ada')).toString(),
      userId: (json['user_id'] as num?)?.toInt(),
      hasUserAccount: json['has_user_account'] == true,
      userEmail: json['user_email']?.toString(),
      fotoUrl: json['photo_url']?.toString() ?? json['foto_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nisn': nisn,
      'nis': nis,
      'nama': nama,
      'gender': gender,
      'religion': religion,
      'birth_place': birthPlace,
      'birth_date': birthDate,
      'address': address,
      'previous_school': previousSchool,
      'admission_date': admissionDate,
      'admission_class': admissionClass,
      'family_status': familyStatus,
      'child_order': childOrder,
      'nama_ayah': namaAyah,
      'pekerjaan_ayah': pekerjaanAyah,
      'nama_ibu': namaIbu,
      'pekerjaan_ibu': pekerjaanIbu,
      'nama_wali': namaWali,
      'pekerjaan_wali': pekerjaanWali,
      'no_hp': noHp,
      'no_hp_orang_tua': noHpOrangTua,
    };
  }

  StudentModel copyWith({
    String? nama,
    String? noHp,
    String? noHpOrangTua,
    String? waHpSiswa,
    String? waHpOrtu,
    String? fotoUrl,
    String? barcodeCode,
    bool? barcodeActive,
    String? barcodeStatus,
  }) {
    return StudentModel(
      id: id,
      nisn: nisn,
      nis: nis,
      nama: nama ?? this.nama,
      gender: gender,
      genderLabel: genderLabel,
      religion: religion,
      birthPlace: birthPlace,
      birthDate: birthDate,
      birthInfo: birthInfo,
      address: address,
      previousSchool: previousSchool,
      admissionDate: admissionDate,
      admissionClass: admissionClass,
      familyStatus: familyStatus,
      childOrder: childOrder,
      namaAyah: namaAyah,
      pekerjaanAyah: pekerjaanAyah,
      namaIbu: namaIbu,
      pekerjaanIbu: pekerjaanIbu,
      namaWali: namaWali,
      pekerjaanWali: pekerjaanWali,
      noHp: noHp ?? this.noHp,
      noHpOrangTua: noHpOrangTua ?? this.noHpOrangTua,
      waHpSiswa: waHpSiswa ?? this.waHpSiswa,
      waHpOrtu: waHpOrtu ?? this.waHpOrtu,
      barcodeCode: barcodeCode ?? this.barcodeCode,
      barcodeActive: barcodeActive ?? this.barcodeActive,
      barcodeStatus: barcodeStatus ?? this.barcodeStatus,
      userId: userId,
      hasUserAccount: hasUserAccount,
      userEmail: userEmail,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}
