class NotificationModel {
  final int? id;
  final int userId;
  final int? documentId;
  final String title;
  final String? message;
  final String? fromDepartment;
  final bool isRead;
  final String? createdAt;

  NotificationModel({
    this.id,
    required this.userId,
    this.documentId,
    required this.title,
    this.message,
    this.fromDepartment,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['user_id'],
      documentId: map['document_id'],
      title: map['title'],
      message: map['message'],
      fromDepartment: map['from_department'],
      isRead: map['is_read'] == 1,
      createdAt: map['created_at'],
    );
  }
}