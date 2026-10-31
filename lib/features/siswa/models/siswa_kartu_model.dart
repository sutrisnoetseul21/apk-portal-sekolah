class SiswaKartuDigitalInfo {
  final String studentId;
  final String name;
  final String nisn;
  final String nis;
  final String className;
  final String gender;
  final String genderLabel;
  final String birthPlace;
  final String? birthDate;
  final String birthInfo;
  final String? photoUrl;
  final String barcodeCode;
  final bool barcodeActive;
  final String schoolName;
  final String schoolAddress;
  final String? schoolLogoUrl;
  final String principalName;
  final String principalNip;
  final String scanMode;
  final String downloadPdfUrl;
  final String biodataPdfUrl;

  const SiswaKartuDigitalInfo({
    required this.studentId,
    required this.name,
    required this.nisn,
    required this.nis,
    required this.className,
    required this.gender,
    required this.genderLabel,
    required this.birthPlace,
    this.birthDate,
    required this.birthInfo,
    this.photoUrl,
    required this.barcodeCode,
    required this.barcodeActive,
    required this.schoolName,
    required this.schoolAddress,
    this.schoolLogoUrl,
    required this.principalName,
    required this.principalNip,
    required this.scanMode,
    required this.downloadPdfUrl,
    required this.biodataPdfUrl,
  });

  factory SiswaKartuDigitalInfo.fromJson(Map<String, dynamic> json) {
    return SiswaKartuDigitalInfo(
      studentId: json['student_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nisn: json['nisn']?.toString() ?? '-',
      nis: json['nis']?.toString() ?? '-',
      className: json['class_name']?.toString() ?? '-',
      gender: json['gender']?.toString() ?? 'L',
      genderLabel: json['gender_label']?.toString() ?? 'Laki-laki',
      birthPlace: json['birth_place']?.toString() ?? '',
      birthDate: json['birth_date']?.toString(),
      birthInfo: json['birth_info']?.toString() ?? '-',
      photoUrl: json['photo_url']?.toString(),
      barcodeCode: json['barcode_code']?.toString() ?? '',
      barcodeActive: json['barcode_active'] == true,
      schoolName: json['school_name']?.toString() ?? 'SMP Negeri 3 Kedungreja',
      schoolAddress: json['school_address']?.toString() ?? '-',
      schoolLogoUrl: json['school_logo_url']?.toString(),
      principalName: json['principal_name']?.toString() ?? 'Kepala Sekolah',
      principalNip: json['principal_nip']?.toString() ?? '-',
      scanMode: json['scan_mode']?.toString() ?? 'nisn',
      downloadPdfUrl: json['download_pdf_url']?.toString() ?? '',
      biodataPdfUrl: json['biodata_pdf_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'nisn': nisn,
      'nis': nis,
      'class_name': className,
      'gender': gender,
      'gender_label': genderLabel,
      'birth_place': birthPlace,
      'birth_date': birthDate,
      'birth_info': birthInfo,
      'photo_url': photoUrl,
      'barcode_code': barcodeCode,
      'barcode_active': barcodeActive,
      'school_name': schoolName,
      'school_address': schoolAddress,
      'school_logo_url': schoolLogoUrl,
      'principal_name': principalName,
      'principal_nip': principalNip,
      'scan_mode': scanMode,
      'download_pdf_url': downloadPdfUrl,
      'biodata_pdf_url': biodataPdfUrl,
    };
  }
}

class SiswaKartuResponse {
  final bool success;
  final String message;
  final SiswaKartuDigitalInfo? data;

  const SiswaKartuResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SiswaKartuResponse.fromJson(Map<String, dynamic> json) {
    return SiswaKartuResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? SiswaKartuDigitalInfo.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

