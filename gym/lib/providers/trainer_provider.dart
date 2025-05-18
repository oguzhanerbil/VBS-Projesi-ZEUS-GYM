import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/member/user_service.dart';

class TrainerProvider with ChangeNotifier {
  final UserService _userService = UserService();
  List<User> _trainers = [];
  bool _isLoading = false;
  String? _error;

  List<User> get trainers => _trainers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTrainers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trainers = await _userService.getAllTrainers();
    } catch (e) {
      _error = 'Eğitmenler yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTrainer(int trainerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Eğitmeni veritabanından sil
      final success = await _userService.deleteTrainer(trainerId);

      if (success) {
        // Başarılı silme işleminden sonra listeyi güncelle
        _trainers.removeWhere((trainer) => trainer.id == trainerId);
        notifyListeners();
        return true;
      } else {
        _error = 'Eğitmen silinirken bir hata oluştu';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Eğitmen silinirken bir hata oluştu: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
