/// Model DTO untuk lampiran surat izin / sakit
class SiswaIjinAttachment {
  final int index;
  final String fileName;
  final String url;
  final String filePath;
  final String extension;
  final bool isImage;
  final String mediaType;

  const SiswaIjinAttachment({
    required this.index,
    required this.fileName,
    required this.url,
    required this.filePath,
    required this.extension,
    required this.isImage,
    required this.mediaType,
  });

  factory SiswaIjinAttachment.fromJson(Map<String, dynamic> json) {
    return SiswaIjinAttachment(
      index: json['index'] is int ? json['index'] : 0,
      fileName: json['file_name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      filePath: json['file_path']?.toString() ?? '',
      extension: json['extension']?.toString() ?? '',
      isImage: json['is_image'] == true,
      mediaType: json['mediatype']?.toString() ?? 'image',
    );
  }
}

/// Model DTO untuk satu item pengajuan izin siswa
class SiswaIjinItem {
  final String id;
  final String type; // 'sakit' | 'ijin'
  final String typeLabel;
  final int durationDays;
  final String startDate;
  final String endDate;
  final String formattedStartDate;
  final String formattedEndDate;
  final String formattedRange;
  final String reason;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String statusLabel;
  final bool hasAttachments;
  final int attachmentsCount;
  final List<SiswaIjinAttachment> attachments;
  final String? primaryAttachmentUrl;
  final bool isCancellable;
  final String? verificationNote;
  final String? approvedAt;
  final String? approverName;
  final String createdAt;
  final String formattedCreatedAt;

  const SiswaIjinItem({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.formattedStartDate,
    required this.formattedEndDate,
    required this.formattedRange,
    required this.reason,
    required this.status,
    required this.statusLabel,
    required this.hasAttachments,
    required this.attachmentsCount,
    required this.attachments,
    this.primaryAttachmentUrl,
    required this.isCancellable,
    this.verificationNote,
    this.approvedAt,
    this.approverName,
    required this.createdAt,
    required this.formattedCreatedAt,
  });

  factory SiswaIjinItem.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'] as List<dynamic>? ?? [];
    return SiswaIjinItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'ijin',
      typeLabel: json['type_label']?.toString() ?? 'Izin',
      durationDays: json['duration_days'] is int ? json['duration_days'] : 1,
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      formattedStartDate: json['formatted_start_date']?.toString() ?? '',
      formattedEndDate: json['formatted_end_date']?.toString() ?? '',
      formattedRange: json['formatted_range']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Menunggu Verifikasi',
      hasAttachments: json['has_attachments'] == true,
      attachmentsCount: json['attachments_count'] is int ? json['attachments_count'] : 0,
      attachments: rawAttachments.map((e) => SiswaIjinAttachment.fromJson(e as Map<String, dynamic>)).toList(),
      primaryAttachmentUrl: json['primary_attachment_url']?.toString(),
      isCancellable: json['is_cancellable'] == true,
      verificationNote: json['verification_note']?.toString(),
      approvedAt: json['approved_at']?.toString(),
      approverName: json['approver_name']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      formattedCreatedAt: json['formatted_created_at']?.toString() ?? '',
    );
  }
}

/// Model counter status ringkasan pengajuan ijin
class SiswaIjinCounts {
  final int total;
  final int pending;
  final int approved;
  final int rejected;

  const SiswaIjinCounts({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory SiswaIjinCounts.fromJson(Map<String, dynamic> json) {
    return SiswaIjinCounts(
      total: json['total'] is int ? json['total'] : 0,
      pending: json['pending'] is int ? json['pending'] : 0,
      approved: json['approved'] is int ? json['approved'] : 0,
      rejected: json['rejected'] is int ? json['rejected'] : 0,
    );
  }
}

/// Model pagination data
class SiswaIjinPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  const SiswaIjinPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory SiswaIjinPagination.fromJson(Map<String, dynamic> json) {
    return SiswaIjinPagination(
      currentPage: json['current_page'] is int ? json['current_page'] : 1,
      lastPage: json['last_page'] is int ? json['last_page'] : 1,
      perPage: json['per_page'] is int ? json['per_page'] : 10,
      total: json['total'] is int ? json['total'] : 0,
      hasMore: json['has_more'] == true,
    );
  }
}

/// Model respons penuh daftar riwayat permohonan ijin siswa
class SiswaIjinListResponse {
  final SiswaIjinCounts counts;
  final List<SiswaIjinItem> items;
  final SiswaIjinPagination pagination;

  const SiswaIjinListResponse({
    required this.counts,
    required this.items,
    required this.pagination,
  });

  factory SiswaIjinListResponse.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['counts'] as Map<String, dynamic>? ?? {};
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawPagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return SiswaIjinListResponse(
      counts: SiswaIjinCounts.fromJson(rawCounts),
      items: rawItems.map((e) => SiswaIjinItem.fromJson(e as Map<String, dynamic>)).toList(),
      pagination: SiswaIjinPagination.fromJson(rawPagination),
    );
  }
}

/// Model respons pengecekan hari libur kalender sekolah
class SiswaHolidaysCheckResult {
  final String startDate;
  final String endDate;
  final int durationDays;
  final int schoolDaysCount;
  final int holidayCount;
  final List<String> holidayMessages;
  final List<String> holidayDates;

  const SiswaHolidaysCheckResult({
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.schoolDaysCount,
    required this.holidayCount,
    required this.holidayMessages,
    required this.holidayDates,
  });

  factory SiswaHolidaysCheckResult.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['holiday_messages'] as List<dynamic>? ?? [];
    final rawDates = json['holiday_dates'] as List<dynamic>? ?? [];

    return SiswaHolidaysCheckResult(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      durationDays: json['duration_days'] is int ? json['duration_days'] : 1,
      schoolDaysCount: json['school_days_count'] is int ? json['school_days_count'] : 1,
      holidayCount: json['holiday_count'] is int ? json['holiday_count'] : 0,
      holidayMessages: rawMessages.map((e) => e.toString()).toList(),
      holidayDates: rawDates.map((e) => e.toString()).toList(),
    );
  }
}

