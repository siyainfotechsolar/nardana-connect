import 'dart:developer' as developer;
import 'package:nardana_connect/core/services/supabase_service.dart';
import '../models/village_update_model.dart';

class VillageUpdatesService {
  VillageUpdatesService._();
  static final VillageUpdatesService instance = VillageUpdatesService._();

  final List<VillageUpdateModel> _fallbackUpdates = [
    const VillageUpdateModel(
      id: 'e1000000-0000-0000-0000-000000000001',
      category: 'kirtan_bhajan',
      titleMr: 'अखंड हरिनाम सप्ताह व काकड आरती सोहळा',
      titleEn: 'Akhand Harinam Saptah & Bhajan Festival',
      descriptionMr:
          'नरडाणा ग्रामस्थांच्या वतीने आयोजित भव्य अखंड हरिनाम सप्ताह, ग्रंथराज ज्ञानेश्वरी पारायण आणि रोज सायंकाळी महाराष्ट्रातील नामवंत कीर्तनकारांचे सुश्राव्य कीर्तन. महाप्रसादाचा लाभ घ्यावा.',
      eventDate: '2026-11-20',
      eventTime: 'दररोज सायं. ६:०० ते रात्री ८:३०',
      venueMr: 'श्री विठ्ठल रुक्मिणी मंदिर प्रांगण, नरडाणा',
      organizerName: 'श्री विठ्ठल मंदिर उत्सव समिती, नरडाणा',
      organizerContact: '9823012345',
      posterUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=800&q=80',
      latitude: 21.2885,
      longitude: 74.8388,
      status: 'published',
      isApproved: true,
    ),
    const VillageUpdateModel(
      id: 'e1000000-0000-0000-0000-000000000002',
      category: 'health_camp',
      titleMr: 'भव्य मोफत आरोग्य तपासणी व नेत्रचिकित्सा शिबीर',
      titleEn: 'Free Health Checkup & Eye Care Camp',
      descriptionMr:
          'प्राथमिक आरोग्य केंद्र नरडाणा व धुळे सिव्हिल हॉस्पिटल यांच्या संयुक्त विद्यमाने मोफत रक्तदाब, मधुमेह, हृदय तपासणी, औषध वाटप व मोफत मोतीबिंदू शस्त्रक्रिया मार्गदर्शन.',
      eventDate: '2026-11-18',
      eventTime: 'सकाळी ९:०० ते दुपारी २:००',
      venueMr: 'प्राथमिक आरोग्य केंद्र (PHC), नरडाणा',
      organizerName: 'आरोग्य विभाग व ग्रामपंचायत नरडाणा',
      organizerContact: '02566245100',
      posterUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=800&q=80',
      latitude: 21.2890,
      longitude: 74.8375,
      status: 'published',
      isApproved: true,
    ),
    const VillageUpdateModel(
      id: 'e1000000-0000-0000-0000-000000000003',
      category: 'shop_opening',
      titleMr: 'नवीन दुकान भव्य उद्घाटन: आई भवानी हार्डवेअर',
      titleEn: 'Grand Opening: Aai Bhavani Hardware',
      descriptionMr:
          'नरडाणा ग्रामस्थांच्या सेवेसाठी सर्व प्रकारचे सिमेंट, पाईप, फिटिंग, पेंट्स, शेती अवजारे आणि इलेक्ट्रिक साहित्याचे नवीन भव्य दुकान सुरू होत आहे. उद्घाटनास उपस्थित राहून आशीर्वाद द्यावेत.',
      eventDate: '2026-11-15',
      eventTime: 'सकाळी १०:३० वाजता',
      venueMr: 'स्टेशन रोड, रेल्वे गेट जवळ, नरडाणा',
      organizerName: 'सचिन पाटील व परिवार',
      organizerContact: '9422054321',
      posterUrl: 'https://images.unsplash.com/photo-1581783342308-f792dbdd27c5?auto=format&fit=crop&w=800&q=80',
      latitude: 21.2878,
      longitude: 74.8395,
      status: 'published',
      isApproved: true,
    ),
    const VillageUpdateModel(
      id: 'e1000000-0000-0000-0000-000000000004',
      category: 'school_education',
      titleMr: 'नरडाणा हायस्कूल: विज्ञान व कला शाखा प्रवेश सूचना',
      titleEn: 'Nardana High School Admissions',
      descriptionMr:
          'नरडाणा पंचक्रोशीतील विद्यार्थ्यांसाठी इयत्ता ११ वी व १२ वी सायन्स, आर्ट्स आणि व्होकेशनल अभ्यासक्रमांचे प्रवेश अर्ज सुरू झाले आहेत. सर्व शासकीय शिष्यवृत्ती व मोफत बस पास सुविधा उपलब्ध.',
      eventDate: '2026-11-25',
      eventTime: 'सकाळी १०:०० ते सायं. ५:००',
      venueMr: 'नरडाणा हायस्कूल व ज्युनियर कॉलेज',
      organizerName: 'प्राचार्य व शिक्षण समिती, नरडाणा',
      organizerContact: '02566245150',
      posterUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?auto=format&fit=crop&w=800&q=80',
      latitude: 21.2865,
      longitude: 74.8360,
      status: 'published',
      isApproved: true,
    ),
    const VillageUpdateModel(
      id: 'e1000000-0000-0000-0000-000000000005',
      category: 'announcement',
      titleMr: 'महत्त्वाची जाहीर ग्रामसभा सूचना: पाणी व रस्ते विकास',
      titleEn: 'Public Gram Sabha Meeting Notice',
      descriptionMr:
          'नरडाणा ग्रामपंचायत अंतर्गत गाव पाणीपुरवठा पाईपलाईन दुरुस्ती, भूमिगत गटर योजना व नवीन रस्ते डांबरीकरण कामाच्या मंजुरीसाठी जाहीर विशेष ग्रामसभेचे आयोजन केले आहे. सर्व नागरिकांनी उपस्थित राहावे.',
      eventDate: '2026-11-22',
      eventTime: 'सकाळी ११:०० वाजता',
      venueMr: 'ग्रामपंचायत कार्यालय प्रांगण, नरडाणा',
      organizerName: 'सरपंच व ग्रामविकास अधिकारी, नरडाणा',
      organizerContact: '02566245111',
      posterUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80',
      latitude: 21.2882,
      longitude: 74.8386,
      status: 'published',
      isApproved: true,
    ),
  ];

  Future<List<VillageUpdateModel>> getPublishedUpdates({String? category}) async {
    try {
      final supabase = SupabaseService.client;
      var filter = supabase
          .from('village_updates')
          .select('*')
          .eq('status', 'published')
          .eq('is_approved', true);

      if (category != null && category.isNotEmpty && category != 'all') {
        filter = filter.eq('category', category);
      }

      final response = await filter.order('event_date', ascending: true);
      final list = (response as List).map((row) => VillageUpdateModel.fromJson(row)).toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      developer.log('Error loading village updates from Supabase: $e');
    }

    if (category != null && category != 'all') {
      return _fallbackUpdates.where((u) => u.category == category).toList();
    }
    return _fallbackUpdates;
  }

  Future<VillageUpdateModel?> getUpdateById(String id) async {
    try {
      final supabase = SupabaseService.client;
      final response = await supabase
          .from('village_updates')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        return VillageUpdateModel.fromJson(response);
      }
    } catch (e) {
      developer.log('Error fetching update by id $id: $e');
    }

    try {
      return _fallbackUpdates.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> submitUpdate({
    required String category,
    required String titleMr,
    required String descriptionMr,
    String? eventDate,
    String? eventTime,
    String? venueMr,
    String? organizerName,
    String? organizerContact,
    String? posterUrl,
  }) async {
    try {
      final supabase = SupabaseService.client;
      await supabase.from('village_updates').insert({
        'village_id': 'a0000000-0000-0000-0000-000000000001',
        'category': category,
        'title_mr': titleMr.trim(),
        'description_mr': descriptionMr.trim(),
        'event_date': eventDate,
        'event_time': eventTime?.trim(),
        'venue_mr': venueMr?.trim(),
        'organizer_name': organizerName?.trim(),
        'organizer_contact': organizerContact?.trim(),
        'poster_url': posterUrl?.trim(),
        'status': 'pending',
        'is_approved': false,
        'submitted_by_user_id': supabase.auth.currentUser?.id,
      });
      return true;
    } catch (e) {
      developer.log('Error submitting village update: $e');
      return false;
    }
  }
}

