class PlumberJobModel {
  final String id;
  final String? plumberId;
  final String title;
  final String? description;
  final String? location;
  final String status;
  final String priority;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? plumberNotes;
  final String? adminNotes;
  final String? zohoJobId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlumberJobModel({
    required this.id,
    this.plumberId,
    required this.title,
    this.description,
    this.location,
    required this.status,
    this.priority = 'normal',
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.scheduledDate,
    this.completedDate,
    this.plumberNotes,
    this.adminNotes,
    this.zohoJobId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlumberJobModel.fromJson(Map<String, dynamic> json) {
    return PlumberJobModel(
      id: json['id'] as String,
      plumberId: json['plumber_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String? ?? 'normal',
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerAddress: json['customer_address'] as String?,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'] as String)
          : null,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      plumberNotes: json['plumber_notes'] as String?,
      adminNotes: json['admin_notes'] as String?,
      zohoJobId: json['zoho_job_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plumber_id': plumberId,
      'title': title,
      'description': description,
      'location': location,
      'status': status,
      'priority': priority,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'plumber_notes': plumberNotes,
      'admin_notes': adminNotes,
      'zoho_job_id': zohoJobId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
