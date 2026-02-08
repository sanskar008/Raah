import 'package:flutter/material.dart';
import '../../../data/models/property_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../data/repositories/wallet_repository.dart';

/// Broker ViewModel — manages dashboard, property list, and wallet.
class BrokerViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;
  final WalletRepository _walletRepository;

  BrokerViewModel({
    required PropertyRepository propertyRepository,
    required WalletRepository walletRepository,
  })  : _propertyRepository = propertyRepository,
        _walletRepository = walletRepository;

  // ── State ──
  List<PropertyModel> _properties = [];
  WalletModel? _wallet;
  bool _isLoading = false;
  bool _isWalletLoading = false;
  String? _error;

  // ── Getters ──
  List<PropertyModel> get properties => _properties;
  WalletModel? get wallet => _wallet;
  bool get isLoading => _isLoading;
  bool get isWalletLoading => _isWalletLoading;
  String? get error => _error;
  double get coinBalance => _wallet?.balance ?? 0;

  // ── Load broker's properties ──
  Future<void> loadMyProperties(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _properties = await _propertyRepository.getMyProperties(userId);
    } catch (e) {
      _error = 'Failed to load properties';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load wallet ──
  Future<void> loadWallet(String userId) async {
    _isWalletLoading = true;
    notifyListeners();

    try {
      _wallet = await _walletRepository.getWallet(userId);
    } catch (e) {
      _error = 'Failed to load wallet';
    }

    _isWalletLoading = false;
    notifyListeners();
  }

  // ── Request withdrawal ──
  Future<bool> requestWithdrawal(double amount) async {
    try {
      final success = await _walletRepository.requestWithdrawal(amount);
      if (success) {
        await loadWallet('1'); // Refresh wallet
      }
      return success;
    } catch (e) {
      _error = 'Withdrawal failed';
      notifyListeners();
      return false;
    }
  }

  // ── Add property ──
  Future<bool> addProperty(PropertyModel property) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _propertyRepository.addProperty(property);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add property';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
