import 'package:mysql_utils/mysql_utils.dart';
import '../../config/db_connection.dart';
import '../../models/user.dart';

class UserService {
  Future<User?> getUserById(int userId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.getOne(
        table: 'kullanici',
        fields: '*',
        where: {'id': userId},
      );

      if (results != null) {
        return User.fromMap(results.cast<String, dynamic>());
      }
      return null;
    } catch (e) {
      print('Kullanıcı getirme hatası: $e');
      return null;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> updateUserProfile(
    int userId,
    String fullName,
    String email,
  ) async {
    MysqlUtils? conn;

    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts.first;
    String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    try {
      conn = await DatabaseConnection.getConnection();

      // Kullanici tablosunu güncelle
      final kullaniciResult = await conn.update(
        table: 'kullanici',
        updateData: {'ad': firstName, 'soyad': lastName, 'email': email},
        where: {'kullanici_id': userId},
      );

      if (kullaniciResult <= BigInt.from(0)) {
        return false;
      }

      final userRole = await conn.getOne(
        table: 'kullanici',
        fields: 'rol',
        where: {'kullanici_id': userId},
      );

      if (userRole != null && userRole['rol'] == 'Uye') {
        await conn.update(
          table: 'uye',
          updateData: {'ad': firstName, 'soyad': lastName},
          where: {'kullanici_id': userId},
        );
      }

      return true;
    } catch (e) {
      print('Kullanıcı güncelleme hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> updatePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final checkResults = await conn.getOne(
        table: 'kullanici',
        fields: '*',
        where: {'id': userId, 'sifre': oldPassword},
      );

      if (checkResults == null) {
        return false;
      }

      final result = await conn.update(
        table: 'kullanici',
        updateData: {'sifre': newPassword},
        where: {'id': userId},
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Şifre güncelleme hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Kullanıcı rolüne göre tüm kullanıcıları getir (admin için)
  Future<List<User>> getUsersByRole(String role) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.getAll(
        table: 'kullanici',
        fields: '*',
        where: {'rol': role},
      );

      return results.map((row) => User.fromMap(row)).toList();
    } catch (e) {
      print('Kullanıcıları getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Yeni kullanıcı oluştur (admin için)
  Future<bool> createUser(
    String email,
    String password,
    String fullName,
    String role,
  ) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      // E-posta kullanımda mı kontrol et
      final checkResults = await conn.getOne(
        table: 'kullanici',
        fields: '*',
        where: {'email': email},
      );

      if (checkResults != null) {
        return false;
      }

      // Yeni kullanıcı oluştur
      final result = await conn.insert(
        table: 'kullanici',
        insertData: {
          'email': email,
          'sifre': password,
          'ad_soyad': fullName,
          'rol': role,
        },
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Kullanıcı oluşturma hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<List<User>> getAllTrainers() async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.query('''
        SELECT 
          kullanici_id,
          email,
          ad,
          soyad,
          rol as role,
          son_giris as lastLogin
        FROM kullanici 
        WHERE rol = 'Egitmen'
        ORDER BY ad, soyad
      ''');

      return results.rows
          .map((row) => User.fromMap(row.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      print('Eğitmenleri getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<User?> getTrainerById(int trainerId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final result = await conn.query('''
        SELECT 
          kullanici_id,
          email,
          ad as firstName,
          soyad as lastName,
          rol as role,
          son_giris as lastLogin
        FROM kullanici 
        WHERE kullanici_id = $trainerId AND rol = 'Egitmen'
      ''');

      if (result.rows.isEmpty) {
        return null;
      }

      return User.fromMap(result.rows.first.cast<String, dynamic>());
    } catch (e) {
      print('Eğitmen getirme hatası: $e');
      return null;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> deleteTrainer(int trainerId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();
      print("Eğitmen silme işlemi başlatıldı. ID: $trainerId");

      // Transaction başlat
      await conn.startTrans();

      // Önce eğitmenin mevcut olup olmadığını kontrol et
      final trainer = await conn.getOne(
        table: 'kullanici',
        where: {'kullanici_id': trainerId, 'rol': 'Egitmen'},
      );

      if (trainer == null) {
        print('Silinecek eğitmen bulunamadı');
        await conn.rollback();
        return false;
      }

      print("Eğitmen bulundu: ${trainer.toString()}");

      // 1. Önce eğitmenin verdiği dersleri kontrol et
      final classCheck = await conn.query('''
      SELECT COUNT(*) as count 
      FROM ders 
      WHERE kullanici_id = $trainerId AND aktiflik = 'Aktif'
    ''');

      final activeClassCount = int.parse(
        classCheck.rows.first['count'].toString(),
      );
      print("Aktif ders sayısı: $activeClassCount");

      if (activeClassCount > 0) {
        print("Eğitmenin aktif dersleri var, silme işlemi iptal edildi");
        await conn.rollback();
        throw Exception(
          'Bu eğitmenin aktif dersleri bulunmaktadır. Önce dersleri silinmelidir.',
        );
      }

      // 2. Ders tablosundaki kayıtları pasife çek
      final updateResult = await conn.update(
        table: 'ders',
        updateData: {'aktiflik': 'Pasif'},
        where: {'kullanici_id': trainerId},
      );
      print("Dersleri pasife çekme sonucu: $updateResult");

      // 3. Son olarak eğitmeni sil
      final deleteResult = await conn.delete(
        table: 'kullanici',
        where: {'kullanici_id': trainerId}, // rol şartını kaldırdık
      );
      print("Silme işlemi sonucu: $deleteResult");

      if (deleteResult <= BigInt.from(0)) {
        print("Eğitmen silme başarısız oldu");
        await conn.rollback();
        return false;
      }

      print("Eğitmen başarıyla silindi");
      await conn.commit();
      return true;
    } catch (e) {
      print('DB Error: $e');
      await conn?.rollback();
      rethrow;
    } finally {
      await conn?.close();
    }
  }
}
