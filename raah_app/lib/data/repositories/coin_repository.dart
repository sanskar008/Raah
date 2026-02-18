import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../models/coin_pack_model.dart';

/// Coin repository for customer coin system.
class CoinRepository {
  final ApiService _apiService;

  CoinRepository({required ApiService apiService}) : _apiService = apiService;

  // ── Get all coin packs ──
  Future<List<CoinPackModel>> getCoinPacks() async {
    final response = await _apiService.get(
      ApiEndpoints.coinPacks,
      auth: false,
    );

    final packsList = response['packs'] as List<dynamic>? ?? [];
    return packsList
        .map((json) => CoinPackModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Purchase a coin pack ──
  Future<Map<String, dynamic>> purchaseCoinPack(String packId) async {
    final response = await _apiService.post(
      ApiEndpoints.purchaseCoinPack,
      body: {'packId': packId},
    );

    return response as Map<String, dynamic>;
  }

  // ── Unlock a property ──
  Future<Map<String, dynamic>> unlockProperty(String propertyId) async {
    final response = await _apiService.post(
      ApiEndpoints.unlockProperty,
      body: {'propertyId': propertyId},
    );

    return response as Map<String, dynamic>;
  }

  // ── Get customer wallet ──
  Future<Map<String, dynamic>> getCustomerWallet() async {
    final response = await _apiService.get(
      ApiEndpoints.customerWallet,
    );

    return response as Map<String, dynamic>;
  }
}
