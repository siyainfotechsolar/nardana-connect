class AdvertisementModel {
  final String id;
  final String villageId;
  final String titleMr;
  final String titleEn;
  final String? descriptionMr;
  final String? descriptionEn;
  final String imageUrl;
  final String placement; // 'home_carousel', 'sponsored_card', 'category_banner', 'popup'
  final String? categoryId;
  final String targetType; // 'none', 'business', 'phone', 'whatsapp', 'url', 'notice'
  final String? targetId;
  final String? targetUrl;
  final String? phone;
  final String? whatsapp;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int priority;
  final int impressionsCount;
  final int clicksCount;
  final String? advertiserName;
  final String? advertiserContact;
  final DateTime createdAt;

  const AdvertisementModel({
    required this.id,
    required this.villageId,
    required this.titleMr,
    required this.titleEn,
    this.descriptionMr,
    this.descriptionEn,
    required this.imageUrl,
    this.placement = 'home_carousel',
    this.categoryId,
    this.targetType = 'none',
    this.targetId,
    this.targetUrl,
    this.phone,
    this.whatsapp,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.priority = 0,
    this.impressionsCount = 0,
    this.clicksCount = 0,
    this.advertiserName,
    this.advertiserContact,
    required this.createdAt,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'] as String,
      villageId: json['village_id'] as String? ?? 'a0000000-0000-0000-0000-000000000001',
      titleMr: json['title_mr'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      descriptionMr: json['description_mr'] as String?,
      descriptionEn: json['description_en'] as String?,
      imageUrl: json['image_url'] as String? ?? '',
      placement: json['placement'] as String? ?? 'home_carousel',
      categoryId: json['category_id'] as String?,
      targetType: json['target_type'] as String? ?? 'none',
      targetId: json['target_id'] as String?,
      targetUrl: json['target_url'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String) ?? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      isActive: json['is_active'] as bool? ?? true,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      impressionsCount: (json['impressions_count'] as num?)?.toInt() ?? 0,
      clicksCount: (json['clicks_count'] as num?)?.toInt() ?? 0,
      advertiserName: json['advertiser_name'] as String?,
      advertiserContact: json['advertiser_contact'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'village_id': villageId,
      'title_mr': titleMr,
      'title_en': titleEn,
      'description_mr': descriptionMr,
      'description_en': descriptionEn,
      'image_url': imageUrl,
      'placement': placement,
      'category_id': categoryId,
      'target_type': targetType,
      'target_id': targetId,
      'target_url': targetUrl,
      'phone': phone,
      'whatsapp': whatsapp,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'priority': priority,
      'impressions_count': impressionsCount,
      'clicks_count': clicksCount,
      'advertiser_name': advertiserName,
      'advertiser_contact': advertiserContact,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String localizedTitle(String languageCode) {
    if (languageCode == 'mr') {
      return titleMr.isNotEmpty ? titleMr : titleEn;
    }
    return titleEn.isNotEmpty ? titleEn : titleMr;
  }

  String localizedDescription(String languageCode) {
    if (languageCode == 'mr') {
      return (descriptionMr != null && descriptionMr!.isNotEmpty)
          ? descriptionMr!
          : (descriptionEn ?? '');
    }
    return (descriptionEn != null && descriptionEn!.isNotEmpty)
        ? descriptionEn!
        : (descriptionMr ?? '');
  }

  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && !isExpired && now.isAfter(startDate);
  }
}

