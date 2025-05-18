import 'package:gym/config/db_connection.dart';
import 'package:gym/models/package.dart';
import 'package:mysql_utils/mysql_utils.dart';

class PackageService {
  Future<List<PackageModel>> getPackages() async {
    /*
    Aktif üyelerin paketlerini getiren fonksiyon.
    package_management_screen.dart dosyasında loadPackages providerı ile kullanılıyor.
    */
    MysqlUtils? conn;

    try {
      conn = await DatabaseConnection.getConnection();
      final results = await conn.query(
        'SELECT * FROM uyelikpaketi WHERE aktif = 1 ORDER BY fiyat ASC',
      );
      print('Paketler: ${results.rows}');

      return results.rows.map((row) => PackageModel.fromMap(row)).toList();
    } catch (e) {
      print('Paket listesi getirme hatası: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }

  Future<bool> addPackage(PackageModel package) async {
    /*
    package_management_screen.dart dosyasında addPackage providerı ile kullanılıyor.
    */
    MysqlUtils? conn;
    try {
      conn = await DatabaseConnection.getConnection();
      final result = await conn.insert(
        table: 'uyelikpaketi',
        insertData: package.toMap(),
      );
      return result > BigInt.from(0);
    } catch (e) {
      print('Paket ekleme hatası: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> updatePackage(int id, PackageModel package) async {
    /*
    package_management_screen.dart dosyasında updatePackage providerı ile kullanılıyor.
    */
    MysqlUtils? conn;
    try {
      conn = await DatabaseConnection.getConnection();
      final result = await conn.update(
        table: 'uyelikpaketi',
        updateData: package.toMap(),
        where: {'paket_id': id},
      );
      return result > BigInt.from(0);
    } catch (e) {
      print('Paket güncelleme hatası: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> deletePackage(int id) async {
    /*
    package_management_screen.dart dosyasında deletePackage providerı ile kullanılıyor.
    */
    MysqlUtils? conn;
    try {
      conn = await DatabaseConnection.getConnection();
      // Soft delete - paketi pasife çek
      final result = await conn.update(
        table: 'uyelikpaketi',
        updateData: {'aktif': 0},
        where: {'paket_id': id},
      );
      return result > BigInt.from(0);
    } catch (e) {
      print('Paket silme hatası: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }
}
