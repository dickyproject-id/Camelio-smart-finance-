import 'dart:async';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../data/models/notification_model.dart';
import '../data/services/firestore_service.dart';
import '../data/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = locator<FirestoreService>();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void loadNotifications(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestoreService
        .getNotificationsStream(userId)
        .listen(
          (data) {
            final newNotifications = data
                .map((map) => NotificationModel.fromMap(map, map['id']))
                .toList();

            // Trigger system notification for NEW unread notifications
            // (Hanya jika jumlah unread bertambah, untuk menghindari spam saat load awal)
            if (_notifications.isNotEmpty &&
                newNotifications.length > _notifications.length) {
              final latest =
                  newNotifications.first; // Stream biasanya descending by date
              if (!latest.isRead) {
                NotificationService.showNotification(
                  title: latest.title,
                  body: latest.message,
                );
              }
            }

            _notifications = newNotifications;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('NOTIFICATION_STREAM_ERROR: $error');
            _isLoading = false;
            notifyListeners();
          },
        );

    // Timeout safety
    Future.delayed(const Duration(seconds: 5), () {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> addNotification(NotificationModel notification) async {
    await _firestoreService.addNotification(notification.toMap());

    // Trigger system tray notification (Tray / Layar Atas)
    await NotificationService.showNotification(
      title: notification.title,
      body: notification.message,
    );
  }

  Future<void> sendTestNotification(
    String userId,
    String Function(String, String) translate,
  ) async {
    final testNotification = NotificationModel(
      userId: userId,
      title: translate(
        'Halo! Ini Tes Notifikasi ✨',
        'Hello! This is a Test Notification ✨',
      ),
      message: translate(
        'Notifikasi berhasil muncul di sistem dan aplikasi. Klik untuk membaca detailnya!',
        'Notification successfully appeared in the system and app. Click to read more!',
      ),
      date: DateTime.now(),
      type: 'system',
      isRead: false,
    );
    await addNotification(testNotification);
  }

  Future<void> markAsRead(String id) async {
    await _firestoreService.markNotificationAsRead(id);
  }

  Future<void> deleteNotification(String id) async {
    await _firestoreService.deleteNotification(id);
  }

  Future<void> deleteAllNotifications(String userId) async {
    await _firestoreService.deleteAllNotifications(userId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
