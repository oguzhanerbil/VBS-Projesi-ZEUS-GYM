import 'package:flutter/material.dart';
import 'package:gym/models/user.dart';
import 'package:gym/services/admin/admin_services.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<User> _admins = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<User> get admins => _admins;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Admin kayıt işlemi
  Future<bool> registerAdmin({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String adminKey,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _adminService.registerAdmin(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        adminKey: adminKey,
      );

      if (!success) {
        _error = 'Admin kaydı başarısız oldu';
      }

      return success;
    } catch (e) {
      _error = 'Admin kaydı hatası: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tüm adminleri yükle
  Future<void> loadAdmins() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _admins = await _adminService.getAllAdmins();
    } catch (e) {
      _error = 'Admin listesi yüklenemedi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
