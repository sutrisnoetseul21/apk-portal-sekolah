/// Model data untuk Menu 9: Profil Saya & Akun Pendidik (/portal-guru/profil)
class GuruProfilData {
  final GuruUserData user;
  final GuruTeacherData teacher;
  final GuruAkademikData akademik;

  const GuruProfilData({
    required this.user,
    required this.teacher,
    required this.akademik,
  });

  factory GuruProfilData.fromJson(Map<String, dynamic> json) {
    return GuruProfilData(
      user: GuruUserData.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      teacher: GuruTeacherData.fromJson(
        json['teacher'] as Map<String, dynamic>? ?? {},
      ),
      akademik: GuruAkademikData.fromJson(
        json['akademik'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'teacher': teacher.toJson(),
    'akademik': akademik.toJson(),
  };

  GuruProfilData copyWith({
    GuruUserData? user,
    GuruTeacherData? teacher,
    GuruAkademikData? akademik,
  }) {
    return GuruProfilData(
      user: user ?? this.user,
      teacher: teacher ?? this.teacher,
      akademik: akademik ?? this.akademik,
    );
  }

  /// Nama lengkap yang paling valid (utamakan teacher name, fallback user name)
  String get displayName {
    if (teacher.name.isNotEmpty) return teacher.name;
    if (user.name.isNotEmpty) return user.name;
    return 'Guru Pendidik';
  }

  /// Inisial huruf nama (1-2 karakter untuk avatar placeholder)
  String get initial {
    final name = displayName.trim();
    if (name.isEmpty) return 'G';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Label peran pendidik (Wali Kelas vs Guru Pengajar)
  String get roleBadgeLabel {
    if (akademik.isWaliKelas && akademik.kelasWali.isNotEmpty) {
      return 'Wali Kelas ${akademik.kelasWali.join(', ')}';
    }
    return 'Guru Pengajar';
  }
}

/// Data akun user login
class GuruUserData {
  final String id;
  final String name;
  final String email;
  final String noHp;

  const GuruUserData({
    required this.id,
    required this.name,
    required this.email,
    required this.noHp,
  });

  factory GuruUserData.fromJson(Map<String, dynamic> json) {
    return GuruUserData(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      noHp: json['no_hp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'no_hp': noHp,
  };

  GuruUserData copyWith({
    String? id,
    String? name,
    String? email,
    String? noHp,
  }) {
    return GuruUserData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
    );
  }
}

/// Data biodata guru / pendidik di tabel teachers
class GuruTeacherData {
  final String? id;
  final String name;
  final String nip;
  final String noHp;
  final String? photoPath;
  final String? photoUrl;
  final String? micrositeUrl;

  const GuruTeacherData({
    this.id,
    required this.name,
    required this.nip,
    required this.noHp,
    this.photoPath,
    this.photoUrl,
    this.micrositeUrl,
  });

  factory GuruTeacherData.fromJson(Map<String, dynamic> json) {
    return GuruTeacherData(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      nip: json['nip']?.toString() ?? '-',
      noHp: json['no_hp']?.toString() ?? '',
      photoPath: json['photo_path']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      micrositeUrl: json['microsite_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nip': nip,
    'no_hp': noHp,
    'photo_path': photoPath,
    'photo_url': photoUrl,
    'microsite_url': micrositeUrl,
  };

  GuruTeacherData copyWith({
    String? id,
    String? name,
    String? nip,
    String? noHp,
    String? photoPath,
    String? photoUrl,
    String? micrositeUrl,
    bool clearPhoto = false,
  }) {
    return GuruTeacherData(
      id: id ?? this.id,
      name: name ?? this.name,
      nip: nip ?? this.nip,
      noHp: noHp ?? this.noHp,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      micrositeUrl: micrositeUrl ?? this.micrositeUrl,
    );
  }

  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;
  bool get hasMicrosite =>
      micrositeUrl != null && micrositeUrl!.trim().isNotEmpty;
}

/// Data penugasan akademik aktif (Wali Kelas, BK, Mapel, Jabatan)
class GuruAkademikData {
  final bool isWaliKelas;
  final List<String> kelasWali;
  final List<String> kelasPantau;
  final List<String> mapelDiampu;
  final List<String> jabatanAktif;
  final String? tahunAjaran;

  const GuruAkademikData({
    required this.isWaliKelas,
    required this.kelasWali,
    required this.kelasPantau,
    required this.mapelDiampu,
    required this.jabatanAktif,
    this.tahunAjaran,
  });

  factory GuruAkademikData.fromJson(Map<String, dynamic> json) {
    return GuruAkademikData(
      isWaliKelas: json['is_wali_kelas'] == true,
      kelasWali:
          (json['kelas_wali'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      kelasPantau:
          (json['kelas_pantau'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mapelDiampu:
          (json['mapel_diampu'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      jabatanAktif:
          (json['jabatan_aktif'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tahunAjaran: json['tahun_ajaran']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'is_wali_kelas': isWaliKelas,
    'kelas_wali': kelasWali,
    'kelas_pantau': kelasPantau,
    'mapel_diampu': mapelDiampu,
    'jabatan_aktif': jabatanAktif,
    'tahun_ajaran': tahunAjaran,
  };
}
