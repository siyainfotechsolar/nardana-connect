import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('mr'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'mr': {
      'app_name': 'नरडाणा कनेक्ट',
      'tagline': 'आपलं गाव, आपली डिजिटल ओळख!',
      'select_village': 'गाव निवडा',
      'all_villages': 'सर्व गावे',
      'search_hint': 'सेवा, दुकान किंवा व्यावसायिक शोधा...',
      'categories': 'सेवा व दुकाने',
      'view_all': 'सर्व पहा',
      'emergency_services': 'आपत्कालीन सेवा',
      'village_notices': 'गाव सूचना व घोषणा',
      'jobs': 'रोजगार व नोकऱ्या',
      'buy_sell': 'खरेदी - विक्री',
      'home': 'मुख्य',
      'explore': 'शोधा',
      'post': 'पोस्ट करा',
      'updates': 'सूचना',
      'profile': 'प्रोफाइल',
      'call_now': 'कॉल करा',
      'whatsapp': 'व्हॉट्सॲप',
      'directions': 'मार्ग पहा',
      'favorites': 'माझे सेव्ह केलेले',
      'change_language': 'भाषा बदला (Change Language)',
      'choose_language': 'कृपया तुमची पसंतीची भाषा निवडा',
      'marathi': 'मराठी',
      'english': 'English',
      'continue_btn': 'पुढे जा',
      'welcome_title': 'आपल्या गावात आपले स्वागत आहे!',
      'welcome_subtitle': 'नरडाणा आणि परिसरातील सर्व माहिती एकाच ठिकाणी.',
      'login_with_phone': 'मोबाईल नंबरने लॉगिन करा',
      'skip_for_now': 'आताच पुढे जा (नोंदणीशिवाय)',
      'my_listings': 'माझ्या जाहिराती',
      'help_support': 'मदत व संपर्क',
      'free_citizen_access': 'नागरिकांसाठी १००% मोफत',
      'verified_service': 'पडताळणीकृत',
      'gram_panchayat_official': 'ग्रामपंचायत अधिकृत',
    },
    'en': {
      'app_name': 'Nardana Connect',
      'tagline': 'Our Village, Our Digital Identity!',
      'select_village': 'Select Village',
      'all_villages': 'All Villages',
      'search_hint': 'Search services, shops, or businesses...',
      'categories': 'Services & Shops',
      'view_all': 'View All',
      'emergency_services': 'Emergency Services',
      'village_notices': 'Village Notices & Updates',
      'jobs': 'Jobs & Employment',
      'buy_sell': 'Buy & Sell',
      'home': 'Home',
      'explore': 'Explore',
      'post': 'Post',
      'updates': 'Notices',
      'profile': 'Profile',
      'call_now': 'Call Now',
      'whatsapp': 'WhatsApp',
      'directions': 'Directions',
      'favorites': 'My Saved',
      'change_language': 'Change Language',
      'choose_language': 'Please select your preferred language',
      'marathi': 'मराठी',
      'english': 'English',
      'continue_btn': 'Continue',
      'welcome_title': 'Welcome to Your Village App!',
      'welcome_subtitle': 'All village services and updates for Nardana in one place.',
      'login_with_phone': 'Login with Mobile Number',
      'skip_for_now': 'Browse Directly (No Login Required)',
      'my_listings': 'My Listings',
      'help_support': 'Help & Support',
      'free_citizen_access': '100% Free for Citizens',
      'verified_service': 'Verified',
      'gram_panchayat_official': 'Gram Panchayat Official',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['mr']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['mr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

