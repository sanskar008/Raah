import 'package:flutter/material.dart';
import '../../../data/models/property_model.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../domain/enums/appointment_status.dart';

/// Owner ViewModel — manages owned properties and incoming appointments.
class OwnerViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;
  final AppointmentRepository _appointmentRepository;

  OwnerViewModel({
    required PropertyRepository propertyRepository,
    required AppointmentRepository appointmentRepository,
  })  : _propertyRepository = propertyRepository,
        _appointmentRepository = appointmentRepository;

  // ── State ──
  List<PropertyModel> _properties = [];
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  bool _isAppointmentsLoading = false;
  String? _error;

  // ── Getters ──
  List<PropertyModel> get properties => _properties;
  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  bool get isAppointmentsLoading => _isAppointmentsLoading;
  String? get error => _error;

  int get pendingAppointments =>
      _appointments.where((a) => a.status == AppointmentStatus.pending).length;

  // ── Load owned properties ──
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

  // ── Load incoming appointments ──
  Future<void> loadAppointments(String ownerId) async {
    _isAppointmentsLoading = true;
    notifyListeners();

    try {
      _appointments =
          await _appointmentRepository.getOwnerAppointments(ownerId);
    } catch (e) {
      _error = 'Failed to load appointments';
    }

    _isAppointmentsLoading = false;
    notifyListeners();
  }

  // ── Accept/Reject appointment ──
  Future<void> updateAppointmentStatus(
      String id, AppointmentStatus status) async {
    try {
      await _appointmentRepository.updateStatus(id, status);
      // Refresh
      await loadAppointments('1');
    } catch (e) {
      _error = 'Failed to update appointment';
      notifyListeners();
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
