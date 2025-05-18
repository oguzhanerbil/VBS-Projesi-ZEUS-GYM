import 'package:mysql_utils/mysql_utils.dart';
import '../../config/db_connection.dart';
import '../../models/member.dart';
import '../../models/membership_package.dart';

class MemberService {
  Future<Member?> getMemberByUserId(int userId) async {
    /*
    Kullanıcı ID'sine göre üye bilgilerini getiren fonksiyon
    */
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      // İki tabloyu birleştiren JOIN sorgusu
      final results = await conn.query('''
        SELECT 
          u.uye_id, 
          u.kullanici_id,
          k.email, 
          k.rol, 
          k.son_giris,
          k.ad,    
          k.soyad,
          p.paket_adi,
          p.fiyat
        FROM uye u
        INNER JOIN kullanici k ON u.kullanici_id = k.kullanici_id
        LEFT JOIN uyelikpaketi p ON u.paket_id = p.paket_id
        WHERE u.kullanici_id = $userId
        LIMIT 1
      ''');

      print("JOIN sonuçları: ${results.rows}");

      if (results.rows.isEmpty) {
        print("Kullanıcı var ama üye kaydı yok!");
        return null;
      }

      return Member.fromMap(results.rows.first);
    } catch (e) {
      print('Üye getirme hatası: $e');
      print('Hata detayı: ${e.toString()}');
      return null;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<List<Member>> getMembers() async {
    /*
    Sistemdeki tüm üyelerin bilgilerini getiren fonksiyon
     */
    MysqlUtils? conn;
    try {
      print('Veritabanına bağlanılıyor...');
      conn = await DatabaseConnection.getConnection();

      final results = await conn.query('''
        SELECT 
          u.kullanici_id,
          u.email,
          u.ad as firstName,
          u.soyad as lastName,
          u.rol as role,
          u.son_giris as lastLogin,
          uy.uyelik_durumu,
          uy.uyelik_baslangic,
          p.paket_adi,
          p.fiyat
        FROM kullanici u
        LEFT JOIN uye uy ON u.kullanici_id = uy.kullanici_id
        LEFT JOIN uyelikpaketi p ON uy.paket_id = p.paket_id
        WHERE u.rol = 'Uye'
        ORDER BY u.ad, u.soyad
      ''');

      print('Sorgu sonucu: ${results.rows}');

      return results.rows.map((row) => Member.fromMap(row)).toList();
    } catch (e) {
      print('Üye listesi getirme hatası: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }

  Future<List<Member>> getActiveMembers() async {
    /*
    View sanal tablosu kullanarak aktif üyeleri getiren fonksiyon
    */
    MysqlUtils? conn;
    try {
      conn = await DatabaseConnection.getConnection();

      // vw_aktif_uyeler view'ını kullan
      final results = await conn.query('''
        SELECT * FROM vw_aktif_uyeler
        ORDER BY ad, soyad
      ''');

      if (results.rows.isEmpty) {
        print('Aktif üye bulunamadı');
        return [];
      }

      print('Bulunan aktif üye sayısı: ${results.rows.length}');
      return results.rows.map((row) => Member.fromMap(row.fields)).toList();
    } catch (e) {
      print('Aktif üyeleri getirme hatası: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }

  Future<bool> updateMember(int userId, String fullName) async {
    /*
    Üye bilgilerini güncelleyen fonksiyon
     */
    MysqlUtils? conn;

    // Ad ve soyadı ayırır
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts.first;
    String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    try {
      conn = await DatabaseConnection.getConnection();

      // Öncelikle kullanici tablosunu güncelle
      final kullaniciResult = await conn.update(
        table: 'kullanici',
        updateData: {'ad': firstName, 'soyad': lastName},
        where: {'kullanici_id': userId},
      );

      if (kullaniciResult <= BigInt.from(0)) {
        return false;
      }

      // Sonra uye tablosunu günceller
      final uyeResult = await conn.update(
        table: 'uye',
        updateData: {'ad': firstName, 'soyad': lastName},
        where: {'kullanici_id': userId},
      );

      return uyeResult > BigInt.from(0);
    } catch (e) {
      print('Üye güncelleme hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Üyenin aktif üyelik paketini getir
  Future<MembershipPackage?> getActiveMembership(int memberId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.getOne(
        table: 'uyelikpaketi up, paket_turu pt',
        fields: 'up.*, pt.ad as paket_adi, pt.aciklama',
        where: {
          'up.paket_turu_id': 'pt.id',
          'up.uye_id': memberId,
          'up.bitis_tarihi >= CURRENT_DATE()': null,
        },
        order: 'up.bitis_tarihi DESC',
      );

      if (results != null) {
        return MembershipPackage.fromMap(results.cast<String, dynamic>());
      }
      return null;
    } catch (e) {
      print('Aktif üyelik paketi getirme hatası: $e');
      return null;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Üyenin tüm üyelik paketlerini getir
  Future<List<MembershipPackage>> getMembershipHistory(int memberId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.getAll(
        table: 'uyelikpaketi up, paket_turu pt',
        fields: 'up.*, pt.ad as paket_adi, pt.aciklama',
        where: {'up.paket_turu_id': 'pt.id', 'up.uye_id': memberId},
        order: 'up.bitis_tarihi DESC',
      );

      return results.map((row) => MembershipPackage.fromMap(row)).toList();
    } catch (e) {
      print('Üyelik geçmişi getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Üyelik paketlerini getiren metod
  Future<List<MembershipPackage>> getMembershipPackages() async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.query('''
      SELECT 
        paket_id,
        paket_adi,
        aciklama,
        fiyat,
        sure_gun,
        aktif
      FROM uyelikpaketi
      WHERE aktif = 1
      ORDER BY fiyat ASC
    ''');

      print('Üyelik paketleri sorgu sonucu: ${results.rows}');

      return results.rows.map((row) => MembershipPackage.fromMap(row)).toList();
    } catch (e) {
      print('Üyelik paketleri getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> deleteMember(int memberId) async {
    MysqlUtils? conn;
    try {
      conn = await DatabaseConnection.getConnection();

      // Önce üyelik kayıtlarını sil
      await conn.delete(
        table: 'uyelik_kayit',
        where: {'kullanici_id': memberId},
      );

      // Sonra kullanıcıyı sil
      final result = await conn.delete(
        table: 'kullanici',
        where: {'kullanici_id': memberId, 'rol': 'Uye'},
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Üye silme hatası: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  // Üyelik satın alma metodu
  Future<bool> purchaseMembership(int memberId, int packageId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      await conn.startTrans();

      final packageResult = await conn.getOne(
        table: 'uyelikpaketi',
        fields: '*',
        where: {'paket_id': packageId},
      );

      if (packageResult == null) {
        await conn.rollback();
        return false;
      }

      final int packageDays = packageResult['sure_gun'];
      final double packagePrice = packageResult['fiyat'].toDouble();

      final memberResult = await conn.getOne(
        table: 'uye',
        fields: '*',
        where: {'uye_id': memberId},
      );

      if (memberResult == null) {
        await conn.rollback();
        return false;
      }

      final now = DateTime.now();

      DateTime newEndDate;

      if (memberResult['uyelik_bitis'] != null &&
          DateTime.parse(memberResult['uyelik_bitis']).isAfter(now)) {
        newEndDate = DateTime.parse(
          memberResult['uyelik_bitis'],
        ).add(Duration(days: packageDays));
      } else {
        newEndDate = now.add(Duration(days: packageDays));
      }

      // Üyelik bilgilerini güncelle
      final updateResult = await conn.update(
        table: 'uye',
        updateData: {
          'uyelik_baslangic': now.toIso8601String(),
          'uyelik_bitis': newEndDate.toIso8601String(),
          'uyelik_durumu': 'Aktif',
        },
        where: {'uye_id': memberId},
      );

      if (updateResult <= BigInt.from(0)) {
        await conn.rollback();
        return false;
      }

      // Ödeme kaydı oluştur
      final paymentResult = await conn.insert(
        table: 'odeme',
        insertData: {
          'uye_id': memberId,
          'odeme_turu_id': 1, // Nakit veya banka kartı olarak ayarlanabilir
          'odeme_tarihi': now.toIso8601String(),
          'tutar': packagePrice,
          'aciklama': 'Üyelik paketi: ${packageResult['paket_adi']}',
        },
      );

      if (paymentResult <= BigInt.from(0)) {
        await conn.rollback();
        return false;
      }

      await conn.commit();
      return true;
    } catch (e) {
      print('Üyelik satın alma hatası: $e');
      await conn?.rollback();
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> addMembership(
    int memberId,
    int packageTypeId,
    DateTime startDate,
    DateTime endDate,
    double amount,
  ) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final result = await conn.insert(
        table: 'uyelikpaketi',
        insertData: {
          'uye_id': memberId,
          'paket_turu_id': packageTypeId,
          'baslangic_tarihi': startDate.toString(),
          'bitis_tarihi': endDate.toString(),
          'odeme_tutari': amount,
        },
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Üyelik paketi ekleme hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
