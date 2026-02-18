import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../models/rental_plan_model.dart';

/// Rental repository for owner rental period system.
class RentalRepository {
  final ApiService _apiService;

  RentalRepository({required ApiService apiService}) : _apiService = apiService;

  // ── Get rental plans ──
  Future<List<RentalPlanModel>> getRentalPlans() async {
    final response = await _apiService.get(
      ApiEndpoints.rentalPlans,
      auth: false,
    );

    final plansList = response['plans'] as List<dynamic>? ?? [];
    return plansList
        .map((json) => RentalPlanModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Purchase a rental period ──
  Future<Map<String, dynamic>> purchaseRentalPeriod({
    required String propertyId,
    required int days,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.purchaseRentalPeriod,
      body: {
        'propertyId': propertyId,
        'days': days,
      },
    );

    return response as Map<String, dynamic>;
  }

  // ── Get owner's rentals ──
  Future<Map<String, dynamic>> getMyRentals() async {
    final response = await _apiService.get(
      ApiEndpoints.myRentals,
    );

    return response as Map<String, dynamic>;
  }
}
