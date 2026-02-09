import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../data/repositories/property_repository.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/property_detail_viewmodel.dart';

/// Appointment booking screen — select date, time, confirm visit.
/// Clean calendar-style date picker + time slots.
class AppointmentBookingScreen extends StatefulWidget {
  final PropertyModel property;

  const AppointmentBookingScreen({super.key, required this.property});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  bool _isBooking = false;
  bool _bookingSuccess = false;

  final List<String> _timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _bookVisit() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    // Create repositories with ApiService
    final secureStorage = SecureStorageService();
    final apiService = ApiService(storage: secureStorage);
    final detailVM = PropertyDetailViewModel(
      propertyRepository: PropertyRepository(apiService: apiService),
      appointmentRepository: AppointmentRepository(apiService: apiService),
    );
    detailVM.setProperty(widget.property);

    final success = await detailVM.bookAppointment(
      date: _selectedDate,
      time: _selectedTime!,
    );

    setState(() {
      _isBooking = false;
      _bookingSuccess = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bookingSuccess) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book a Visit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Property Summary ──
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSm),
                    child: widget.property.imageUrls.isNotEmpty
                        ? Image.network(
                            widget.property.imageUrls[0],
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 72,
                              height: 72,
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.image_outlined),
                            ),
                          )
                        : Container(
                            width: 72,
                            height: 72,
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.image_outlined),
                          ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.property.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.property.rent.toRent,
                          style: AppTextStyles.priceSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingXl),

            // ── Select Date ──
            Text('Select Date', style: AppTextStyles.h4),
            const SizedBox(height: AppConstants.spacingMd),

            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDate.formatted,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _selectedDate.shortFormatted,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingXl),

            // ── Select Time ──
            Text('Select Time', style: AppTextStyles.h4),
            const SizedBox(height: AppConstants.spacingMd),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final time = _timeSlots[index];
                final isSelected = _selectedTime == time;

                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      time,
                      style: AppTextStyles.label.copyWith(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppConstants.spacingXxl),

            // ── Confirm Button ──
            CustomButton(
              text: 'Confirm Booking',
              onPressed: _bookVisit,
              isLoading: _isBooking,
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
        ),
      ),
    );
  }

  /// Success confirmation screen after booking.
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success animation placeholder
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 56,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingLg),

                Text('Visit Booked!', style: AppTextStyles.h2),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Your visit has been scheduled for\n${_selectedDate.formatted} at $_selectedTime',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'The property owner will confirm your appointment shortly.',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingXxl),

                CustomButton(
                  text: 'Back to Home',
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),

                const SizedBox(height: AppConstants.spacingMd),

                CustomButton(
                  text: 'View Property',
                  isOutlined: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
