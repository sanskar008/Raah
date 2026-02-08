import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../domain/enums/property_type.dart';

/// Add property form — multi-step feel with image upload placeholders.
/// Used by both Broker and Owner flows.
class AddPropertyScreen extends StatefulWidget {
  final bool showCoinsInfo; // Show coin info for brokers

  const AddPropertyScreen({super.key, this.showCoinsInfo = true});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaSqFtController = TextEditingController();

  PropertyType _selectedType = PropertyType.room;
  final List<String> _selectedAmenities = [];
  bool _isSubmitting = false;

  final List<String> _allAmenities = [
    'WiFi', 'AC', 'Parking', 'Gym', 'Swimming Pool', 'Kitchen',
    'Washing Machine', 'Security', 'Power Backup', 'Lift', 'Balcony',
    'Garden', 'Meals', 'Housekeeping', 'Geyser', 'Fan', 'Cupboard',
    'Water Supply', 'Club House', 'Children Play Area', 'Laundry',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaSqFtController.dispose();
    super.dispose();
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.showCoinsInfo
                    ? 'Property added! +50 coins earned'
                    : 'Property added successfully!',
              ),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Property'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Coins Info (Broker only) ──
              if (widget.showCoinsInfo)
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  margin: const EdgeInsets.only(
                      bottom: AppConstants.spacingLg),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: AppColors.accent,
                        size: 24,
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Earn 50 Coins',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                            Text(
                              'You\'ll earn coins for each property listing',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Image Upload ──
              Text('Property Images', style: AppTextStyles.h4),
              const SizedBox(height: AppConstants.spacingMd),
              _buildImageUploader(),

              const SizedBox(height: AppConstants.spacingLg),

              // ── Property Type ──
              Text('Property Type', style: AppTextStyles.h4),
              const SizedBox(height: AppConstants.spacingMd),
              _buildPropertyTypeSelector(),

              const SizedBox(height: AppConstants.spacingLg),

              // ── Title ──
              CustomTextField(
                label: 'Property Title',
                hint: 'e.g., Cozy 2BHK in Koramangala',
                controller: _titleController,
                validator: (v) => Validators.required(v, 'Title'),
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: AppConstants.spacingMd),

              // ── Description ──
              CustomTextField(
                label: 'Description',
                hint: 'Describe the property features, location highlights...',
                controller: _descriptionController,
                validator: (v) => Validators.required(v, 'Description'),
                maxLines: 4,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: AppConstants.spacingMd),

              // ── Rent & Deposit ──
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Monthly Rent (₹)',
                      hint: '15000',
                      controller: _rentController,
                      validator: Validators.rent,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: CustomTextField(
                      label: 'Deposit (₹)',
                      hint: '30000',
                      controller: _depositController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingMd),

              // ── Address ──
              CustomTextField(
                label: 'Full Address',
                hint: '3rd Cross, 5th Block',
                controller: _addressController,
                validator: (v) => Validators.required(v, 'Address'),
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: AppConstants.spacingMd),

              // ── Area & City ──
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Area / Locality',
                      hint: 'Koramangala',
                      controller: _areaController,
                      validator: (v) => Validators.required(v, 'Area'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: CustomTextField(
                      label: 'City',
                      hint: 'Bangalore',
                      controller: _cityController,
                      validator: (v) => Validators.required(v, 'City'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingMd),

              // ── Room Details ──
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Bedrooms',
                      hint: '2',
                      controller: _bedroomsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: CustomTextField(
                      label: 'Bathrooms',
                      hint: '1',
                      controller: _bathroomsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: CustomTextField(
                      label: 'Area (sq.ft)',
                      hint: '800',
                      controller: _areaSqFtController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingLg),

              // ── Amenities ──
              Text('Amenities', style: AppTextStyles.h4),
              const SizedBox(height: AppConstants.spacingMd),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allAmenities.map((amenity) {
                  final isSelected = _selectedAmenities.contains(amenity);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedAmenities.remove(amenity);
                        } else {
                          _selectedAmenities.add(amenity);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceVariant,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusFull),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        amenity,
                        style: AppTextStyles.label.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppConstants.spacingXxl),

              // ── Submit ──
              CustomButton(
                text: 'Submit Property',
                onPressed: _submitProperty,
                isLoading: _isSubmitting,
                icon: Icons.upload_rounded,
              ),

              const SizedBox(height: AppConstants.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.divider,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 36,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to upload images',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              'Max 5 images • JPG, PNG',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTypeSelector() {
    return Row(
      children: PropertyType.values.map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != PropertyType.values.last
                  ? AppConstants.spacingSm
                  : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusSm),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                ),
                child: Text(
                  type.label,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
