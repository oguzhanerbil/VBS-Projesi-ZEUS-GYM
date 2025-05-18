import 'package:mysql_utils/mysql_utils.dart';
import '../config/db_connection.dart';
import '../models/class.dart';
import '../models/attendance.dart';

class ClassService {
  Future<List<Class>> getAllClasses() async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.query('''
        SELECT 
          d.ders_id as id,
          d.ders_adi as name,
          d.gun as gun,
          d.saat as saat,
          d.baslangic_saati as startTime,
          d.bitis_saati as endTime,
          DATE_ADD(d.saat, INTERVAL d.sure_dakika MINUTE) as endTime,
          d.max_kapasite as capacity,
          d.lokasyon as location,
          k.kullanici_id as trainerId,
          CONCAT(k.ad, ' ', k.soyad) as trainerName
        FROM ders d
        INNER JOIN kullanici k ON d.kullanici_id = k.kullanici_id
        WHERE k.rol = 'Egitmen'
        ORDER BY d.gun, d.saat
      ''');

      print("Sorgu çalıştırıldı");
      print("Sonuç sayısı: ${results.rows.length}");

      return results.rows.map((row) => Class.fromMap(row)).toList();
    } catch (e) {
      print('Dersleri getirme hatası: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }

  Future<List<Class>> getClassesForMember(int memberId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.query('''
        SELECT 
          d.ders_id as id, 
          d.ders_adi as name,  
          d.gun as dayOfWeek, 
          d.saat,
          d.baslangic_saati as startTime,
          d.bitis_saati as endTime,
          d.sure_dakika as durationMinutes,
          d.max_kapasite as capacity,
          d.lokasyon as location,
          d.kullanici_id as trainerId,
          CONCAT(k.ad, ' ', k.soyad) as trainerName
        FROM ders d
        INNER JOIN kullanici k ON d.kullanici_id = k.kullanici_id
        WHERE d.aktiflik = 'Aktif'
        ORDER BY d.gun, d.saat
      ''');

      print('Sorgu çalıştırıldı');
      print('Sonuç sayısı: ${results.rows.length}');

      return results.rows.map((row) => Class.fromMap(row)).toList();
    } catch (e) {
      print('Üye dersleri getirme hatası: $e');
      print('Hata ayrıntıları: ${e.toString()}');
      return [];
    } finally {
      await conn?.close();
    }
  }

  Future<List<Class>> getClassesForTrainer(int trainerId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.query('''
        SELECT 
          d.ders_id,
          d.ders_adi,  
          d.gun, 
          d.baslangic_saati as startTime,
          d.bitis_saati as endTime,
          d.saat,
          d.sure_dakika,
          d.max_kapasite as capacity,
          d.lokasyon as location,
          d.kullanici_id as trainerId,
          CONCAT(k.ad, ' ', k.soyad) AS trainerName
        FROM ders d
        INNER JOIN kullanici k ON d.kullanici_id = k.kullanici_id
        WHERE d.kullanici_id = $trainerId
        ORDER BY d.gun, d.saat
      ''');

      return results.rows.map((row) => Class.fromMap(row)).toList();
    } catch (e) {
      print('Eğitmen dersleri getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Derse katılım ekle
  Future<bool> addAttendance(int classId, int memberId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      // Katılım kontrolü
      final existingAttendance = await conn.getOne(
        table: 'derskatilim',
        where: {'ders_id': classId, 'uye_id': memberId},
      );

      if (existingAttendance != null) {
        return false;
      }

      // Yeni katılım ekle
      final result = await conn.insert(
        table: 'derskatilim',
        insertData: {
          'ders_id': classId,
          'uye_id': memberId,
          'tarih': DateTime.now().toString(),
          'durum': 'Geldi',
        },
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Derse katılım ekleme hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Katılım durumunu güncelle
  Future<bool> updateAttendance(int attendanceId, String status) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final result = await conn.update(
        table: 'derskatilim',
        updateData: {'durum': status},
        where: {'katilim_id': attendanceId},
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Katılım güncelleme hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Süreyi dakika cinsinden hesaplayan yardımcı metot
  int _calculateDurationInMinutes(String startTime, String endTime) {
    final start = DateTime.parse('1970-01-01 $startTime');
    final end = DateTime.parse('1970-01-01 $endTime');
    return end.difference(start).inMinutes;
  }

  // Yeni ders oluştur
  Future<bool> createClass(Class classData) async {
    MysqlUtils? conn;
    try {
      conn = await DatabaseConnection.getConnection();

      // Önce eğitmenin var olup olmadığını kontrol et
      final trainerExists = await conn.getOne(
        table: 'kullanici',
        where: {'kullanici_id': classData.trainerId, 'rol': 'Egitmen'},
      );

      if (trainerExists == null) {
        print('Eğitmen bulunamadı! ID: ${classData.trainerId}');
        return false;
      }

      final result = await conn.insert(
        table: 'ders',
        insertData: {
          'ders_adi': classData.name,
          'gun': classData.dayOfWeek,
          'sure_dakika': _calculateDurationInMinutes(
            classData.startTime,
            classData.endTime,
          ),
          'max_kapasite': 20,
          'lokasyon': 'Ana Salon',
          'aktiflik': 'Aktif',
          'kullanici_id': classData.trainerId,
          'baslangic_saati': classData.startTime,
          'bitis_saati': classData.endTime,
        },
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Ders ekleme hatası: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  // Ders güncelleme metodu (eklenmesi önerilir)
  Future<bool> updateClass(Class classData) async {
    MysqlUtils? conn;
    try {
      conn = await DatabaseConnection.getConnection();

      final trainerExists = await conn.getOne(
        table: 'kullanici',
        where: {'kullanici_id': classData.trainerId, 'rol': 'Egitmen'},
      );

      if (trainerExists == null) {
        print('Eğitmen bulunamadı! ID: ${classData.trainerId}');
        return false;
      }

      final result = await conn.update(
        table: 'ders',
        updateData: {
          'ders_adi': classData.name,
          'gun': classData.dayOfWeek,
          'saat': classData.startTime,
          'sure_dakika': _calculateDurationInMinutes(
            classData.startTime,
            classData.endTime,
          ),
          'kullanici_id': classData.trainerId,
        },
        where: {'ders_id': classData.id},
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Ders güncelleme hatası: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> deleteClass(int classId) async {
    MysqlUtils? conn;
    try {
      conn = await DatabaseConnection.getConnection();

      await conn.delete(table: 'derskatilim', where: {'ders_id': classId});

      final result = await conn.delete(
        table: 'ders',
        where: {'ders_id': classId},
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Ders silme hatası: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<List<Attendance>> getClassAttendances(int classId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.query('''
        SELECT 
          dk.katilim_id as id,
          dk.uye_id as memberId,
          dk.ders_id as classId,
          dk.tarih as date,
          dk.durum as status,
          CONCAT(k.ad, ' ', k.soyad) as memberName
        FROM derskatilim dk
        INNER JOIN uye u ON dk.uye_id = u.uye_id
        INNER JOIN kullanici k ON u.kullanici_id = k.kullanici_id
        WHERE dk.ders_id = $classId
        ORDER BY dk.tarih DESC
      ''');

      return results.rows.map((row) => Attendance.fromMap(row)).toList();
    } catch (e) {
      print('Ders katılımlarını getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
