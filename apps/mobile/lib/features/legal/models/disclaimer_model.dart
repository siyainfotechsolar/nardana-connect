class DisclaimerSectionModel {
  final String id;
  final String sectionKey;
  final String titleMr;
  final String titleEn;
  final String contentMr;
  final String contentEn;
  final int displayOrder;
  final bool isActive;
  final bool isMaterial;
  final bool requiresReacceptance;
  final String approvalStatus;
  final String version;
  final DateTime? updatedAt;

  const DisclaimerSectionModel({
    required this.id,
    required this.sectionKey,
    required this.titleMr,
    required this.titleEn,
    required this.contentMr,
    required this.contentEn,
    this.displayOrder = 0,
    this.isActive = true,
    this.isMaterial = false,
    this.requiresReacceptance = false,
    this.approvalStatus = 'approved',
    this.version = '1.0.0',
    this.updatedAt,
  });

  factory DisclaimerSectionModel.fromMap(Map<String, dynamic> map) {
    return DisclaimerSectionModel(
      id: map['id']?.toString() ?? '',
      sectionKey: map['section_key']?.toString() ?? '',
      titleMr: map['title_mr']?.toString() ?? '',
      titleEn: map['title_en']?.toString() ?? '',
      contentMr: map['content_mr']?.toString() ?? '',
      contentEn: map['content_en']?.toString() ?? '',
      displayOrder: (map['display_order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] != false,
      isMaterial: map['is_material'] == true,
      requiresReacceptance: map['requires_reacceptance'] == true,
      approvalStatus: map['approval_status']?.toString() ?? 'approved',
      version: map['version']?.toString() ?? '1.0.0',
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }
}

class DisclaimerDocumentModel {
  final String id;
  final String titleMr;
  final String titleEn;
  final String currentVersion;
  final String effectiveDate;
  final DateTime? lastPublishedAt;

  const DisclaimerDocumentModel({
    required this.id,
    required this.titleMr,
    required this.titleEn,
    required this.currentVersion,
    required this.effectiveDate,
    this.lastPublishedAt,
  });

  factory DisclaimerDocumentModel.fromMap(Map<String, dynamic> map) {
    return DisclaimerDocumentModel(
      id: map['id']?.toString() ?? '',
      titleMr: map['title_mr']?.toString() ?? 'नरडाणा कनेक्ट - कायदेशीर अस्वीकरण',
      titleEn: map['title_en']?.toString() ?? 'Nardana Connect - Legal Disclaimer',
      currentVersion: map['current_version']?.toString() ?? '1.0.0',
      effectiveDate: map['effective_date']?.toString() ?? '2026-11-12',
      lastPublishedAt: map['last_published_at'] != null ? DateTime.tryParse(map['last_published_at'].toString()) : null,
    );
  }
}

class DisclaimerVersionHistoryModel {
  final String id;
  final String versionNumber;
  final String changelogMr;
  final String changelogEn;
  final bool isMaterialChange;
  final bool requiresReacceptance;
  final String effectiveDate;
  final DateTime? createdAt;

  const DisclaimerVersionHistoryModel({
    required this.id,
    required this.versionNumber,
    required this.changelogMr,
    required this.changelogEn,
    this.isMaterialChange = false,
    this.requiresReacceptance = false,
    required this.effectiveDate,
    this.createdAt,
  });

  factory DisclaimerVersionHistoryModel.fromMap(Map<String, dynamic> map) {
    return DisclaimerVersionHistoryModel(
      id: map['id']?.toString() ?? '',
      versionNumber: map['version_number']?.toString() ?? '',
      changelogMr: map['changelog_mr']?.toString() ?? '',
      changelogEn: map['changelog_en']?.toString() ?? '',
      isMaterialChange: map['is_material_change'] == true,
      requiresReacceptance: map['requires_reacceptance'] == true,
      effectiveDate: map['effective_date']?.toString() ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }
}

