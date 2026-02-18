import 'package:flutter/material.dart';
import '../../../core/utils/error_messages.dart';
import '../../../data/models/coin_pack_model.dart';
import '../../../data/repositories/coin_repository.dart';

/// ViewModel for coin packs store.
class CoinStoreViewModel extends ChangeNotifier {
  final CoinRepository _coinRepository;

  CoinStoreViewModel({required CoinRepository coinRepository})
      : _coinRepository = coinRepository;

  // ── State ──
  List<CoinPackModel> _coinPacks = [];
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _error;

  // ── Getters ──
  List<CoinPackModel> get coinPacks => _coinPacks;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get error => _error;

  // ── Load coin packs ──
  Future<void> loadCoinPacks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coinPacks = await _coinRepository.getCoinPacks();
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Purchase coin pack ──
  Future<bool> purchaseCoinPack(String packId) async {
    _isPurchasing = true;
    _error = null;
    notifyListeners();

    try {
      await _coinRepository.purchaseCoinPack(packId);
      _isPurchasing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
      _isPurchasing = false;
      notifyListeners();
      return false;
    }
  }
}
