import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../models/wallet_model.dart';

/// Wallet repository for broker coin system.
class WalletRepository {
  final ApiService _apiService;

  WalletRepository({required ApiService apiService}) : _apiService = apiService;

  // ── Get wallet balance & transactions ──
  Future<WalletModel> getWallet({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await _apiService.get(
      ApiEndpoints.wallet,
      queryParams: queryParams,
    );

    // Response format: { balance: number, transactions: [...], pagination: {...} }
    final transactionsList = response['transactions'] as List<dynamic>? ?? [];
    return WalletModel(
      balance: (response['balance'] ?? 0).toDouble(),
      transactions: transactionsList
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  // ── Request withdrawal ──
  Future<Map<String, dynamic>> requestWithdrawal(double amount) async {
    final response = await _apiService.post(
      ApiEndpoints.walletWithdraw,
      body: {'amount': amount},
    );

    // Response format: { newBalance: number, transaction: {...} }
    return response as Map<String, dynamic>;
  }
}
