import 'package:mysql_utils/mysql_utils.dart';
import '../config/db_connection.dart';
import '../models/notification.dart';

class NotificationService {
  Future<List<GymNotification>> getMemberNotifications(int memberId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.getAll(
        table: 'bildirim',
        where: {'uye_id': memberId},
        order: 'gonderim_tarihi DESC',
      );

      return results.map((row) => GymNotification.fromMap(row)).toList();
    } catch (e) {
      print('Bildirimleri getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> addNotification(int memberId, String content) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final result = await conn.insert(
        table: 'bildirim',
        insertData: {
          'uye_id': memberId,
          'icerik': content,
          'okundu': 0,
          'gonderim_tarihi': DateTime.now().toString(),
        },
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Bildirim ekleme hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> markNotificationAsRead(int notificationId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final result = await conn.update(
        table: 'bildirim',
        updateData: {'okundu': 1},
        where: {'bildirim_id': notificationId},
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Bildirim güncelleme hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> sendBulkNotifications(
    List<int> memberIds,
    String content,
  ) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      await conn.startTrans();
      bool allSuccess = true;

      for (int memberId in memberIds) {
        final result = await conn.insert(
          table: 'bildirim',
          insertData: {
            'uye_id': memberId,
            'icerik': content,
            'okundu': 0,
            'gonderim_tarihi': DateTime.now().toString(),
          },
        );

        if (result <= BigInt.from(0)) {
          allSuccess = false;
          break;
        }
      }

      if (allSuccess) {
        await conn.commit();
        return true;
      } else {
        await conn.rollback();
        return false;
      }
    } catch (e) {
      print('Toplu bildirim gönderme hatası: $e');
      await conn?.rollback();
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
