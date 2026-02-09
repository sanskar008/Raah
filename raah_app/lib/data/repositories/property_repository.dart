import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../models/property_model.dart';
import '../../domain/enums/property_type.dart';

/// Property repository — provides property data.
class PropertyRepository {
  final ApiService _apiService;

  PropertyRepository({required ApiService apiService}) : _apiService = apiService;

  // ── Fetch all properties (with optional filters) ──
  Future<List<PropertyModel>> getProperties({
    String? area,
    String? city,
    double? minRent,
    double? maxRent,
    PropertyType? propertyType,
    List<String>? amenities,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (area != null && area.isNotEmpty) queryParams['area'] = area;
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (minRent != null) queryParams['minRent'] = minRent.toString();
    if (maxRent != null) queryParams['maxRent'] = maxRent.toString();
    if (amenities != null && amenities.isNotEmpty) {
      queryParams['amenities'] = amenities.join(',');
    }

    final response = await _apiService.get(
      ApiEndpoints.properties,
      queryParams: queryParams,
      auth: false,
    );

    // Response format: { properties: [...], pagination: {...} }
    final propertiesList = response['properties'] as List<dynamic>? ?? [];
    return propertiesList
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Fetch single property ──
  Future<PropertyModel> getPropertyById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.propertyById(id),
      auth: false,
    );

    // Response format: { property: {...} }
    final propertyData = response['property'] ?? response;
    return PropertyModel.fromJson(propertyData as Map<String, dynamic>);
  }

  // ── Fetch properties by owner/broker ──
  Future<List<PropertyModel>> getMyProperties({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await _apiService.get(
      ApiEndpoints.myProperties,
      queryParams: queryParams,
    );

    // Response format: { properties: [...], pagination: {...} }
    final propertiesList = response['properties'] as List<dynamic>? ?? [];
    return propertiesList
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Add new property ──
  Future<PropertyModel> addProperty({
    required String title,
    required String description,
    required double rent,
    required double deposit,
    required String area,
    required String city,
    required String ownerId,
    List<String>? images,
    List<String>? amenities,
    String? brokerId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'rent': rent,
      'deposit': deposit,
      'area': area,
      'city': city,
      'ownerId': ownerId,
    };

    if (images != null && images.isNotEmpty) {
      body['images'] = images;
    }
    if (amenities != null && amenities.isNotEmpty) {
      body['amenities'] = amenities;
    }
    if (brokerId != null) {
      body['brokerId'] = brokerId;
    }

    final response = await _apiService.post(
      ApiEndpoints.properties,
      body: body,
    );

    // Response format: { property: {...} }
    final propertyData = response['property'] ?? response;
    return PropertyModel.fromJson(propertyData as Map<String, dynamic>);
  }
}
