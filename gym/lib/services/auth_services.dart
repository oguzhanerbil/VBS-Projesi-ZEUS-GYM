import 'package:mysql_utils/mysql_utils.dart';
import '../config/db_connection.dart';
import '../models/user.dart';

class AuthService {
  // Login fonksiyonundaki UPDATE sorgusu
  Future<User?> login(String email, String password) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.getOne(
        table: 'kullanici',
        fields: '*',
        where: {'email': email.trim(), 'sifre_hash': password.trim()},
      );

      if (results.isNotEmpty) {
        await conn.query(
          'UPDATE kullanici SET son_giris = NOW() WHERE kullanici_id = :kullanici_id',
          values: {'kullanici_id': results['kullanici_id']},
        );

        return User.fromMap(results.cast<String, dynamic>());
      }

      return null;
    } catch (e) {
      print('Login hatası: $e');
      return null;
    } finally {
      await conn?.close();
    }
  }

  // Login işlemini izlemek için trigger oluşturma
  Future<void> createLoginTrigger() async {
    MysqlUtils? conn;
    try {
      conn = await DatabaseConnection.getConnection();

      // TRIGGER'ı oluştur
      // Eğer trigger zaten varsa, tekrar oluşturma
      await conn.query('''
      CREATE TRIGGER IF NOT EXISTS login_log
      AFTER UPDATE ON kullanici
      FOR EACH ROW
      BEGIN
        IF NEW.son_giris != OLD.son_giris THEN
          INSERT INTO login_log (kullanici_id, giris_zamani, rol)
          VALUES (NEW.kullanici_id, NEW.son_giris, NEW.rol);
        END IF;
      END
    ''');
    } catch (e) {
      print('Trigger oluşturma hatası: $e');
    } finally {
      await conn?.close();
    }
  }

  // register fonksiyonu
  Future<bool> register(String fullName, String email, String password) async {
    MysqlUtils? conn;

    // Ad ve soyadı ayır
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts.first;
    String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    try {
      conn = await DatabaseConnection.getConnection();

      await conn.startTrans();

      final kullaniciResult = await conn.insert(
        table: 'kullanici',
        insertData: {
          'email': email,
          'sifre_hash': password,
          'ad': firstName,
          'soyad': lastName,
          'rol': 'Uye',
          'son_giris': DateTime.now().toIso8601String(),
        },
      );

      if (kullaniciResult <= BigInt.from(0)) {
        await conn.rollback();
        return false;
      }

      // Sonra uye tablosuna ekle - ad ve soyadı tekrar gönderme
      final uyeResult = await conn.insert(
        table: 'uye',
        insertData: {
          'kullanici_id': kullaniciResult,
          'dogum_tarihi': null,
          'adres': null,
          'uyelik_baslangic': DateTime.now().toIso8601String(),
          'uyelik_bitis': null,
          'uyelik_durumu': 'Aktif',
        },
      );

      if (uyeResult <= BigInt.from(0)) {
        await conn.rollback();
        return false;
      }

      await conn.commit();
      return true;
    } catch (e) {
      print('Kayıt hatası: $e');
      await conn?.rollback();
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> registerTrainer(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();
      await conn.startTrans();

      final kullaniciResult = await conn.insert(
        table: 'kullanici',
        insertData: {
          'email': email,
          'sifre_hash': password,
          'ad': firstName,
          'soyad': lastName,
          'rol': 'Egitmen',
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
      print('Eğitmen kayıt hatası: $e');
      await conn?.rollback();
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

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
}
