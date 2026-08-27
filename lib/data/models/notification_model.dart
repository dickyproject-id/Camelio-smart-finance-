import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String userId;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final String type; // 'transaction', 'system', 'sync'

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
    required this.type,
  });

  factory NotificationModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return NotificationModel(
      id: documentId,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'date': date,
      'isRead': isRead,
      'type': type,
    };
  }
}
