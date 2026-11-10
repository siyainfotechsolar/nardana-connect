class AppUpdateConfigModel {
  final String id;
  final String platform;
  final String latestVersion;
  final int latestBuildNumber;
  final String minimumSupportedVersion;
  final int minimumSupportedBuild;
  final bool forceUpdateEnabled;
  final bool optionalUpdateEnabled;
  final String updateTitleMr;
  final String updateTitleEn;
  final String updateMessageMr;
  final String updateMessageEn;
  final String releaseNotesMr;
  final String releaseNotesEn;
  final String playStoreUrl;
  final String apkDownloadUrl;
  final bool maintenanceMode;
  final String maintenanceMessageMr;
  final String maintenanceMessageEn;
  final DateTime updatedAt;
  final String updatedBy;

  const AppUpdateConfigModel({
    required this.id,
    required this.platform,
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.minimumSupportedVersion,
    required this.minimumSupportedBuild,
    required this.forceUpdateEnabled,
    required this.optionalUpdateEnabled,
    required this.updateTitleMr,
    required this.updateTitleEn,
    required this.updateMessageMr,
    required this.updateMessageEn,
    required this.releaseNotesMr,
    required this.releaseNotesEn,
    required this.playStoreUrl,
    required this.apkDownloadUrl,
    required this.maintenanceMode,
    required this.maintenanceMessageMr,
    required this.maintenanceMessageEn,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory AppUpdateConfigModel.fromJson(Map<String, dynamic> json) {
    return AppUpdateConfigModel(
      id: json['id'] as String? ?? '',
      platform: json['platform'] as String? ?? 'android',
      latestVersion: json['latest_version'] as String? ?? '1.0.0',
      latestBuildNumber: (json['latest_build_number'] as num?)?.toInt() ?? 1,
      minimumSupportedVersion: json['minimum_supported_version'] as String? ?? '1.0.0',
      minimumSupportedBuild: (json['minimum_supported_build'] as num?)?.toInt() ?? 1,
      forceUpdateEnabled: json['force_update_enabled'] as bool? ?? false,
      optionalUpdateEnabled: json['optional_update_enabled'] as bool? ?? true,
      updateTitleMr: json['update_title_mr'] as String? ?? 'नवीन ॲप अपडेट उपलब्ध आहे!',
      updateTitleEn: json['update_title_en'] as String? ?? 'New App Update Available!',
      updateMessageMr: json['update_message_mr'] as String? ??
          'नरडाणा कनेक्ट ॲप अधिक वेगवान व सुरक्षित करण्यासाठी कृपया नवीन व्हर्जन इन्स्टॉल करा.',
      updateMessageEn: json['update_message_en'] as String? ??
          'Please update to the latest version of Nardana Connect for new features, speed and security enhancements.',
      releaseNotesMr: json['release_notes_mr'] as String? ??
          '• सर्व मॉड्यूल्ससाठी सविस्तर तपशील स्क्रीन\n• नवीन जाहिरात व्यवस्थापन प्रणाली\n• कामगिरी व गतीमध्ये सुधारणा',
      releaseNotesEn: json['release_notes_en'] as String? ??
          '• Full details screen on every module\n• Enhanced advertisement module\n• Performance optimizations',
      playStoreUrl: json['play_store_url'] as String? ??
          'https://play.google.com/store/apps/details?id=in.nardana.connect.nardana_connect',
      apkDownloadUrl: json['apk_download_url'] as String? ??
          'https://github.com/siyainfotechsolar/nardana-connect/releases/download/v1.0.0/app-release.apk',
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      maintenanceMessageMr: json['maintenance_message_mr'] as String? ??
          'नरडाणा कनेक्ट ॲप सध्या नियोजित तांत्रिक देखभालीसाठी तात्पुरते बंद आहे. कृपया थोड्या वेळाने पुन्हा प्रयत्न करा.',
      maintenanceMessageEn: json['maintenance_message_en'] as String? ??
          'Nardana Connect is currently undergoing scheduled maintenance. Please check back shortly.',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedBy: json['updated_by'] as String? ?? 'admin',
    );
  }

  String localizedTitle(String lang) {
    return lang.toLowerCase() == 'en' ? updateTitleEn : updateTitleMr;
  }

  String localizedMessage(String lang) {
    return lang.toLowerCase() == 'en' ? updateMessageEn : updateMessageMr;
  }

  String localizedReleaseNotes(String lang) {
    return lang.toLowerCase() == 'en' ? releaseNotesEn : releaseNotesMr;
  }

  String localizedMaintenanceMessage(String lang) {
    return lang.toLowerCase() == 'en' ? maintenanceMessageEn : maintenanceMessageMr;
  }
}

