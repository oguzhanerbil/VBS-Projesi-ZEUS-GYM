import 'package:flutter/material.dart';
import 'package:gym/models/package.dart';
import 'package:gym/services/admin/package_services.dart';

class PackageProvider with ChangeNotifier {
  final _packageService = PackageService();
  List<PackageModel> _packages = [];
  bool _isLoading = false;
  String? _error;

  List<PackageModel> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPackages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _packages = await _packageService.getPackages();
    } catch (e) {
      _error = 'Paketler yüklenirken hata oluştu';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPackage(PackageModel package) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _packageService.addPackage(package);
      if (success) {
        await loadPackages();
      }
      return success;
    } catch (e) {
      _error = 'Paket eklenirken hata oluştu';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePackage(int id, PackageModel package) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _packageService.updatePackage(id, package);
      if (success) {
        await loadPackages();
      }
      return success;
    } catch (e) {
      _error = 'Paket güncellenirken hata oluştu';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePackage(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _packageService.deletePackage(id);
      if (success) {
        await loadPackages();
      }
      return success;
    } catch (e) {
      _error = 'Paket silinirken hata oluştu';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
