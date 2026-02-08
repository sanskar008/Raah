import '../../domain/enums/appointment_status.dart';

/// Appointment booking model — tracks visit requests.
class AppointmentModel {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyImage;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String ownerId;
  final String ownerName;
  final DateTime scheduledDate;
  final String scheduledTime;
  final AppointmentStatus status;
  final String? notes;
  final DateTime? createdAt;

  AppointmentModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyImage,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.ownerId,
    required this.ownerName,
    required this.scheduledDate,
    required this.scheduledTime,
    this.status = AppointmentStatus.pending,
    this.notes,
    this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      propertyId: json['property_id'] ?? '',
      propertyTitle: json['property_title'] ?? '',
      propertyImage: json['property_image'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      ownerId: json['owner_id'] ?? '',
      ownerName: json['owner_name'] ?? '',
      scheduledDate: DateTime.parse(
          json['scheduled_date'] ?? DateTime.now().toIso8601String()),
      scheduledTime: json['scheduled_time'] ?? '',
      status: AppointmentStatus.fromString(json['status'] ?? 'pending'),
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'property_title': propertyTitle,
      'property_image': propertyImage,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_time': scheduledTime,
      'status': status.value,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
