import 'package:flutter/material.dart';
import '../../../core/utils/error_messages.dart';
import '../../../data/repositories/coin_repository.dart';

/// ViewModel for customer coin wallet.
class CoinWalletViewModel extends ChangeNotifier {
  final CoinRepository _coinRepository;

  CoinWalletViewModel({required CoinRepository coinRepository})
      : _coinRepository = coinRepository;

  // ── State ──
  int _coins = 0;
  int _freePropertyViewsUsed = 0;
  int _freePropertyViewsRemaining = 3;
  List<Map<String, dynamic>> _unlockedProperties = [];
  bool _isLoading = false;
  String? _error;

  // ── Getters ──
  int get coins => _coins;
  int get freePropertyViewsUsed => _freePropertyViewsUsed;
  int get freePropertyViewsRemaining => _freePropertyViewsRemaining;
  List<Map<String, dynamic>> get unlockedProperties => _unlockedProperties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Load wallet data ──
  Future<void> loadWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _coinRepository.getCustomerWallet();
      _coins = data['coins'] ?? 0;
      _freePropertyViewsUsed = data['freePropertyViewsUsed'] ?? 0;
      _freePropertyViewsRemaining = data['freePropertyViewsRemaining'] ?? 0;
      _unlockedProperties = List<Map<String, dynamic>>.from(
        data['unlockedProperties'] ?? [],
      );
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Refresh wallet (after purchase/unlock) ──
  Future<void> refreshWallet() async {
    await loadWallet();
  }
}
