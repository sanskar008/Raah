import 'package:flutter/material.dart';
import '../../../core/utils/error_messages.dart';
import '../../../data/models/rental_plan_model.dart';
import '../../../data/repositories/rental_repository.dart';

/// ViewModel for owner rental management.
class RentalViewModel extends ChangeNotifier {
  final RentalRepository _rentalRepository;

  RentalViewModel({required RentalRepository rentalRepository})
      : _rentalRepository = rentalRepository;

  // ── State ──
  List<RentalPlanModel> _rentalPlans = [];
  List<Map<String, dynamic>> _subscriptions = [];
  List<Map<String, dynamic>> _properties = [];
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _error;

  // ── Getters ──
  List<RentalPlanModel> get rentalPlans => _rentalPlans;
  List<Map<String, dynamic>> get subscriptions => _subscriptions;
  List<Map<String, dynamic>> get properties => _properties;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get error => _error;

  // ── Load rental plans ──
  Future<void> loadRentalPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rentalPlans = await _rentalRepository.getRentalPlans();
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load owner rentals ──
  Future<void> loadMyRentals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _rentalRepository.getMyRentals();
      _subscriptions = List<Map<String, dynamic>>.from(
        data['subscriptions'] ?? [],
      );
      _properties = List<Map<String, dynamic>>.from(
        data['properties'] ?? [],
      );
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Purchase rental period ──
  Future<bool> purchaseRentalPeriod({
    required String propertyId,
    required int days,
  }) async {
    _isPurchasing = true;
    _error = null;
    notifyListeners();

    try {
      await _rentalRepository.purchaseRentalPeriod(
        propertyId: propertyId,
        days: days,
      );
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
