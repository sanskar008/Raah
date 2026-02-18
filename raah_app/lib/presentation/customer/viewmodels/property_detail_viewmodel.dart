import 'package:flutter/material.dart';
import '../../../core/utils/error_messages.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../data/repositories/coin_repository.dart';

/// ViewModel for property detail + appointment booking + unlock.
class PropertyDetailViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;
  final AppointmentRepository _appointmentRepository;
  final CoinRepository? _coinRepository;

  PropertyDetailViewModel({
    required PropertyRepository propertyRepository,
    required AppointmentRepository appointmentRepository,
    CoinRepository? coinRepository,
  })  : _propertyRepository = propertyRepository,
        _appointmentRepository = appointmentRepository,
        _coinRepository = coinRepository;

  // ── State ──
  PropertyModel? _property;
  bool _isLoading = false;
  bool _isBooking = false;
  bool _isUnlocking = false;
  String? _error;
  bool _bookingSuccess = false;

  // ── Getters ──
  PropertyModel? get property => _property;
  bool get isLoading => _isLoading;
  bool get isBooking => _isBooking;
  bool get isUnlocking => _isUnlocking;
  String? get error => _error;
  bool get bookingSuccess => _bookingSuccess;
  
  bool get isUnlocked => _property?.isUnlocked ?? false;

  // ── Load property details ──
  Future<void> loadProperty(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _property = await _propertyRepository.getPropertyById(id);
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Set property directly (from card tap) ──
  void setProperty(PropertyModel property) {
    _property = property;
    notifyListeners();
  }

  // ── Book appointment ──
  Future<bool> bookAppointment({
    required DateTime date,
    required String time,
  }) async {
    if (_property == null) return false;

    _isBooking = true;
    _bookingSuccess = false;
    _error = null;
    notifyListeners();

    try {
      await _appointmentRepository.bookAppointment(
        propertyId: _property!.id,
        date: date,
        time: time,
      );
      _bookingSuccess = true;
      _isBooking = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMessages.getContextMessage('appointment', e);
      _isBooking = false;
      notifyListeners();
      return false;
    }
  }

  // ── Unlock property ──
  Future<bool> unlockProperty() async {
    if (_property == null || _coinRepository == null) return false;

    _isUnlocking = true;
    _error = null;
    notifyListeners();

    try {
      await _coinRepository.unlockProperty(_property!.id);
      
      // Update property unlock status
      if (_property != null) {
        _property = PropertyModel(
          id: _property!.id,
          title: _property!.title,
          description: _property!.description,
          propertyType: _property!.propertyType,
          rent: _property!.rent,
          deposit: _property!.deposit,
          address: _property!.address,
          area: _property!.area,
          city: _property!.city,
          imageUrls: _property!.imageUrls,
          amenities: _property!.amenities,
          ownerId: _property!.ownerId,
          ownerName: _property!.ownerName,
          ownerPhone: _property!.ownerPhone,
          isBrokerListed: _property!.isBrokerListed,
          bedrooms: _property!.bedrooms,
          bathrooms: _property!.bathrooms,
          areaSqFt: _property!.areaSqFt,
          isAvailable: _property!.isAvailable,
          createdAt: _property!.createdAt,
          isUnlocked: true,
        );
      }
      
      _isUnlocking = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMessages.getContextMessage('unlock', e);
      _isUnlocking = false;
      notifyListeners();
      return false;
    }
  }
}
