class SiswaProfilDetail {
  final String studentId;
  final String? userId;
  final String name;
  final String nisn;
  final String nis;
  final String email;
  final String className;
  final String academicYear;
  final String status;
  final String gender;
  final String genderLabel;
  final String religion;
  final String birthPlace;
  final String? birthDate;
  final String birthInfo;
  final String address;
  final String noHp;
  final String? photoUrl;
  final bool allowPhotoUpload;
  final String namaAyah;
  final String pekerjaanAyah;
  final String namaIbu;
  final String pekerjaanIbu;
  final String namaWali;
  final String pekerjaanWali;
  final String noHpOrangTua;
  final String barcodeCode;

  const SiswaProfilDetail({
    required this.studentId,
    this.userId,
    required this.name,
    required this.nisn,
    required this.nis,
    required this.email,
    required this.className,
    required this.academicYear,
    required this.status,
    required this.gender,
    required this.genderLabel,
    required this.religion,
    required this.birthPlace,
    this.birthDate,
    required this.birthInfo,
    required this.address,
    required this.noHp,
    this.photoUrl,
    required this.allowPhotoUpload,
    required this.namaAyah,
    required this.pekerjaanAyah,
    required this.namaIbu,
    required this.pekerjaanIbu,
    required this.namaWali,
    required this.pekerjaanWali,
    required this.noHpOrangTua,
    required this.barcodeCode,
  });

  factory SiswaProfilDetail.fromJson(Map<String, dynamic> json) {
    return SiswaProfilDetail(
      studentId: json['student_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      name: json['name']?.toString() ?? '',
      nisn: json['nisn']?.toString() ?? '-',
      nis: json['nis']?.toString() ?? '-',
      email: json['email']?.toString() ?? '-',
      className: json['class_name']?.toString() ?? '-',
      academicYear: json['academic_year']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'aktif',
      gender: json['gender']?.toString() ?? 'L',
      genderLabel: json['gender_label']?.toString() ?? 'Laki-laki',
      religion: json['religion']?.toString() ?? '-',
      birthPlace: json['birth_place']?.toString() ?? '-',
      birthDate: json['birth_date']?.toString(),
      birthInfo: json['birth_info']?.toString() ?? '-',
      address: json['address']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString(),
      allowPhotoUpload: json['allow_photo_upload'] == true,
      namaAyah: json['nama_ayah']?.toString() ?? '-',
      pekerjaanAyah: json['pekerjaan_ayah']?.toString() ?? '-',
      namaIbu: json['nama_ibu']?.toString() ?? '-',
      pekerjaanIbu: json['pekerjaan_ibu']?.toString() ?? '-',
      namaWali: json['nama_wali']?.toString() ?? '-',
      pekerjaanWali: json['pekerjaan_wali']?.toString() ?? '-',
      noHpOrangTua: json['no_hp_orang_tua']?.toString() ?? '-',
      barcodeCode: json['barcode_code']?.toString() ?? '',
    );
  }

  SiswaProfilDetail copyWith({
    String? address,
    String? noHp,
    String? noHpOrangTua,
    String? photoUrl,
  }) {
    return SiswaProfilDetail(
      studentId: studentId,
      userId: userId,
      name: name,
      nisn: nisn,
      nis: nis,
      email: email,
      className: className,
      academicYear: academicYear,
      status: status,
      gender: gender,
      genderLabel: genderLabel,
      religion: religion,
      birthPlace: birthPlace,
      birthDate: birthDate,
      birthInfo: birthInfo,
      address: address ?? this.address,
      noHp: noHp ?? this.noHp,
      photoUrl: photoUrl ?? this.photoUrl,
      allowPhotoUpload: allowPhotoUpload,
      namaAyah: namaAyah,
      pekerjaanAyah: pekerjaanAyah,
      namaIbu: namaIbu,
      pekerjaanIbu: pekerjaanIbu,
      namaWali: namaWali,
      pekerjaanWali: pekerjaanWali,
      noHpOrangTua: noHpOrangTua ?? this.noHpOrangTua,
      barcodeCode: barcodeCode,
    );
  }
}

class SiswaProfilResponse {
  final bool success;
  final String message;
  final SiswaProfilDetail? data;

  const SiswaProfilResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SiswaProfilResponse.fromJson(Map<String, dynamic> json) {
    return SiswaProfilResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SiswaProfilDetail.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

