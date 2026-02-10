import 'package:flutter/material.dart';
import '../../../core/utils/error_messages.dart';
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
  Future<void> loadMyProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _properties = await _propertyRepository.getMyProperties();
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load wallet ──
  Future<void> loadWallet() async {
    _isWalletLoading = true;
    notifyListeners();

    try {
      _wallet = await _walletRepository.getWallet();
    } catch (e) {
      _error = ErrorMessages.getContextMessage('wallet', e);
    }

    _isWalletLoading = false;
    notifyListeners();
  }

  // ── Request withdrawal ──
  Future<bool> requestWithdrawal(double amount) async {
    try {
      await _walletRepository.requestWithdrawal(amount);
      await loadWallet(); // Refresh wallet
      return true;
    } catch (e) {
      _error = ErrorMessages.getContextMessage('wallet', e);
      notifyListeners();
      return false;
    }
  }

  // ── Add property ──
  Future<bool> addProperty({
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
    _isLoading = true;
    notifyListeners();

    try {
      await _propertyRepository.addProperty(
        title: title,
        description: description,
        rent: rent,
        deposit: deposit,
        area: area,
        city: city,
        ownerId: ownerId,
        images: images,
        amenities: amenities,
        brokerId: brokerId,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMessages.getContextMessage('property_add', e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
