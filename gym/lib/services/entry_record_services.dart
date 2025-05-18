import 'package:mysql_utils/mysql_utils.dart';
import '../config/db_connection.dart';
import '../models/entry_record.dart';

class EntryRecordService {
  Future<List<EntryRecord>> getMemberEntries(int memberId) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.getAll(
        table: 'giriskaydi',
        where: {'uye_id': memberId},
        order: 'tarih_saat DESC',
      );

      return results.map((row) => EntryRecord.fromMap(row)).toList();
    } catch (e) {
      print('Giriş kayıtlarını getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> addEntryRecord(int memberId, String entryType) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final result = await conn.insert(
        table: 'giriskaydi',
        insertData: {
          'uye_id': memberId,
          'tarih_saat': DateTime.now().toString(),
          'giris_tipi': entryType,
        },
      );

      return result > BigInt.from(0);
    } catch (e) {
      print('Giriş kaydı ekleme hatası: $e');
      return false;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<List<EntryRecord>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();

      final results = await conn.query('''
        SELECT 
          g.giris_id,
          g.uye_id,
          g.tarih_saat,
          g.giris_tipi,
          CONCAT(k.ad, ' ', k.soyad) as member_name
        FROM giriskaydi g
        INNER JOIN uye u ON g.uye_id = u.uye_id
        INNER JOIN kullanici k ON u.kullanici_id = k.kullanici_id
        WHERE g.tarih_saat BETWEEN '${start.toString()}' AND '${end.toString()}'
        ORDER BY g.tarih_saat DESC
      ''');

      return results.rows.map((row) => EntryRecord.fromMap(row)).toList();
    } catch (e) {
      print('Tarih aralığına göre girişleri getirme hatası: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
