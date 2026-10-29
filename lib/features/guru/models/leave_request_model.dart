/// Helper fungsi untuk parsing nilai integer yang tahan banting (aman dari null, num, double, maupun string)
int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? defaultValue;
  }
  return defaultValue;
}

/// Model data permohonan ijin siswa (Menu 4)
class LeaveRequestItemModel {
  final String id;
  final String studentId;
  final String studentName;
  final String studentNisn;
  final String studentGender;
  final String? studentAvatarUrl;
  final String? classId;
  final String className;
  final String type;
  final String typeLabel;
  final String? startDate;
  final String startDateFormatted;
  final String? endDate;
  final String endDateFormatted;
  final int durationDays;
  final String durationLabel;
  final String reason;
  final String status;
  final String statusLabel;
  final String? approvedByName;
  final String? approvedAt;
  final String? approvedAtFormatted;
  final String? createdAtFormatted;
  final int attachmentsCount;
  final String? thumbnailUrl;
  final List<LeaveAttachmentModel> attachments;
  final bool canApprove;

  const LeaveRequestItemModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentNisn,
    required this.studentGender,
    this.studentAvatarUrl,
    this.classId,
    required this.className,
    required this.type,
    required this.typeLabel,
    this.startDate,
    required this.startDateFormatted,
    this.endDate,
    required this.endDateFormatted,
    required this.durationDays,
    required this.durationLabel,
    required this.reason,
    required this.status,
    required this.statusLabel,
    this.approvedByName,
    this.approvedAt,
    this.approvedAtFormatted,
    this.createdAtFormatted,
    required this.attachmentsCount,
    this.thumbnailUrl,
    required this.attachments,
    required this.canApprove,
  });

  bool get isSakit => type.toLowerCase() == 'sakit';
  bool get isIzin => !isSakit;
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  String get dateRange =>
      startDateFormatted == endDateFormatted
          ? startDateFormatted
          : '$startDateFormatted - $endDateFormatted';

  String get initials {
    final parts = studentName.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return 'S';
  }

  factory LeaveRequestItemModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestItemModel(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? 'Siswa',
      studentNisn: json['student_nisn']?.toString() ?? '-',
      studentGender: json['student_gender']?.toString() ?? 'L',
      studentAvatarUrl: json['student_avatar_url']?.toString(),
      classId: json['class_id']?.toString(),
      className: json['class_name']?.toString() ?? '-',
      type: json['type']?.toString() ?? 'ijin',
      typeLabel: json['type_label']?.toString() ?? 'Izin',
      startDate: json['start_date']?.toString(),
      startDateFormatted: json['start_date_formatted']?.toString() ?? '-',
      endDate: json['end_date']?.toString(),
      endDateFormatted: json['end_date_formatted']?.toString() ?? '-',
      durationDays: _parseInt(json['duration_days'], 1),
      durationLabel: json['duration_label']?.toString() ?? '1 Hari',
      reason: json['reason']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Menunggu',
      approvedByName: json['approved_by_name']?.toString(),
      approvedAt: json['approved_at']?.toString(),
      approvedAtFormatted: json['approved_at_formatted']?.toString(),
      createdAtFormatted: json['created_at_formatted']?.toString(),
      attachmentsCount: _parseInt(json['attachments_count'], 0),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      attachments: (json['attachments'] as List? ?? [])
          .map((a) => LeaveAttachmentModel.fromJson(Map<String, dynamic>.from(a as Map)))
          .toList(),
      canApprove: json['can_approve'] == true,
    );
  }
}

/// Model berkas lampiran surat dokter / orang tua
class LeaveAttachmentModel {
  final int index;
  final String name;
  final String url;
  final String mediatype;
  final bool isImage;
  final bool isPdf;

  const LeaveAttachmentModel({
    required this.index,
    required this.name,
    required this.url,
    required this.mediatype,
    required this.isImage,
    required this.isPdf,
  });

  factory LeaveAttachmentModel.fromJson(Map<String, dynamic> json) {
    return LeaveAttachmentModel(
      index: _parseInt(json['index'], 0),
      name: json['name']?.toString() ?? 'Lampiran',
      url: json['url']?.toString() ?? '',
      mediatype: json['mediatype']?.toString() ?? 'document',
      isImage: json['is_image'] == true,
      isPdf: json['is_pdf'] == true,
    );
  }
}

/// Model riwayat log permohonan
class LeaveRequestLogModel {
  final String id;
  final String action;
  final String actionLabel;
  final String? reason;
  final String userName;
  final String? createdAt;
  final String createdAtFormatted;

  const LeaveRequestLogModel({
    required this.id,
    required this.action,
    required this.actionLabel,
    this.reason,
    required this.userName,
    this.createdAt,
    required this.createdAtFormatted,
  });

  factory LeaveRequestLogModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestLogModel(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      actionLabel: json['action_label']?.toString() ?? 'Log',
      reason: json['reason']?.toString(),
      userName: json['user_name']?.toString() ?? 'Sistem',
      createdAt: json['created_at']?.toString(),
      createdAtFormatted: json['created_at_formatted']?.toString() ?? '-',
    );
  }
}

/// Model statistik ringkasan permohonan
class LeaveRequestStatsModel {
  final int pending;
  final int approved;
  final int rejected;
  final int total;

  const LeaveRequestStatsModel({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.total,
  });

  factory LeaveRequestStatsModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestStatsModel(
      pending: _parseInt(json['pending'], 0),
      approved: _parseInt(json['approved'], 0),
      rejected: _parseInt(json['rejected'], 0),
      total: _parseInt(json['total'], 0),
    );
  }
}

/// Model respons daftar permohonan ijin
class LeaveRequestListResponse {
  final List<LeaveRequestItemModel> requests;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final LeaveRequestStatsModel todayStats;
  final List<Map<String, dynamic>> accessibleClasses;
  final List<Map<String, dynamic>> availableMonths;
  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> academicYear;

  const LeaveRequestListResponse({
    required this.requests,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.todayStats,
    required this.accessibleClasses,
    required this.availableMonths,
    required this.userInfo,
    required this.academicYear,
  });

  factory LeaveRequestListResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    final stats = json['today_stats'] as Map<String, dynamic>? ?? {};

    return LeaveRequestListResponse(
      requests: (json['requests'] as List? ?? [])
          .map((item) => LeaveRequestItemModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      currentPage: _parseInt(pagination['current_page'], 1),
      lastPage: _parseInt(pagination['last_page'], 1),
      perPage: _parseInt(pagination['per_page'], 15),
      total: _parseInt(pagination['total'], 0),
      todayStats: LeaveRequestStatsModel.fromJson(stats),
      accessibleClasses: List<Map<String, dynamic>>.from(
        (json['accessible_classes'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      availableMonths: List<Map<String, dynamic>>.from(
        (json['available_months'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      userInfo: Map<String, dynamic>.from(json['user_info'] as Map? ?? {}),
      academicYear: Map<String, dynamic>.from(json['academic_year'] as Map? ?? {}),
    );
  }
}
