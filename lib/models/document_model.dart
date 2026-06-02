class DocumentModel {
  final int? id;
  final String type; // 'brd', 'berita_acara', 'invoice'
  final String title;
  final String? description;
  final String? leadProject;
  final String? assignTo;
  final String? startDate;
  final String? endDate;
  final String? filePath;
  final String status; // 'active','delay','done','payment'
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  DocumentModel({
    this.id,
    required this.type,
    required this.title,
    this.description,
    this.leadProject,
    this.assignTo,
    this.startDate,
    this.endDate,
    this.filePath,
    this.status = 'active',
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      description: map['description'],
      leadProject: map['lead_project'],
      assignTo: map['assign_to'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      filePath: map['file_path'],
      status: map['status'] ?? 'active',
      createdBy: map['created_by'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'lead_project': leadProject,
      'assign_to': assignTo,
      'start_date': startDate,
      'end_date': endDate,
      'file_path': filePath,
      'status': status,
      'created_by': createdBy,
    };
  }
}