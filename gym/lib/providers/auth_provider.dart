import 'package:flutter/material.dart';
import 'package:gym/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Kullanıcı rollerini kontrol etme getter'ları
  bool get isAdmin => _currentUser?.role == 'Admin';
  bool get isTrainer => _currentUser?.role == 'Egitmen';
  bool get isMember => _currentUser?.role == 'Uye';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authService = AuthService();
      final user = await authService.login(email, password);
      print("user: $user"); // Debugging için eklenmiştir

      if (user != null) {
        _currentUser = user;
        _saveUserSession(user.id, user.role);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Giriş başarısız. Email veya şifre hatalı.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Giriş sırasında bir hata oluştu: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // register metodu ekleyin

  Future<bool> register(String fullName, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authService = AuthService();
      final success = await authService.register(fullName, email, password);

      if (success) {
        return true;
      } else {
        _error = 'Kayıt işlemi başarısız oldu, lütfen tekrar deneyin';
        return false;
      }
    } catch (e) {
      _error = 'Kayıt sırasında bir hata oluştu: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerTrainer(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final AuthService _authService = AuthService();
      final success = await _authService.registerTrainer(
        firstName,
        lastName,
        email,
        password,
      );

      if (!success) {
        _error = 'Eğitmen kaydı başarısız oldu';
      }

      return success;
    } catch (e) {
      _error = 'Eğitmen kaydı sırasında hata: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    notifyListeners();
  }

  // Oturum bilgisini kaydet
  Future<void> _saveUserSession(int userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('userRole', role);
  }

  // Kaydedilmiş oturumu kontrol et
  Future<bool> checkSavedSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        final authService = AuthService();
        final user = await authService.getUserById(userId);

        if (user != null) {
          _currentUser = user;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = "Oturum kontrolünde hata oluştu: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
