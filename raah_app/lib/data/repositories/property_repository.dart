import '../models/property_model.dart';
import '../../domain/enums/property_type.dart';

/// Property repository — provides property data.
/// Uses dummy data now; replace with API calls when backend is ready.
class PropertyRepository {
  // ── Fetch all properties (with optional filters) ──
  Future<List<PropertyModel>> getProperties({
    String? area,
    double? minRent,
    double? maxRent,
    PropertyType? propertyType,
    int page = 1,
  }) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 800));
    return _dummyProperties.where((p) {
      if (area != null && area.isNotEmpty) {
        if (!p.area.toLowerCase().contains(area.toLowerCase())) return false;
      }
      if (minRent != null && p.rent < minRent) return false;
      if (maxRent != null && p.rent > maxRent) return false;
      if (propertyType != null && p.propertyType != propertyType) return false;
      return true;
    }).toList();
  }

  // ── Fetch single property ──
  Future<PropertyModel> getPropertyById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyProperties.firstWhere((p) => p.id == id);
  }

  // ── Fetch properties by owner/broker ──
  Future<List<PropertyModel>> getMyProperties(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _dummyProperties.where((p) => p.ownerId == userId).toList();
  }

  // ── Add new property ──
  Future<PropertyModel> addProperty(PropertyModel property) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Replace with actual API call
    return property;
  }

  // ── Dummy data ──
  static final List<PropertyModel> _dummyProperties = [
    PropertyModel(
      id: '1',
      title: 'Cozy Studio Apartment in Koramangala',
      description:
          'A beautifully furnished studio apartment perfect for students and young professionals. '
          'Located in the heart of Koramangala with easy access to cafes, restaurants, and IT parks. '
          'The apartment features a modern kitchen, high-speed wifi, and a comfortable workspace.',
      propertyType: PropertyType.flat,
      rent: 15000,
      deposit: 30000,
      address: '3rd Cross, 5th Block, Koramangala',
      area: 'Koramangala',
      city: 'Bangalore',
      imageUrls: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      ],
      amenities: ['WiFi', 'AC', 'Washing Machine', 'Kitchen', 'Parking'],
      ownerId: '1',
      ownerName: 'Rahul Sharma',
      ownerPhone: '9876543210',
      bedrooms: 1,
      bathrooms: 1,
      areaSqFt: 450,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PropertyModel(
      id: '2',
      title: 'Spacious 2BHK near Indiranagar Metro',
      description:
          'A well-maintained 2BHK apartment with great ventilation and natural light. '
          'Walking distance to Indiranagar Metro Station and 100 Feet Road. '
          'Semi-furnished with wardrobes, fans, and geysers.',
      propertyType: PropertyType.flat,
      rent: 25000,
      deposit: 50000,
      address: '12th Main, HAL 2nd Stage, Indiranagar',
      area: 'Indiranagar',
      city: 'Bangalore',
      imageUrls: [
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
        'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800',
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
      ],
      amenities: ['WiFi', 'AC', 'Gym', 'Security', 'Power Backup', 'Lift'],
      ownerId: '2',
      ownerName: 'Priya Patel',
      ownerPhone: '9876543211',
      bedrooms: 2,
      bathrooms: 2,
      areaSqFt: 950,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PropertyModel(
      id: '3',
      title: 'Single Room in HSR Layout',
      description:
          'Affordable single room in a shared flat. Perfect for students. '
          'Includes common kitchen, washing area, and balcony access. '
          'Near sector 2, close to restaurants and grocery stores.',
      propertyType: PropertyType.room,
      rent: 8000,
      deposit: 16000,
      address: 'Sector 2, HSR Layout',
      area: 'HSR Layout',
      city: 'Bangalore',
      imageUrls: [
        'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800',
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
      ],
      amenities: ['WiFi', 'Geyser', 'Shared Kitchen', 'Balcony'],
      ownerId: '1',
      ownerName: 'Rahul Sharma',
      ownerPhone: '9876543210',
      isBrokerListed: true,
      bedrooms: 1,
      bathrooms: 1,
      areaSqFt: 200,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PropertyModel(
      id: '4',
      title: 'Premium PG for Women in BTM Layout',
      description:
          'Fully furnished PG accommodation for working women. '
          'Triple/double sharing available with attached bathrooms. '
          'Includes meals, housekeeping, and laundry service.',
      propertyType: PropertyType.pg,
      rent: 10000,
      deposit: 10000,
      address: '1st Stage, BTM Layout',
      area: 'BTM Layout',
      city: 'Bangalore',
      imageUrls: [
        'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800',
        'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800',
      ],
      amenities: [
        'Meals', 'WiFi', 'AC', 'Housekeeping', 'Laundry', 'Security'
      ],
      ownerId: '3',
      ownerName: 'Meera Joshi',
      ownerPhone: '9876543212',
      bedrooms: 1,
      bathrooms: 1,
      areaSqFt: 150,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    PropertyModel(
      id: '5',
      title: 'Modern 3BHK Apartment in Whitefield',
      description:
          'Luxurious 3BHK apartment in a gated community. '
          'Features modular kitchen, wooden flooring, and large balconies. '
          'Close to ITPL and major tech parks.',
      propertyType: PropertyType.apartment,
      rent: 35000,
      deposit: 70000,
      address: 'Prestige Shantiniketan, Whitefield',
      area: 'Whitefield',
      city: 'Bangalore',
      imageUrls: [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
        'https://images.unsplash.com/photo-1600566753376-12c8ab7c01a6?w=800',
      ],
      amenities: [
        'Swimming Pool', 'Gym', 'Club House', 'Security', 'Power Backup',
        'Parking', 'Children Play Area', 'Garden'
      ],
      ownerId: '2',
      ownerName: 'Priya Patel',
      ownerPhone: '9876543211',
      bedrooms: 3,
      bathrooms: 3,
      areaSqFt: 1800,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PropertyModel(
      id: '6',
      title: 'Budget Room near Marathahalli Bridge',
      description:
          'Affordable single room on the main road. '
          'Easy access to public transport and ORR. '
          'Basic furnishing with bed, fan, and cupboard.',
      propertyType: PropertyType.room,
      rent: 6000,
      deposit: 12000,
      address: 'Near Marathahalli Bridge, Outer Ring Road',
      area: 'Marathahalli',
      city: 'Bangalore',
      imageUrls: [
        'https://images.unsplash.com/photo-1598928506311-c55ez633a1ab?w=800',
        'https://images.unsplash.com/photo-1564078516393-cf04bd966897?w=800',
      ],
      amenities: ['Fan', 'Cupboard', 'Water Supply'],
      ownerId: '3',
      ownerName: 'Meera Joshi',
      ownerPhone: '9876543212',
      isBrokerListed: true,
      bedrooms: 1,
      bathrooms: 1,
      areaSqFt: 120,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];
}
