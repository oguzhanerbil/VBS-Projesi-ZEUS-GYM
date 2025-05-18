import 'package:flutter/material.dart';
import 'package:gym/services/notification_service.dart';
import '../models/notification.dart';

class NotificationProvider with ChangeNotifier {
  List<GymNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<GymNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Üye bildirimlerini yükle
  Future<void> loadMemberNotifications(int memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = NotificationService();
      _notifications = await service.getMemberNotifications(memberId);
      _updateUnreadCount();
    } catch (e) {
      _error = "Bildirimler yüklenirken hata: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Bildirim okundu olarak işaretle
  Future<bool> markAsRead(int notificationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = NotificationService();
      final success = await service.markNotificationAsRead(notificationId);

      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedList = [..._notifications];
          updatedList[index] = _notifications[index].copyWith(isRead: true);
          _notifications = updatedList;
          _updateUnreadCount();
        }
        return true;
      } else {
        _error = "Bildirim güncellenemedi";
        return false;
      }
    } catch (e) {
      _error = "Bildirim güncellenirken hata: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Okunmamış bildirim sayısını güncelle
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // Provider'ı temizle
  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _error = null;
    notifyListeners();
  }
}
