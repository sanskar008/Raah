import '../models/wallet_model.dart';

/// Wallet repository for broker coin system.
/// Uses dummy data; replace with API calls when backend is ready.
class WalletRepository {
  // ── Get wallet balance & transactions ──
  Future<WalletModel> getWallet(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return WalletModel(
      balance: 250,
      transactions: [
        TransactionModel(
          id: 'txn-1',
          type: 'earn',
          amount: 50,
          description: 'Listed: Cozy Studio Apartment',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TransactionModel(
          id: 'txn-2',
          type: 'earn',
          amount: 50,
          description: 'Listed: Single Room in HSR Layout',
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
        TransactionModel(
          id: 'txn-3',
          type: 'withdraw',
          amount: 100,
          description: 'Withdrawal to bank',
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
        TransactionModel(
          id: 'txn-4',
          type: 'earn',
          amount: 50,
          description: 'Listed: 2BHK near Metro',
          date: DateTime.now().subtract(const Duration(days: 7)),
        ),
        TransactionModel(
          id: 'txn-5',
          type: 'earn',
          amount: 200,
          description: 'Welcome bonus',
          date: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
    );
  }

  // ── Request withdrawal ──
  Future<bool> requestWithdrawal(double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Replace with actual API call
    return true;
  }
}
