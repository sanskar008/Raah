import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../domain/enums/appointment_status.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/owner_viewmodel.dart';

/// Owner appointments screen — view incoming visit requests,
/// accept/reject with status updates.
class OwnerAppointmentsScreen extends StatefulWidget {
  const OwnerAppointmentsScreen({super.key});

  @override
  State<OwnerAppointmentsScreen> createState() =>
      _OwnerAppointmentsScreenState();
}

class _OwnerAppointmentsScreenState extends State<OwnerAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      context.read<OwnerViewModel>().loadAppointments(user?.id ?? '1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ownerVM = context.watch<OwnerViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appointments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ownerVM.isAppointmentsLoading
          ? const LoadingWidget(message: 'Loading appointments...')
          : ownerVM.appointments.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.event_busy_rounded,
                  title: 'No appointments yet',
                  subtitle: 'Visit requests will appear here',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final user = context.read<AuthViewModel>().user;
                    await ownerVM.loadAppointments(user?.id ?? '1');
                  },
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(AppConstants.spacingLg),
                    itemCount: ownerVM.appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = ownerVM.appointments[index];
                      return _buildAppointmentCard(
                          context, appointment, ownerVM);
                    },
                  ),
                ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    dynamic appointment,
    OwnerViewModel ownerVM,
  ) {
    final statusColor = _getStatusColor(appointment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Property Info ──
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusSm),
                  child: appointment.propertyImage.isNotEmpty
                      ? Image.network(
                          appointment.propertyImage,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.image_outlined),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
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
                        appointment.propertyTitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.customerName,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    appointment.status.label,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Date & Time ──
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  appointment.scheduledDate.formatted,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  appointment.scheduledTime,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Phone
                const Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  appointment.customerPhone,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          // ── Action Buttons (only for pending) ──
          if (appointment.status == AppointmentStatus.pending) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ownerVM.updateAppointmentStatus(
                          appointment.id,
                          AppointmentStatus.rejected,
                        );
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ownerVM.updateAppointmentStatus(
                          appointment.id,
                          AppointmentStatus.accepted,
                        );
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.accepted:
        return AppColors.success;
      case AppointmentStatus.rejected:
        return AppColors.error;
      case AppointmentStatus.completed:
        return AppColors.primary;
      case AppointmentStatus.cancelled:
        return AppColors.textHint;
    }
  }
}
