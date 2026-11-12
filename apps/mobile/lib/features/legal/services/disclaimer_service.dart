import 'package:flutter/foundation.dart';
import 'package:nardana_connect/core/services/supabase_service.dart';
import 'package:nardana_connect/features/legal/models/disclaimer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisclaimerService {
  static final DisclaimerService instance = DisclaimerService._();
  DisclaimerService._();

  static const String _prefAcceptedVersionKey = 'accepted_disclaimer_version';

  /// Fetch document metadata
  Future<DisclaimerDocumentModel> fetchDocument() async {
    try {
      final res = await SupabaseService.client
          .from('disclaimer_documents')
          .select('*')
          .limit(1)
          .single();

      if (res.isNotEmpty) {
        return DisclaimerDocumentModel.fromMap(res);
      }
    } catch (e) {
      debugPrint('[DisclaimerService] fetchDocument error: $e');
    }

    return const DisclaimerDocumentModel(
      id: 'default',
      titleMr: 'नरडाणा कनेक्ट - अस्वीकरण (DISCLAIMER)',
      titleEn: 'NARDANA CONNECT - LEGAL DISCLAIMER',
      currentVersion: '1.0.0',
      effectiveDate: '2026-11-12',
    );
  }

  /// Fetch all active & approved sections ordered by display_order
  Future<List<DisclaimerSectionModel>> fetchSections() async {
    try {
      final res = await SupabaseService.client
          .from('disclaimer_sections')
          .select('*')
          .eq('is_active', true)
          .eq('approval_status', 'approved')
          .order('display_order', ascending: true);

      if (res.isNotEmpty) {
        return (res as List)
            .map((e) => DisclaimerSectionModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[DisclaimerService] fetchSections error: $e');
    }

    return _fallbackSections;
  }

  /// Fetch version history snapshots
  Future<List<DisclaimerVersionHistoryModel>> fetchVersionHistory() async {
    try {
      final res = await SupabaseService.client
          .from('disclaimer_versions')
          .select('*')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        return (res as List)
            .map((e) => DisclaimerVersionHistoryModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[DisclaimerService] fetchVersionHistory error: $e');
    }

    return [
      const DisclaimerVersionHistoryModel(
        id: '1',
        versionNumber: '1.0.0',
        changelogMr: 'पहिली अधिकृत कायदेशीर अस्वीकरण आवृत्ती (Initial Release)',
        changelogEn: 'First official legal disclaimer release with 14 village-specific sections',
        isMaterialChange: true,
        requiresReacceptance: false,
        effectiveDate: '2026-11-12',
      ),
    ];
  }

  /// Check if user has accepted the latest version
  Future<bool> hasAcceptedLatestVersion(String currentVersion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final acceptedVersion = prefs.getString(_prefAcceptedVersionKey);
      if (acceptedVersion == null) return false;
      return acceptedVersion == currentVersion;
    } catch (e) {
      return false;
    }
  }

  /// Check if a specific feature requires disclaimer re-acceptance
  Future<bool> checkFeatureRequiresAcceptance(String featureId) async {
    try {
      // 1. Check mapping
      final res = await SupabaseService.client
          .from('disclaimer_feature_mappings')
          .select('requires_reacceptance, disclaimer_version')
          .eq('feature_id', featureId)
          .maybeSingle();

      if (res != null && res['requires_reacceptance'] == true) {
        final ver = res['disclaimer_version']?.toString() ?? '1.0.0';
        final prefs = await SharedPreferences.getInstance();
        final acceptedForFeature = prefs.getString('accepted_disclaimer_feature_$featureId');
        if (acceptedForFeature != ver) {
          return true; // Requires acceptance before use!
        }
      }
    } catch (e) {
      debugPrint('[DisclaimerService] checkFeatureRequiresAcceptance error: $e');
    }
    return false;
  }

  /// Record citizen acceptance
  Future<bool> recordAcceptance({
    required String versionNumber,
    String? featureId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefAcceptedVersionKey, versionNumber);
      if (featureId != null) {
        await prefs.setString('accepted_disclaimer_feature_$featureId', versionNumber);
      }

      // Record in Supabase
      final userId = SupabaseService.client.auth.currentUser?.id ?? 'citizen_guest';
      await SupabaseService.client.from('disclaimer_acceptances').insert({
        'user_id': userId,
        'version_number': versionNumber,
        'feature_id': featureId,
        'device_info': 'Android Citizen App',
      });
      return true;
    } catch (e) {
      debugPrint('[DisclaimerService] recordAcceptance error: $e');
      return true; // Local acceptance succeeded
    }
  }

  static const List<DisclaimerSectionModel> _fallbackSections = [
    DisclaimerSectionModel(
      id: '1',
      sectionKey: 'general_info',
      titleMr: '१. सामान्य माहिती',
      titleEn: '1. General Information',
      contentMr:
          'NARDANA CONNECT हे नर्डाणा गावातील नागरिकांना स्थानिक माहिती, दुकाने, व्यवसाय, सेवा, नोकरी, वाहन भाडे, बस वेळापत्रक, Buy & Sell, ग्रामपंचायत सूचना आणि इतर सार्वजनिक माहिती उपलब्ध करून देण्यासाठी तयार केलेले डिजिटल व्यासपीठ आहे.\n\nया App वरील माहिती ही माहिती आणि जनजागृतीच्या उद्देशाने उपलब्ध करून दिली जाते.',
      contentEn:
          'NARDANA CONNECT is a community information platform designed to provide local information, shops, businesses, services, jobs, vehicle rentals, bus timetables, Buy & Sell, Gram Panchayat notices and other public information for citizens of Nardana village.\n\nInformation on this App is provided solely for informational and community awareness purposes.',
      displayOrder: 1,
    ),
    DisclaimerSectionModel(
      id: '2',
      sectionKey: 'accuracy_of_info',
      titleMr: '२. माहितीची अचूकता',
      titleEn: '2. Accuracy of Information',
      contentMr:
          'App वरील बस वेळापत्रक, वाहन सेवा, दुकाने, व्यवसाय, नोकरी, संपर्क क्रमांक, किंमती, उपलब्धता आणि इतर माहिती बदलू शकते. शक्य तितकी अचूक माहिती देण्याचा प्रयत्न केला जातो; मात्र प्रत्येक माहितीची पूर्ण अचूकता, अद्ययावतपणा किंवा उपलब्धता याची हमी दिली जात नाही.\n\nप्रवास करण्यापूर्वी बसची वेळ संबंधित बसस्थानक किंवा अधिकृत MSRTC स्रोताकडून तपासावी.',
      contentEn:
          'Information regarding bus timetables, vehicle services, shops, businesses, jobs, contact numbers, prices, and availability may change over time. While every effort is made to provide accurate information, absolute accuracy, completeness, or ongoing availability cannot be guaranteed.\n\nUsers should verify bus timings with the local bus station or official MSRTC sources prior to traveling.',
      displayOrder: 2,
    ),
    DisclaimerSectionModel(
      id: '3',
      sectionKey: 'shops_and_ads',
      titleMr: '३. दुकाने, सेवा आणि जाहिराती',
      titleEn: '3. Shops, Services and Advertisements',
      contentMr:
          'या App वरील दुकाने, व्यवसाय, जाहिराती आणि सेवा यांची माहिती संबंधित जाहिरातदार किंवा सेवा पुरवठादारांकडून मिळू शकते.\n\nकोणतीही खरेदी, व्यवहार, सेवा बुकिंग किंवा आर्थिक देवाणघेवाण करण्यापूर्वी नागरिकांनी स्वतः आवश्यक पडताळणी करावी.',
      contentEn:
          'Information regarding shops, businesses, advertisements, and local services is provided directly by respective merchants or service providers.\n\nCitizens and users must conduct independent verification before making any purchase, transaction, service booking, or financial transfer.',
      displayOrder: 3,
    ),
    DisclaimerSectionModel(
      id: '4',
      sectionKey: 'buy_and_sell',
      titleMr: '४. Buy & Sell',
      titleEn: '4. Buy & Sell (Marketplace)',
      contentMr:
          'Buy & Sell विभागातील वस्तूंची खरेदी-विक्री ही संबंधित खरेदीदार आणि विक्रेत्यांमधील थेट व्यवहार आहे.\n\nNARDANA CONNECT वस्तूंची गुणवत्ता, मालकी, किंमत, सुरक्षितता किंवा व्यवहाराची पूर्तता याची हमी देत नाही. पैसे देण्यापूर्वी वस्तू आणि विक्रेत्याची स्वतः पडताळणी करावी.',
      contentEn:
          'Buying and selling in the Buy & Sell section constitutes a direct private transaction between the respective buyer and seller.\n\nNARDANA CONNECT does not guarantee the quality, legitimate ownership, pricing, safety, or fulfillment of any transaction. Users must inspect items and verify the seller independently before making any payment.',
      displayOrder: 4,
    ),
    DisclaimerSectionModel(
      id: '5',
      sectionKey: 'vehicle_and_driver',
      titleMr: '५. वाहन व ड्रायव्हर माहिती',
      titleEn: '5. Vehicle Rental & Driver Directory',
      contentMr:
          'वाहन भाडे आणि ड्रायव्हर संपर्क माहिती ही संबंधित वाहनधारक किंवा सेवा पुरवठादारांकडून दिली जाऊ शकते.\n\nवाहनाची कागदपत्रे, परवाना, विमा, वाहनाची स्थिती आणि भाडे यांची खात्री करूनच प्रवास करावा.',
      contentEn:
          'Vehicle rental details and driver contact information are provided directly by vehicle owners and service providers.\n\nPassengers must verify valid vehicle documentation, driver license, insurance, vehicle fitness, and agreed fare before commencing any travel.',
      displayOrder: 5,
    ),
    DisclaimerSectionModel(
      id: '6',
      sectionKey: 'grampanchayat_govt',
      titleMr: '६. ग्रामपंचायत व शासकीय माहिती',
      titleEn: '6. Gram Panchayat & Government Information',
      contentMr:
          'App वरील ग्रामपंचायत सूचना किंवा शासकीय योजनांशी संबंधित माहिती अधिकृत स्रोताकडून पडताळून घ्यावी. अधिकृतरीत्या प्रमाणित नसलेली माहिती ही सरकारी घोषणा समजू नये.\n\nNARDANA CONNECT हे सरकारी अधिकृत App नाही आणि कोणत्याही सरकारी विभागाचे प्रतिनिधित्व करत नाही, जोपर्यंत संबंधित विभागाची अधिकृत मान्यता स्पष्टपणे नमूद केलेली नाही.',
      contentEn:
          'Gram Panchayat notices, government circulars, and public welfare schemes published on the App should be independently verified from official government portals. Uncertified notices must not be treated as formal statutory notices.\n\nNARDANA CONNECT is not an official government application and does not represent any government department unless explicit statutory authorization is stated.',
      displayOrder: 6,
    ),
    DisclaimerSectionModel(
      id: '7',
      sectionKey: 'jobs_employment',
      titleMr: '७. नोकरी व रोजगार',
      titleEn: '7. Jobs & Employment',
      contentMr:
          'App वरील नोकरीच्या जाहिराती संबंधित नियोक्त्यांकडून दिल्या जाऊ शकतात. अर्ज करण्यापूर्वी नियोक्ता, नोकरीची अट आणि पगार यांची पडताळणी करावी. नोकरी मिळवून देण्याची हमी दिली जात नाही.',
      contentEn:
          'Job listings posted on the App are submitted by respective employers. Candidates must independently verify employer authenticity, working conditions, and wages before applying. NARDANA CONNECT does not guarantee job placement or employment outcomes.',
      displayOrder: 7,
    ),
    DisclaimerSectionModel(
      id: '8',
      sectionKey: 'emergency_services',
      titleMr: '८. आपत्कालीन सेवा',
      titleEn: '8. Emergency Services',
      contentMr:
          'Emergency Contacts मधील संपर्क क्रमांक उपलब्धतेनुसार बदलू शकतात. आपत्कालीन परिस्थितीत संबंधित अधिकृत आपत्कालीन सेवा क्रमांकावर थेट संपर्क साधावा. App वर अवलंबून राहून मदत मिळण्यास विलंब करू नये.',
      contentEn:
          'Numbers listed in the Emergency Directory may change or be temporarily unreachable. In genuine life-safety emergencies, citizens must directly dial official emergency helpline numbers (112, 108, 101) without delay rather than relying solely on the application.',
      displayOrder: 8,
    ),
    DisclaimerSectionModel(
      id: '9',
      sectionKey: 'user_content',
      titleMr: '९. वापरकर्त्यांनी दिलेली माहिती',
      titleEn: '9. User-Generated Content & Submissions',
      contentMr:
          'वापरकर्त्यांनी दिलेली माहिती, फोटो, जाहिराती किंवा मजकूर यासाठी संबंधित वापरकर्ता जबाबदार असेल. चुकीची, फसवी, बेकायदेशीर, आक्षेपार्ह किंवा दुसऱ्यांच्या अधिकारांचे उल्लंघन करणारी माहिती प्रकाशित करण्यास मनाई आहे.\n\nAdmin ला नियमांचे उल्लंघन करणारी सामग्री तपासून नाकारणे, लपवणे किंवा हटवणे याचा अधिकार असेल.',
      contentEn:
          'Users are strictly responsible for all text, photos, listings, advertisements, and content they submit. Publishing fraudulent, illegal, defamatory, abusive, or copyright-infringing content is strictly prohibited.\n\nApp administrators reserve the right to review, reject, conceal, or permanently delete any content violating platform guidelines.',
      displayOrder: 9,
    ),
    DisclaimerSectionModel(
      id: '10',
      sectionKey: 'privacy_data',
      titleMr: '१०. गोपनीयता आणि वैयक्तिक माहिती',
      titleEn: '10. Privacy & Personal Information',
      contentMr:
          'वापरकर्त्यांची माहिती कशी गोळा केली जाते, वापरली जाते, साठवली जाते आणि सुरक्षित ठेवली जाते याची सविस्तर माहिती Privacy Policy मध्ये दिली जाईल.\n\nवापरकर्त्यांनी स्वतःची किंवा इतरांची संवेदनशील वैयक्तिक माहिती सार्वजनिकपणे शेअर करू नये.',
      contentEn:
          'Details concerning data collection, storage, and security are governed by our dedicated Privacy Policy.\n\nUsers are cautioned never to publicly disclose sensitive personal credentials, financial PINs, or private identity documents.',
      displayOrder: 10,
    ),
    DisclaimerSectionModel(
      id: '11',
      sectionKey: 'service_availability',
      titleMr: '११. सेवा उपलब्धता',
      titleEn: '11. Service Availability & Maintenance',
      contentMr:
          'तांत्रिक अडचणी, इंटरनेट समस्या, देखभाल किंवा इतर कारणांमुळे App मधील काही सेवा तात्पुरत्या अनुपलब्ध असू शकतात. अखंडित सेवा उपलब्धतेची हमी दिली जात नाही.',
      contentEn:
          'Services may occasionally experience temporary downtime due to server maintenance, telecommunication issues, or factors beyond technical control. Uninterrupted 24/7 service availability is not guaranteed.',
      displayOrder: 11,
    ),
    DisclaimerSectionModel(
      id: '12',
      sectionKey: 'liability_limitation',
      titleMr: '१२. जबाबदारीची मर्यादा',
      titleEn: '12. Limitation of Liability',
      contentMr:
          'लागू कायद्याने परवानगी दिलेल्या मर्यादेत, वापरकर्त्यामधील व्यवहार, चुकीची माहिती, सेवा पुरवठादारांचे वर्तन किंवा बाह्य सेवांमुळे होणाऱ्या नुकसानीसाठी App व्यवस्थापन जबाबदार राहणार नाही. यामुळे कायद्याने नाकारता न येणारे वापरकर्त्यांचे अधिकार मर्यादित होत नाहीत.',
      contentEn:
          'To the maximum extent permitted by applicable Indian law, NARDANA CONNECT and its creators shall not be liable for direct or indirect losses arising from private peer transactions, third-party misinformation, merchant conduct, or external outages. Non-waivable statutory consumer rights remain unaffected.',
      displayOrder: 12,
    ),
    DisclaimerSectionModel(
      id: '13',
      sectionKey: 'disclaimer_changes',
      titleMr: '१३. Disclaimer मधील बदल',
      titleEn: '13. Modifications to Disclaimer',
      contentMr: 'App व्यवस्थापन आवश्यकतेनुसार या Disclaimer मध्ये बदल करू शकते. सुधारित आवृत्ती App मध्ये प्रकाशित केली जाईल.',
      contentEn:
          'Platform administrators reserve the right to revise this Disclaimer as regulations or features evolve. Updated versions will be published dynamically within the application with clear version history.',
      displayOrder: 13,
    ),
    DisclaimerSectionModel(
      id: '14',
      sectionKey: 'contact_support',
      titleMr: '१४. संपर्क',
      titleEn: '14. Support & Office Contact',
      contentMr:
          'NARDANA CONNECT Support\n\nSupport Email: siyainfotechsolar@gmail.com\n\nContact Number: +91 9421889901\n\nOffice Address: नरडाणा (पिन: ४२५४०४), ता. शिंदखेडा, जि. धुळे, महाराष्ट्र.',
      contentEn:
          'NARDANA CONNECT Support\n\nSupport Email: siyainfotechsolar@gmail.com\n\nContact Number: +91 9421889901\n\nOffice Address: Nardana (PIN: 425404), Tal. Shindkheda, Dist. Dhule, Maharashtra.',
      displayOrder: 14,
    ),
  ];
}

