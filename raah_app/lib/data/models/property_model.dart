import '../../domain/enums/property_type.dart';

/// Property listing model — core data object for the app.
class PropertyModel {
  final String id;
  final String title;
  final String description;
  final PropertyType propertyType;
  final double rent;
  final double? deposit;
  final String address;
  final String area;
  final String city;
  final List<String> imageUrls;
  final List<String> amenities;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final bool isBrokerListed;
  final int? bedrooms;
  final int? bathrooms;
  final double? areaSqFt;
  final bool isAvailable;
  final DateTime? createdAt;
  final bool? isUnlocked; // Whether customer has unlocked this property

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.rent,
    this.deposit,
    required this.address,
    required this.area,
    required this.city,
    required this.imageUrls,
    this.amenities = const [],
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    this.isBrokerListed = false,
    this.bedrooms,
    this.bathrooms,
    this.areaSqFt,
    this.isAvailable = true,
    this.createdAt,
    this.isUnlocked,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB _id format and populated ownerId/brokerId
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    
    // Handle populated ownerId (can be object or string)
    final ownerIdObj = json['ownerId'];
    final ownerId = ownerIdObj is Map 
        ? (ownerIdObj['_id']?.toString() ?? ownerIdObj['id']?.toString() ?? '')
        : ownerIdObj?.toString() ?? json['owner_id']?.toString() ?? '';
    
    final ownerName = ownerIdObj is Map 
        ? (ownerIdObj['name'] ?? '')
        : json['ownerName'] ?? json['owner_name'] ?? '';
    
    final ownerPhone = ownerIdObj is Map 
        ? (ownerIdObj['phone'] ?? '')
        : json['ownerPhone'] ?? json['owner_phone'] ?? '';
    
    // Check if brokerId exists (broker listed)
    final brokerIdObj = json['brokerId'];
    final isBrokerListed = brokerIdObj != null;
    
    return PropertyModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      propertyType: PropertyType.fromString(json['propertyType'] ?? json['property_type'] ?? 'room'),
      rent: (json['rent'] ?? 0).toDouble(),
      deposit: json['deposit']?.toDouble(),
      address: json['address'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      imageUrls: List<String>.from(json['images'] ?? json['image_urls'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      isBrokerListed: isBrokerListed,
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      areaSqFt: json['areaSqFt'] ?? json['area_sq_ft']?.toDouble(),
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      isUnlocked: json['isUnlocked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'property_type': propertyType.value,
      'rent': rent,
      'deposit': deposit,
      'address': address,
      'area': area,
      'city': city,
      'image_urls': imageUrls,
      'amenities': amenities,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'is_broker_listed': isBrokerListed,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area_sq_ft': areaSqFt,
      'is_available': isAvailable,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
