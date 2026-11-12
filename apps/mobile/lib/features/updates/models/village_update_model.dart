import 'package:flutter/material.dart';

class VillageUpdateModel {
  final String id;
  final String villageId;
  final String category;
  final String titleMr;
  final String? titleEn;
  final String descriptionMr;
  final String? descriptionEn;
  final String? eventDate;
  final String? eventTime;
  final String? venueMr;
  final String? venueEn;
  final String? organizerName;
  final String? organizerContact;
  final String? posterUrl;
  final double? latitude;
  final double? longitude;
  final String status;
  final bool isApproved;
  final bool notificationSent;
  final bool reminderEnabled;
  final DateTime? createdAt;

  const VillageUpdateModel({
    required this.id,
    this.villageId = 'a0000000-0000-0000-0000-000000000001',
    required this.category,
    required this.titleMr,
    this.titleEn,
    required this.descriptionMr,
    this.descriptionEn,
    this.eventDate,
    this.eventTime,
    this.venueMr,
    this.venueEn,
    this.organizerName,
    this.organizerContact,
    this.posterUrl,
    this.latitude,
    this.longitude,
    this.status = 'published',
    this.isApproved = true,
    this.notificationSent = false,
    this.reminderEnabled = false,
    this.createdAt,
  });

  factory VillageUpdateModel.fromJson(Map<String, dynamic> json) {
    return VillageUpdateModel(
      id: json['id']?.toString() ?? '',
      villageId: json['village_id']?.toString() ?? 'a0000000-0000-0000-0000-000000000001',
      category: json['category']?.toString() ?? 'announcement',
      titleMr: json['title_mr']?.toString() ?? '',
      titleEn: json['title_en']?.toString(),
      descriptionMr: json['description_mr']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString(),
      eventDate: json['event_date']?.toString(),
      eventTime: json['event_time']?.toString(),
      venueMr: json['venue_mr']?.toString(),
      venueEn: json['venue_en']?.toString(),
      organizerName: json['organizer_name']?.toString(),
      organizerContact: json['organizer_contact']?.toString(),
      posterUrl: json['poster_url']?.toString(),
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      status: json['status']?.toString() ?? 'published',
      isApproved: json['is_approved'] == true,
      notificationSent: json['notification_sent'] == true,
      reminderEnabled: json['reminder_enabled'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'village_id': villageId,
      'category': category,
      'title_mr': titleMr,
      'title_en': titleEn,
      'description_mr': descriptionMr,
      'description_en': descriptionEn,
      'event_date': eventDate,
      'event_time': eventTime,
      'venue_mr': venueMr,
      'venue_en': venueEn,
      'organizer_name': organizerName,
      'organizer_contact': organizerContact,
      'poster_url': posterUrl,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'is_approved': isApproved,
      'reminder_enabled': reminderEnabled,
    };
  }

  String get categoryLabel {
    switch (category) {
      case 'kirtan_bhajan':
        return 'कीर्तन / भजन';
      case 'school_education':
        return 'शाळा व प्रवेश';
      case 'cultural':
        return 'सांस्कृतिक कार्यक्रम';
      case 'festival':
        return 'ग्रामोत्सव व जत्रा';
      case 'shop_opening':
        return 'दुकान उद्घाटन';
      case 'health_camp':
        return 'आरोग्य शिबीर';
      case 'village_news':
        return 'गावच्या बातम्या';
      case 'announcement':
        return 'जाहीर सूचना व बैठका';
      case 'advertisement':
        return 'जाहिरात व प्रसिद्धी';
      case 'invitation':
        return 'निमंत्रण सोहळा';
      default:
        return 'इतर घडामोडी';
    }
  }

  String get categoryIcon {
    switch (category) {
      case 'kirtan_bhajan':
        return '🚩';
      case 'school_education':
        return '🏫';
      case 'cultural':
        return '🎭';
      case 'festival':
        return '🎪';
      case 'shop_opening':
        return '🎉';
      case 'health_camp':
        return '🏥';
      case 'village_news':
        return '📰';
      case 'announcement':
        return '📢';
      case 'advertisement':
        return '🌟';
      case 'invitation':
        return '💌';
      default:
        return '📌';
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'kirtan_bhajan':
        return const Color(0xFFD97706); // Amber
      case 'school_education':
        return const Color(0xFF2563EB); // Blue
      case 'cultural':
        return const Color(0xFF9333EA); // Purple
      case 'festival':
        return const Color(0xFFE11D48); // Rose
      case 'shop_opening':
        return const Color(0xFF059669); // Emerald
      case 'health_camp':
        return const Color(0xFF0D9488); // Teal
      case 'village_news':
        return const Color(0xFF4F46E5); // Indigo
      case 'announcement':
        return const Color(0xFFEA580C); // Orange
      case 'invitation':
        return const Color(0xFFDB2777); // Pink
      default:
        return const Color(0xFF475569); // Slate
    }
  }

  bool get isUpcoming {
    if (eventDate == null || eventDate!.isEmpty) return true;
    final parsed = DateTime.tryParse(eventDate!);
    if (parsed == null) return true;
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    return !parsed.isBefore(todayMidnight);
  }

  bool get hasValidGps =>
      latitude != null &&
      longitude != null &&
      latitude! >= -90.0 &&
      latitude! <= 90.0 &&
      longitude! >= -180.0 &&
      longitude! <= 180.0 &&
      (latitude != 0.0 || longitude != 0.0);
}

