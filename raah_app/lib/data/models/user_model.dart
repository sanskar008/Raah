import '../../domain/enums/user_role.dart';

/// User data model — maps to API response and local storage.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final int coins;
  final String? referralCode;
  final int referredCount;
  final double? locationLat;
  final double? locationLng;
  final String? locationAddress;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImageUrl,
    this.createdAt,
    this.coins = 0,
    this.referralCode,
    this.referredCount = 0,
    this.locationLat,
    this.locationLng,
    this.locationAddress,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB _id format
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final locationObj = json['location'];
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'customer'),
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      coins: (json['coins'] ?? 0) as int,
      referralCode: json['referralCode']?.toString(),
      referredCount: (json['referredCount'] ?? 0) as int,
      locationLat: locationObj is Map ? locationObj['lat']?.toDouble() : null,
      locationLng: locationObj is Map ? locationObj['lng']?.toDouble() : null,
      locationAddress: locationObj is Map ? locationObj['address']?.toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.value,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt?.toIso8601String(),
      'coins': coins,
      'referralCode': referralCode,
      'referredCount': referredCount,
      'location': locationLat != null
          ? {'lat': locationLat, 'lng': locationLng, 'address': locationAddress}
          : null,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
    int? coins,
    String? referralCode,
    int? referredCount,
    double? locationLat,
    double? locationLng,
    String? locationAddress,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      coins: coins ?? this.coins,
      referralCode: referralCode ?? this.referralCode,
      referredCount: referredCount ?? this.referredCount,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      locationAddress: locationAddress ?? this.locationAddress,
    );
  }
}
