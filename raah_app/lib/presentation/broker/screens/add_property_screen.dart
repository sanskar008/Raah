import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../domain/enums/property_type.dart';
import '../../../domain/enums/user_role.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../broker/viewmodels/broker_viewmodel.dart';
import '../../owner/viewmodels/owner_viewmodel.dart';

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
  
  // Image handling
  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _isUploadingImages = false;

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

    // Check Cloudinary configuration
    if (!ImageUploadService.isConfigured()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '⚠️ Cloudinary not configured. Please add your credentials in image_upload_service.dart',
            ),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
      _isUploadingImages = _selectedImages.isNotEmpty;
    });

    try {
      // Upload images first
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Uploading images...'),
                ],
              ),
            ),
          );
        }

        imageUrls = await ImageUploadService.uploadImages(_selectedImages);
        
        if (imageUrls.isEmpty) {
          throw Exception('Failed to upload images. Please try again.');
        }
      }

      setState(() => _isUploadingImages = false);

      final authVM = context.read<AuthViewModel>();
      final user = authVM.user;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final rent = double.parse(_rentController.text);
      final deposit = double.parse(_depositController.text);
      final amenities = _selectedAmenities.isEmpty ? null : _selectedAmenities;

      bool success;
      if (user.role == UserRole.broker) {
        final brokerVM = context.read<BrokerViewModel>();
        success = await brokerVM.addProperty(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          rent: rent,
          deposit: deposit,
          area: _areaController.text.trim(),
          city: _cityController.text.trim(),
          ownerId: user.id, // For brokers, they can set ownerId or use their own
          amenities: amenities,
          brokerId: user.id,
          images: imageUrls.isNotEmpty ? imageUrls : null,
        );
      } else if (user.role == UserRole.owner) {
        final ownerVM = context.read<OwnerViewModel>();
        success = await ownerVM.addProperty(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          rent: rent,
          deposit: deposit,
          area: _areaController.text.trim(),
          city: _cityController.text.trim(),
          ownerId: user.id,
          amenities: amenities,
          images: imageUrls.isNotEmpty ? imageUrls : null,
        );
      } else {
        throw Exception('Only brokers and owners can add properties');
      }

      setState(() => _isSubmitting = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.showCoinsInfo
                        ? 'Property added! +10 coins earned'
                        : 'Property added successfully!',
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    user.role == UserRole.broker
                        ? context.read<BrokerViewModel>().error ?? 'Failed to add property'
                        : context.read<OwnerViewModel>().error ?? 'Failed to add property',
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
                text: _isUploadingImages ? 'Uploading Images...' : 'Submit Property',
                onPressed: (_isSubmitting || _isUploadingImages) ? null : _submitProperty,
                isLoading: _isSubmitting || _isUploadingImages,
                icon: Icons.upload_rounded,
              ),

              const SizedBox(height: AppConstants.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
      
      if (pickedFiles.isEmpty) return;

      // Limit to 5 images total
      final remainingSlots = 5 - _selectedImages.length;
      if (remainingSlots <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 5 images allowed'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final filesToAdd = pickedFiles.take(remainingSlots).toList();
      
      setState(() {
        for (var file in filesToAdd) {
          _selectedImages.add(File(file.path));
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected images grid
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _selectedImages.length - 1
                        ? AppConstants.spacingSm
                        : 0,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image);
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        
        // Upload button
        if (_selectedImages.length < 5)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
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
                      Icons.add_photo_alternate_outlined,
                      size: 36,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedImages.isEmpty
                          ? 'Tap to add images'
                          : 'Add more images',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${_selectedImages.length}/5 images',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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
