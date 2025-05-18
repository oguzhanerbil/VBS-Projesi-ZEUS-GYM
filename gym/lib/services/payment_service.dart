import 'package:mysql_utils/mysql_utils.dart';
import '../config/db_connection.dart';
import '../models/payment.dart';

class PaymentService {
  Future<List<Payment>> getMemberPayments(int memberId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.getAll(
        table: 'odeme o, odeme_turu pt',
        fields: 'o.*, pt.ad as odeme_turu',
        where: {'o.odeme_turu_id': 'pt.id', 'o.uye_id': memberId},
        order: 'o.odeme_tarihi DESC',
      );

      return results.map((row) => Payment.fromMap(row)).toList();
    } catch (e) {
      print('Ödeme geçmişi getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Yeni ödeme kaydı ekle
  Future<bool> addPayment(
    int memberId,
    int paymentTypeId,
    double amount,
    String description,
    DateTime paymentDate,
  ) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final result = await conn.insert(
        table: 'odeme',
        insertData: {
          'uye_id': memberId,
          'odeme_turu_id': paymentTypeId,
          'tutar': amount,
          'aciklama': description,
          'odeme_tarihi': paymentDate.toString(),
        },
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Ödeme ekleme hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> addPaymentWithMembership(
    int memberId,
    int packageTypeId,
    int paymentTypeId,
    double amount,
    DateTime startDate,
    DateTime endDate,
    String description,
  ) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      await conn.startTrans();

      // Ödeme ekle
      final paymentResult = await conn.insert(
        table: 'odeme',
        insertData: {
          'uye_id': memberId,
          'odeme_turu_id': paymentTypeId,
          'tutar': amount,
          'aciklama': description,
          'odeme_tarihi': DateTime.now().toString(),
        },
      );

      // Üyelik paketi ekle
      final membershipResult = await conn.insert(
        table: 'uyelikpaketi',
        insertData: {
          'uye_id': memberId,
          'paket_turu_id': packageTypeId,
          'baslangic_tarihi': startDate.toString(),
          'bitis_tarihi': endDate.toString(),
          'odeme_tutari': amount,
        },
      );

      await conn.commit();
      return paymentResult > BigInt.from(0) &&
          membershipResult > BigInt.from(0);
    } catch (e) {
      print('Ödeme ve üyelik paketi ekleme hatası: $e');
      await conn?.rollback();
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<List<Payment>> getPaymentsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.query('''
        SELECT 
          o.*,
          pt.ad as odeme_turu,
          CONCAT(k.ad, ' ', k.soyad) as member_name
        FROM odeme o
        INNER JOIN odeme_turu pt ON o.odeme_turu_id = pt.id
        INNER JOIN uye u ON o.uye_id = u.id
        INNER JOIN kullanici k ON u.kullanici_id = k.id
        WHERE o.odeme_tarihi BETWEEN '${start.toString()}' AND '${end.toString()}'
        ORDER BY o.odeme_tarihi DESC
      ''');

      return results.rows.map((row) => Payment.fromMap(row)).toList();
    } catch (e) {
      print('Tarih aralığına göre ödemeleri getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Ödeme türlerini getir
  Future<List> getPaymentTypes() async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.getAll(table: 'odeme_turu', fields: '*');

      return results;
    } catch (e) {
      print('Ödeme türlerini getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
