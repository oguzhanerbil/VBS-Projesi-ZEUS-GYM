import 'package:flutter/material.dart';
import 'package:gym/screens/admin/class_schedule_management.dart';
import 'package:gym/screens/admin/member_managment_screen.dart';
import 'package:gym/screens/admin/trainer_managment.dart';
import 'package:gym/screens/auth/register_admin.dart';
import 'package:gym/screens/auth/register_screen.dart';
import 'package:gym/screens/auth/register_trainer_screen.dart';
import 'package:gym/screens/member/membership_packages.dart';
import 'package:gym/screens/member/payment_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/member/member_home_screen.dart';
import '../screens/member/class_schedule_screen.dart';
import '../screens/member/payment_history_screen.dart';
import '../screens/trainer/trainer_home_screen.dart';
import '../screens/trainer/attendance_screen.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/member/member_list_screen.dart';
import '../screens/admin/package_management_screen.dart';

// Rota isimleri sabit olarak tanımlanıyor
class Routes {
  static const login = '/login';
  static const memberHome = '/member/home';
  static const classSchedule = '/member/classes';
  static const paymentHistory = '/member/payments';
  static const trainerHome = '/trainer/home';
  static const attendance = '/trainer/attendance';
  static const adminHome = '/admin/home';
  static const memberList = '/admin/members';
  static const packageManagement = '/admin/packages';
  static const String register = '/register';
  static const registerAdmin = '/admin/register';
  static const String registerTrainer = '/registerTrainer';
  static const membershipPackages = '/membership-packages';
  static const payment = '/payment';
  static const trainerManagement = '/admin/trainers';
  static const memberManagement = '/admin/members/management';
  static const classScheduleManagement = '/admin/classes';
  static const reports = '/admin/reports';
}

// Uygulamanın tüm rotaları
final Map<String, WidgetBuilder> appRoutes = {
  Routes.login: (context) => const LoginScreen(),
  Routes.memberHome: (context) => const MemberHomeScreen(),
  Routes.classSchedule: (context) => const ClassScheduleScreen(),
  Routes.paymentHistory: (context) => const PaymentHistoryScreen(),
  Routes.trainerHome: (context) => const TrainerHomeScreen(),
  Routes.attendance: (context) => const AttendanceScreen(),
  Routes.adminHome: (context) => const AdminHomeScreen(),
  Routes.memberList: (context) => const MemberListScreen(),
  Routes.packageManagement: (context) => const PackageManagementScreen(),
  Routes.register: (context) => const RegisterScreen(),
  Routes.registerTrainer: (context) => const RegisterTrainerScreen(),
  Routes.membershipPackages: (context) => const MembershipPackagesScreen(),
  Routes.payment: (context) => const PaymentScreen(),
  Routes.registerAdmin: (context) => const RegisterAdminScreen(),
  Routes.trainerManagement: (context) => const TrainerManagementScreen(),
  Routes.memberManagement: (context) => const MemberManagementScreen(),
  Routes.classScheduleManagement:
      (context) => const ClassScheduleManagementScreen(),
};

// Rol bazlı yönlendirme yardımcı fonksiyonu
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (context) {
      // Varsayılan olarak login ekranına yönlendir
      return const LoginScreen();
    },
  );
}
