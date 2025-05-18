import 'package:mysql_utils/mysql_utils.dart';

class DatabaseConnection {
  static Future<MysqlUtils> getConnection() async {
    final db = MysqlUtils(
      settings: {
        'host': '10.0.2.2',
        'port': 3306,
        'user': 'root',
        'password': '198910',
        'db': 'spor_salonu',
        'maxPacketSize': 32 * 1024 * 1024,
        'timeout': 30,
        'secure': true, // Changed to true
        'prefix': '',
        'pool': true,
        'collation': 'utf8mb4_general_ci',
      },
      errorLog: (error) {
        print('DB Error: $error');
      },
      sqlLog: (sql) {
        print('SQL: $sql');
      },
      connectInit: (db1) async {
        print('Veritabanı bağlantısı başarılı!');
      },
    );

    try {
      await db.query('SELECT 1');
      return db;
    } catch (e) {
      print('Veritabanı bağlantı hatası: $e');
      rethrow;
    }
  }
}
