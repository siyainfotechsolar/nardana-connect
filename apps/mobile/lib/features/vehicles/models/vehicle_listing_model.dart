class VehicleListingModel {
  final String id;
  final String? ownerUserId;
  final String driverName;
  final String vehicleType;
  final String vehicleModel;
  final String? vehicleNumber;
  final int? seatingCapacity;
  final String? loadCapacity;
  final bool acAvailable;
  final String? rentalRateOptional;
  final String contactNumber;
  final String? whatsappNumber;
  final String? locationText;
  final double? latitudeOptional;
  final double? longitudeOptional;
  final String availabilityStatus; // 'available' | 'busy'
  final String verificationStatus; // 'verified' | 'unverified'
  final String approvalStatus; // 'pending' | 'approved' | 'rejected'
  final String? photoUrl;
  final bool isActive;
  final String? villageId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleListingModel({
    required this.id,
    this.ownerUserId,
    required this.driverName,
    required this.vehicleType,
    required this.vehicleModel,
    this.vehicleNumber,
    this.seatingCapacity,
    this.loadCapacity,
    this.acAvailable = false,
    this.rentalRateOptional,
    required this.contactNumber,
    this.whatsappNumber,
    this.locationText,
    this.latitudeOptional,
    this.longitudeOptional,
    this.availabilityStatus = 'available',
    this.verificationStatus = 'verified',
    this.approvalStatus = 'approved',
    this.photoUrl,
    this.isActive = true,
    this.villageId,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAvailable => availabilityStatus.toLowerCase() == 'available';
  bool get isApproved => approvalStatus.toLowerCase() == 'approved';
  bool get isVerified => verificationStatus.toLowerCase() == 'verified';

  String get maskedVehicleNumber {
    if (vehicleNumber == null || vehicleNumber!.trim().isEmpty) {
      return 'नोंदणीकृत वाहन';
    }
    final v = vehicleNumber!.trim();
    if (v.length > 4) {
      return '${v.substring(0, 4)} ••••';
    }
    return '••••';
  }

  factory VehicleListingModel.fromMap(Map<String, dynamic> map) {
    return VehicleListingModel(
      id: map['id']?.toString() ?? '',
      ownerUserId: map['owner_user_id']?.toString(),
      driverName: map['driver_name']?.toString() ?? '',
      vehicleType: map['vehicle_type']?.toString() ?? 'कार',
      vehicleModel: map['vehicle_model']?.toString() ?? '',
      vehicleNumber: map['vehicle_number']?.toString(),
      seatingCapacity: map['seating_capacity'] != null ? int.tryParse(map['seating_capacity'].toString()) : null,
      loadCapacity: map['load_capacity']?.toString(),
      acAvailable: map['ac_available'] == true,
      rentalRateOptional: map['rental_rate_optional']?.toString(),
      contactNumber: map['contact_number']?.toString() ?? '',
      whatsappNumber: map['whatsapp_number']?.toString() ?? map['contact_number']?.toString(),
      locationText: map['location_text']?.toString() ?? 'नरडाणा',
      latitudeOptional: map['latitude_optional'] != null ? double.tryParse(map['latitude_optional'].toString()) : null,
      longitudeOptional: map['longitude_optional'] != null ? double.tryParse(map['longitude_optional'].toString()) : null,
      availabilityStatus: map['availability_status']?.toString() ?? 'available',
      verificationStatus: map['verification_status']?.toString() ?? 'verified',
      approvalStatus: map['approval_status']?.toString() ?? 'approved',
      photoUrl: map['photo_url']?.toString(),
      isActive: map['is_active'] != false,
      villageId: map['village_id']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      'driver_name': driverName,
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (seatingCapacity != null) 'seating_capacity': seatingCapacity,
      if (loadCapacity != null) 'load_capacity': loadCapacity,
      'ac_available': acAvailable,
      if (rentalRateOptional != null) 'rental_rate_optional': rentalRateOptional,
      'contact_number': contactNumber,
      if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
      'location_text': locationText ?? 'नरडाणा',
      if (latitudeOptional != null) 'latitude_optional': latitudeOptional,
      if (longitudeOptional != null) 'longitude_optional': longitudeOptional,
      'availability_status': availabilityStatus,
      'verification_status': verificationStatus,
      'approval_status': approvalStatus,
      if (photoUrl != null) 'photo_url': photoUrl,
      'is_active': isActive,
      if (villageId != null) 'village_id': villageId,
    };
  }

  static List<VehicleListingModel> get fallbackListings => [
        const VehicleListingModel(
          id: '7be96b01-f04d-4950-9f0b-7c8a4ebfcad5',
          driverName: 'कैलास निवृत्ती पाटील',
          vehicleType: 'अर्टिगा (७ सीटर)',
          vehicleModel: 'Maruti Ertiga VXi (CNG/Petrol)',
          vehicleNumber: 'MH 18 BX 4412',
          seatingCapacity: 7,
          acAvailable: true,
          rentalRateOptional: '₹१२ प्रति किमी / वाटाघाटीनुसार',
          contactNumber: '9421889901',
          whatsappNumber: '9421889901',
          locationText: 'स्टेशन परिसर, नरडाणा',
          availabilityStatus: 'available',
          verificationStatus: 'verified',
          approvalStatus: 'approved',
          photoUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=600&q=80',
        ),
        const VehicleListingModel(
          id: '7aea61ef-c432-49a2-9aff-477499e0dd1c',
          driverName: 'सचिन आनंदा माळी',
          vehicleType: 'पिकअप / छोटा हत्ती',
          vehicleModel: 'Mahindra Bolero Maxi Truck Plus',
          vehicleNumber: 'MH 18 BG 9920',
          loadCapacity: '१.५ टन (माल वाहतूक)',
          acAvailable: false,
          rentalRateOptional: 'स्थानिक भाडे सोयीनुसार',
          contactNumber: '9823012344',
          whatsappNumber: '9823012344',
          locationText: 'मेन बाजारपेठ, नरडाणा',
          availabilityStatus: 'available',
          verificationStatus: 'verified',
          approvalStatus: 'approved',
          photoUrl: 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=600&q=80',
        ),
        const VehicleListingModel(
          id: '5dbf6c34-4b8c-483f-9ea0-49de2cf41263',
          driverName: 'दिनेश पोपट चौधरी',
          vehicleType: 'ट्रॅक्टर',
          vehicleModel: 'Mahindra 575 DI (रोटाव्हेटर व ट्रॉलीसह)',
          vehicleNumber: 'MH 18 AK 1102',
          loadCapacity: 'शेती नांगरणी, रोटाव्हेटर, ट्रॉली वाहतूक',
          acAvailable: false,
          rentalRateOptional: '₹८०० प्रति तास / एकरी दर',
          contactNumber: '9765432101',
          whatsappNumber: '9765432101',
          locationText: 'हायवे चौक, नरडाणा',
          availabilityStatus: 'available',
          verificationStatus: 'verified',
          approvalStatus: 'approved',
          photoUrl: 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=600&q=80',
        ),
        const VehicleListingModel(
          id: '4c9e2814-5005-4d4b-8e39-5c35dae61e05',
          driverName: 'अमोल बापू सूर्यवंशी',
          vehicleType: 'जेसीबी (JCB)',
          vehicleModel: 'JCB 3DX Super Earthmover',
          vehicleNumber: 'MH 18 CL 3389',
          loadCapacity: 'खड्डा खोदणे, जमीन सपाटीकरण, मुरुम भरणे',
          acAvailable: false,
          rentalRateOptional: '₹१,१०० प्रति तास',
          contactNumber: '9822334456',
          whatsappNumber: '9822334456',
          locationText: 'शिरपूर रोड, नरडाणा',
          availabilityStatus: 'available',
          verificationStatus: 'verified',
          approvalStatus: 'approved',
          photoUrl: 'https://images.unsplash.com/photo-1579829366248-204fe8413f31?auto=format&fit=crop&w=600&q=80',
        ),
        const VehicleListingModel(
          id: '015d48f5-e9f9-4f32-9289-08d529f2d4a6',
          driverName: 'ज्ञानेश्वर भाऊराव पाटील',
          vehicleType: 'इनोव्हा',
          vehicleModel: 'Toyota Innova Crysta 2.4 VX',
          vehicleNumber: 'MH 18 AB 7788',
          seatingCapacity: 7,
          acAvailable: true,
          rentalRateOptional: '₹१४ प्रति किमी (लांब पल्ल्यासाठी)',
          contactNumber: '9422771122',
          whatsappNumber: '9422771122',
          locationText: 'स्टेशन रोड, नरडाणा',
          availabilityStatus: 'busy',
          verificationStatus: 'verified',
          approvalStatus: 'approved',
          photoUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=600&q=80',
        ),
      ];
}
