import 'package:flutter/material.dart';
import 'package:gym/services/entry_record_services.dart';
import '../models/entry_record.dart';

class EntryRecordProvider with ChangeNotifier {
  List<EntryRecord> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<EntryRecord> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Üye giriş kayıtlarını yükle
  Future<void> loadMemberEntries(int memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = EntryRecordService();
      _entries = await service.getMemberEntries(memberId);
    } catch (e) {
      _error = "Giriş kayıtları yüklenirken hata: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Yeni giriş kaydı ekle
  Future<bool> addEntry(int memberId, String entryType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = EntryRecordService();
      final success = await service.addEntryRecord(memberId, entryType);

      if (success) {
        await loadMemberEntries(memberId);
        return true;
      } else {
        _error = "Giriş kaydı eklenemedi";
        return false;
      }
    } catch (e) {
      _error = "Giriş kaydı eklenirken hata: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Belirli tarih aralığındaki giriş kayıtlarını getir
  Future<void> loadEntriesByDate(DateTime start, DateTime end) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = EntryRecordService();
      _entries = await service.getEntriesByDateRange(start, end);
    } catch (e) {
      _error = "Giriş kayıtları yüklenirken hata: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Provider'ı temizle
  void clear() {
    _entries = [];
    _error = null;
    notifyListeners();
  }
}
