import 'package:flutter/material.dart';
import '../models/class.dart';
import '../models/attendance.dart';
import '../services/class_service.dart';

class ClassProvider with ChangeNotifier {
  List<Class> _classes = [];
  List<Class> _memberClasses = []; // Üyenin katılabileceği dersler
  List<Class> _trainerClasses = []; // Eğitmenin kendi dersleri
  List<Attendance> _classAttendances = []; // Bir derse katılım bilgileri
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Class> get allClasses => _classes;
  List<Class> get memberClasses => _memberClasses;
  List<Class> get trainerClasses => _trainerClasses;
  List<Attendance> get classAttendances => _classAttendances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int? _selectedTrainerId;
  int? get selectedTrainerId => _selectedTrainerId;

  void updateSelectedTrainer(int? trainerId) {
    print('Seçilen Trainer ID: $trainerId'); // Debug için
    _selectedTrainerId = trainerId;
    notifyListeners();
  }

  // Class oluşturulduğunda veya güncellendiğinde seçili trainer'ı sıfırla
  void resetForm() {
    _selectedTrainerId = null;
    notifyListeners();
  }

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  TimeOfDay get startTime => _startTime;
  TimeOfDay get endTime => _endTime;

  void updateStartTime(TimeOfDay time) {
    _startTime = time;
    notifyListeners();
  }

  void updateEndTime(TimeOfDay time) {
    _endTime = time;
    notifyListeners();
  }

  // Tüm dersleri getir
  Future<void> loadAllClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classService = ClassService();
      _classes = await classService.getAllClasses();
    } catch (e) {
      _error = "Dersler yüklenirken hata: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addClass(
    String name,
    String day,
    String startTime,
    String endTime,
    int trainerId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classService = ClassService();
      final classData = Class(
        id: 0,
        name: name,
        dayOfWeek: day,
        startTime: startTime,
        endTime: endTime,
        trainerId: trainerId,
        durationMinutes:
            60, // Provide a default or appropriate value for 'durationMinutes'
        capacity: 20, // Provide a default or appropriate value for 'capacity'
      );

      final success = await classService.createClass(classData);

      if (success) {
        // Yeni ders oluşturulduğunda tüm dersleri yeniden yükle
        await loadAllClasses();
        return true;
      } else {
        _error = "Ders oluşturulamadı";
        return false;
      }
    } catch (e) {
      _error = "Ders oluşturulurken hata: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClass(
    int classId,
    String name,
    String day,
    String startTime,
    String endTime,
    int trainerId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classService = ClassService();
      final classData = Class(
        id: classId,
        name: name,
        dayOfWeek: day,
        startTime: startTime,
        endTime: endTime,
        trainerId: trainerId,
        durationMinutes:
            60, // Provide a default or appropriate value for 'durationMinutes'
        capacity: 20, // Provide a default or appropriate value for 'capacity'
      );

      final success = await classService.updateClass(classData);

      if (success) {
        // Ders güncellendikten sonra tüm dersleri yeniden yükle
        await loadAllClasses();
        return true;
      } else {
        _error = "Ders güncellenemedi";
        return false;
      }
    } catch (e) {
      _error = "Ders güncellenirken hata: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClass(int classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classService = ClassService();
      final success = await classService.deleteClass(classId);

      if (success) {
        // Ders silindikten sonra tüm dersleri yeniden yükle
        await loadAllClasses();
        return true;
      } else {
        _error = "Ders silinemedi";
        return false;
      }
    } catch (e) {
      _error = "Ders silinirken hata: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Üyenin katılabileceği dersleri yükle (bu haftaki program)
  Future<void> loadMemberClasses(int memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classService = ClassService();
      _memberClasses = await classService.getClassesForMember(memberId);
    } catch (e) {
      _error = "Üye dersleri yüklenirken hata: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eğitmenin verdiği dersleri getir
  Future<void> loadTrainerClasses(int trainerId) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final classService = ClassService();
      _trainerClasses = await classService.getClassesForTrainer(trainerId);
    } catch (e) {
      _error = "Eğitmen dersleri yüklenirken hata: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Belirli bir dersin katılım bilgilerini getir
  Future<void> loadClassAttendances(int classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classService = ClassService();
      _classAttendances = await classService.getClassAttendances(classId);
    } catch (e) {
      _error = "Katılım bilgileri yüklenirken hata: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Üyenin derse katılımını kaydet
  Future<bool> addAttendance(int classId, int memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classService = ClassService();
      final success = await classService.addAttendance(classId, memberId);

      if (success) {
        // Derse katılım başarılı olduğunda dersleri yeniden yükle
        await loadMemberClasses(memberId);
        return true;
      } else {
        _error = "Derse katılım kaydedilemedi";
        return false;
      }
    } catch (e) {
      _error = "Derse katılım kaydedilirken hata: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eğitmen tarafından yoklama işlemleri
  Future<bool> updateAttendance(int attendanceId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classService = ClassService();
      final success = await classService.updateAttendance(attendanceId, status);

      if (success) {
        // Katılım listesinde güncelleme yap
        final index = _classAttendances.indexWhere((a) => a.id == attendanceId);
        if (index != -1) {
          final updatedList = List<Attendance>.from(_classAttendances);
          updatedList[index] = _classAttendances[index].copyWith(
            status: status,
          );
          _classAttendances = updatedList;
        }
        notifyListeners();
        return true;
      } else {
        _error = "Yoklama güncellenemedi";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Yoklama güncellenirken hata: $e";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Yeni ders oluştur (admin/eğitmen için)
  Future<bool> createClass(Class classData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classService = ClassService();
      final success = await classService.createClass(classData);

      if (success) {
        // Yeni ders oluşturulduğunda tüm dersleri yeniden yükle
        await loadAllClasses();
        return true;
      } else {
        _error = "Ders oluşturulamadı";
        return false;
      }
    } catch (e) {
      _error = "Ders oluşturulurken hata: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Provider'ı temizle (çıkış yapıldığında)
  void clear() {
    _classes = [];
    _memberClasses = [];
    _trainerClasses = [];
    _classAttendances = [];
    _error = null;
    notifyListeners();
  }
}
