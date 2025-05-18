import 'package:flutter/material.dart';
import 'package:gym/providers/admin/admin_provider.dart';
import 'package:gym/providers/admin/package_provider.dart';
import 'package:gym/providers/trainer_provider.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/db_connection.dart';
import 'providers/auth_provider.dart';
import 'providers/member_provider.dart';
import 'providers/class_provider.dart';
import 'providers/entry_record_provider.dart'; // Yeni
import 'providers/notification_provider.dart'; // Yeni
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Veritabanı bağlantısını test et
  try {
    final conn = await DatabaseConnection.getConnection();
    await conn.close();
    print('Veritabanı bağlantısı başarılı!');
  } catch (e) {
    print('Veritabanı bağlantısı başarısız: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => EntryRecordProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => TrainerProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => PackageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Spor Salonu Takip',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        routes: appRoutes,
      ),
    );
  }
}
