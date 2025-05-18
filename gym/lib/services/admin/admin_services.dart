import 'package:gym/config/db_connection.dart';
import 'package:gym/models/user.dart';
import 'package:mysql_utils/mysql_utils.dart';

class AdminService {
  // Admin kayıt işlemi
  Future<bool> registerAdmin({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String adminKey, // Güvenlik için özel anahtar
  }) async {
    MysqlUtils? conn;

    try {
      // Admin anahtarını kontrol et (Bu değer normalde güvenli bir yerden alınmalı)
      const validAdminKey = 'admin123'; // Örnek anahtar
      if (adminKey != validAdminKey) {
        print('Geçersiz admin anahtarı');
        return false;
      }

      conn = await DatabaseConnection.getConnection();
      await conn.startTrans();

      // Email kontrolü yap
      final userCheck = await conn.getOne(
        table: 'kullanici',
        fields: 'kullanici_id',
        where: {'email': email},
      );

      print('User check: $userCheck');

      if (!userCheck.isEmpty) {
        print('Bu email adresi zaten kullanılıyor');
        await conn.rollback();
        return false;
      }

      // Admin kaydını oluştur
      final kullaniciResult = await conn.insert(
        table: 'kullanici',
        insertData: {
          'email': email,
          'sifre_hash': password, // Gerçek uygulamada şifre hash'lenir
          'ad': firstName,
          'soyad': lastName,
          'rol': 'Admin',
          'son_giris': DateTime.now().toIso8601String(),
        },
      );

      if (kullaniciResult <= BigInt.from(0)) {
        await conn.rollback();
        return false;
      }

      await conn.commit();
      return true;
    } catch (e) {
      print('Admin kayıt hatası: $e');
      await conn?.rollback();
      return false;
    } finally {
      await conn?.close();
    }
  }

  // Tüm adminleri getir
  Future<List<User>> getAllAdmins() async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.query('''
        SELECT 
          kullanici_id as id,
          email,
          ad,
          soyad,
          rol as role,
          son_giris as lastLogin
        FROM kullanici 
        WHERE rol = 'Admin'
        ORDER BY ad, soyad
      ''');

      print('Admin listesi: ${results.rows}');

      return results.rows
          .map((row) => User.fromMap(row.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      print('Admin listesi getirme hatası: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }
}
