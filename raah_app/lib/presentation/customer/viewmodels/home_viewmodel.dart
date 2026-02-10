import 'package:flutter/material.dart';
import '../../../core/utils/error_messages.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../domain/enums/property_type.dart';

/// Home feed ViewModel — handles property list, search, and filters.
class HomeViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;

  HomeViewModel({required PropertyRepository propertyRepository})
      : _propertyRepository = propertyRepository;

  // ── State ──
  List<PropertyModel> _properties = [];
  bool _isLoading = false;
  String? _error;

  // ── Filters ──
  String _searchArea = '';
  double? _minRent;
  double? _maxRent;
  PropertyType? _selectedType;

  // ── Getters ──
  List<PropertyModel> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchArea => _searchArea;
  double? get minRent => _minRent;
  double? get maxRent => _maxRent;
  PropertyType? get selectedType => _selectedType;
  bool get hasFilters =>
      _searchArea.isNotEmpty ||
      _minRent != null ||
      _maxRent != null ||
      _selectedType != null;

  // ── Load properties ──
  Future<void> loadProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _properties = await _propertyRepository.getProperties(
        area: _searchArea.isNotEmpty ? _searchArea : null,
        minRent: _minRent,
        maxRent: _maxRent,
        propertyType: _selectedType,
      );
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Update filters ──
  void setSearchArea(String area) {
    _searchArea = area;
    loadProperties();
  }

  void setRentRange(double? min, double? max) {
    _minRent = min;
    _maxRent = max;
    loadProperties();
  }

  void setPropertyType(PropertyType? type) {
    _selectedType = type;
    loadProperties();
  }

  void clearFilters() {
    _searchArea = '';
    _minRent = null;
    _maxRent = null;
    _selectedType = null;
    loadProperties();
  }
}
