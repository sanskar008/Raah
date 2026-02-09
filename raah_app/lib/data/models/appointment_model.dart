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
    // Handle MongoDB _id format
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    
    // Handle populated propertyId (can be object or string)
    final propertyIdObj = json['propertyId'] ?? json['property_id'];
    final propertyId = propertyIdObj is Map
        ? (propertyIdObj['_id']?.toString() ?? propertyIdObj['id']?.toString() ?? '')
        : propertyIdObj?.toString() ?? '';
    
    final propertyTitle = propertyIdObj is Map
        ? (propertyIdObj['title'] ?? '')
        : json['propertyTitle'] ?? json['property_title'] ?? '';
    
    final propertyImages = propertyIdObj is Map
        ? (propertyIdObj['images'] as List<dynamic>? ?? [])
        : [];
    final propertyImage = propertyImages.isNotEmpty 
        ? propertyImages[0].toString()
        : json['propertyImage'] ?? json['property_image'] ?? '';
    
    // Handle populated customerId (for received appointments)
    final customerIdObj = json['customerId'] ?? json['customer_id'];
    final customerId = customerIdObj is Map
        ? (customerIdObj['_id']?.toString() ?? customerIdObj['id']?.toString() ?? '')
        : customerIdObj?.toString() ?? '';
    
    final customerName = customerIdObj is Map
        ? (customerIdObj['name'] ?? '')
        : json['customerName'] ?? json['customer_name'] ?? '';
    
    final customerPhone = customerIdObj is Map
        ? (customerIdObj['phone'] ?? '')
        : json['customerPhone'] ?? json['customer_phone'] ?? '';
    
    // Handle populated ownerId
    final ownerIdObj = json['ownerId'] ?? json['owner_id'];
    final ownerId = ownerIdObj is Map
        ? (ownerIdObj['_id']?.toString() ?? ownerIdObj['id']?.toString() ?? '')
        : ownerIdObj?.toString() ?? '';
    
    final ownerName = ownerIdObj is Map
        ? (ownerIdObj['name'] ?? '')
        : json['ownerName'] ?? json['owner_name'] ?? '';
    
    // Handle date field (backend uses 'date' not 'scheduledDate')
    final dateStr = json['date'] ?? json['scheduledDate'] ?? json['scheduled_date'];
    final scheduledDate = dateStr != null 
        ? (dateStr is DateTime ? dateStr : DateTime.parse(dateStr))
        : DateTime.now();
    
    return AppointmentModel(
      id: id,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      propertyImage: propertyImage,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      ownerId: ownerId,
      ownerName: ownerName,
      scheduledDate: scheduledDate,
      scheduledTime: json['time'] ?? json['scheduledTime'] ?? json['scheduled_time'] ?? '',
      status: AppointmentStatus.fromString(json['status'] ?? 'pending'),
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
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
