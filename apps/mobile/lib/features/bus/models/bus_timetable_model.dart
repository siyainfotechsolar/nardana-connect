class BusTimetableModel {
  final String id;
  final String routeMr;
  final String routeEn;
  final String departureTime;
  final int displayOrder;
  final bool isPublished;

  const BusTimetableModel({
    required this.id,
    required this.routeMr,
    required this.routeEn,
    required this.departureTime,
    this.displayOrder = 0,
    this.isPublished = true,
  });

  factory BusTimetableModel.fromMap(Map<String, dynamic> map) {
    return BusTimetableModel(
      id: map['id']?.toString() ?? '',
      routeMr: map['route_mr']?.toString() ?? '',
      routeEn: map['route_en']?.toString() ?? '',
      departureTime: map['departure_time']?.toString() ?? '',
      displayOrder: (map['display_order'] as num?)?.toInt() ?? 0,
      isPublished: map['is_published'] != false,
    );
  }

  static List<BusTimetableModel> get fallbackList => const [
        BusTimetableModel(
          id: '1',
          routeMr: 'धुळे - शिंदखेडा - नरडाणा - दोंडाईचा',
          routeEn: 'Dhule - Shindkheda - Nardana - Dondaicha',
          departureTime: 'सकाळी ०६:३०',
          displayOrder: 1,
        ),
        BusTimetableModel(
          id: '2',
          routeMr: 'नरडाणा - शिंदखेडा - धुळे (साधी बस)',
          routeEn: 'Nardana - Shindkheda - Dhule (Ordinary)',
          departureTime: 'सकाळी ०७:१५',
          displayOrder: 2,
        ),
        BusTimetableModel(
          id: '3',
          routeMr: 'शिरपूर - नरडाणा - दोंडाईचा (जलद)',
          routeEn: 'Shirpur - Nardana - Dondaicha (Express)',
          departureTime: 'सकाळी ०८:००',
          displayOrder: 3,
        ),
        BusTimetableModel(
          id: '4',
          routeMr: 'धुळे - नरडाणा - शहादा (निमआराम)',
          routeEn: 'Dhule - Nardana - Shahada (Semi-Luxury)',
          departureTime: 'सकाळी ०९:३०',
          displayOrder: 4,
        ),
        BusTimetableModel(
          id: '5',
          routeMr: 'दोंडाईचा - नरडाणा - शिंदखेडा - धुळे',
          routeEn: 'Dondaicha - Nardana - Shindkheda - Dhule',
          departureTime: 'सकाळी १०:४५',
          displayOrder: 5,
        ),
        BusTimetableModel(
          id: '6',
          routeMr: 'धुळे - नरडाणा - शिंदखेडा (लोकल)',
          routeEn: 'Dhule - Nardana - Shindkheda (Local)',
          departureTime: 'दुपारी १२:१५',
          displayOrder: 6,
        ),
        BusTimetableModel(
          id: '7',
          routeMr: 'नंदुरबार - दोंडाईचा - नरडाणा - धुळे',
          routeEn: 'Nandurbar - Dondaicha - Nardana - Dhule',
          departureTime: 'दुपारी ०१:४५',
          displayOrder: 7,
        ),
        BusTimetableModel(
          id: '8',
          routeMr: 'धुळे - नरडाणा - दोंडाईचा - तळोदा',
          routeEn: 'Dhule - Nardana - Dondaicha - Taloda',
          departureTime: 'दुपारी ०३:००',
          displayOrder: 8,
        ),
        BusTimetableModel(
          id: '9',
          routeMr: 'शहादा - नरडाणा - शिंदखेडा - धुळे',
          routeEn: 'Shahada - Nardana - Shindkheda - Dhule',
          departureTime: 'संध्याकाळी ०४:३०',
          displayOrder: 9,
        ),
        BusTimetableModel(
          id: '10',
          routeMr: 'धुळे - नरडाणा - शिरपूर (सायंकाळ फेरी)',
          routeEn: 'Dhule - Nardana - Shirpur (Evening)',
          departureTime: 'संध्याकाळी ०५:४५',
          displayOrder: 10,
        ),
        BusTimetableModel(
          id: '11',
          routeMr: 'दोंडाईचा - नरडाणा - धुळे (रात्र फेरी)',
          routeEn: 'Dondaicha - Nardana - Dhule (Night Service)',
          departureTime: 'रात्री ०७:३०',
          displayOrder: 11,
        ),
        BusTimetableModel(
          id: '12',
          routeMr: 'धुळे - नरडाणा (शेवटची लोकल मुक्काम बस)',
          routeEn: 'Dhule - Nardana (Last Local Halt Bus)',
          departureTime: 'रात्री ०८:४५',
          displayOrder: 12,
        ),
      ];
}

