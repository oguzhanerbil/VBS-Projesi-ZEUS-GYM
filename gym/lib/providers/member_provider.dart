import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/membership_package.dart';
import '../services/member/member_service.dart';

class MemberProvider with ChangeNotifier {
  Member? _currentMember;
  MembershipPackage? _activePackage;
  List<Member> _membersList = [];
  bool _isLoading = false;
  String? _error;

  bool _isLoadingPackages = false;
  List<MembershipPackage> _packages = [];

  bool get isLoadingPackages => _isLoadingPackages;
  List<MembershipPackage> get packages => _packages;

  // Getters
  Member? get currentMember => _currentMember;
  MembershipPackage? get activePackage => _activePackage;
  List<Member> get membersList => _membersList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Üyelik durumu bilgisi
  bool get hasMembership => _activePackage != null;
  bool get isMembershipActive =>
      _activePackage != null &&
      (_activePackage!.endDate.isAfter(DateTime.now()) ||
          _activePackage!.endDate.isAtSameMomentAs(DateTime.now()));

  // Kalan gün sayısı hesaplama
  int get remainingDays {
    if (_activePackage == null) return 0;

    final now = DateTime.now();
    if (_activePackage!.endDate.isBefore(now)) return 0;

    return _activePackage!.endDate.difference(now).inDays;
  }

  bool _isShowingActiveOnly = true;
  bool get isShowingActiveOnly => _isShowingActiveOnly;

  void toggleActiveFilter() {
    _isShowingActiveOnly = !_isShowingActiveOnly;
    notifyListeners();
  }

  // Aktif üyenin bilgilerini yükle
  Future<void> loadMemberDetails(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memberService = MemberService();
      print("üye id bilgisi: $userId");
      final member = await memberService.getMemberByUserId(userId);

      if (member != null) {
        _currentMember = member;
        await loadActiveMembership(member.id);
      } else {
        _error = "Üye bilgileri bulunamadı";
      }
    } catch (e) {
      _error = "Üye bilgileri yüklenirken hata: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Üyeler yükleniyor...');
      final memberService = MemberService();
      _membersList = await memberService.getMembers();
      print('Yüklenen üye sayısı: ${_membersList.length}');
    } catch (e) {
      print('Üye listesi yükleme hatası: $e');
      _error = 'Üyeler yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Üyenin aktif üyelik paketini yükle
  Future<void> loadActiveMembership(int memberId) async {
    try {
      final memberService = MemberService();
      final package = await memberService.getActiveMembership(memberId);
      _activePackage = package;
    } catch (e) {
      _error = "Üyelik bilgileri yüklenirken hata: $e";
    }
    notifyListeners();
  }

  // Sadece aktif üyeleri yükle (view kullanır)
  Future<void> loadActiveMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Aktif üyeler yükleniyor...');
      final memberService = MemberService();
      _membersList = await memberService.getActiveMembers();
      print('Yüklenen aktif üye sayısı: ${_membersList.length}');
    } catch (e) {
      print('Aktif üye listesi yükleme hatası: $e');
      _error = 'Aktif üyeler yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Üye bilgisini güncelle (admin için)
  Future<bool> updateMember(int memberId, String fullName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memberService = MemberService();
      final success = await memberService.updateMember(memberId, fullName);

      if (success) {
        // Üye listesini güncelle
        await loadMembers();
        return true;
      } else {
        _error = "Üye güncellenemedi";
        return false;
      }
    } catch (e) {
      _error = "Üye güncellenirken hata: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMember(int memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Üye silme işlemi başlatıldı. ID: $memberId');
      final memberService = MemberService();
      final success = await memberService.deleteMember(memberId);

      if (success) {
        // Yerel listeden de üyeyi kaldır
        _membersList.removeWhere((member) => member.id == memberId);
        print('Üye başarıyla silindi');
      } else {
        _error = 'Üye silinirken bir hata oluştu';
        print('Üye silme işlemi başarısız');
      }

      return success;
    } catch (e) {
      print('Üye silme hatası: $e');
      _error = 'Üye silinirken bir hata oluştu: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Üyelik paketlerini yükleme
  Future<void> loadMembershipPackages() async {
    _isLoadingPackages = true;
    notifyListeners();

    try {
      final memberService = MemberService();
      _packages = await memberService.getMembershipPackages();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPackages = false;
      notifyListeners();
    }
  }

  // Üyelik satın alma
  Future<bool> purchaseMembership(int packageId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentMember == null) {
        _error = 'Üye bilgisi bulunamadı';
        return false;
      }

      final memberService = MemberService();
      final success = await memberService.purchaseMembership(
        _currentMember!.id,
        packageId,
      );

      if (success) {
        // Üyelik satın alındıktan sonra üye bilgilerini yeniden yükle
        await loadMemberDetails(_currentMember!.userId);
      }

      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Yeni üyelik paketi ekle
  Future<bool> addMembership(
    int memberId,
    int packageTypeId,
    DateTime startDate,
    DateTime endDate,
    double amount,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final memberService = MemberService();
      final success = await memberService.addMembership(
        memberId,
        packageTypeId,
        startDate,
        endDate,
        amount,
      );

      if (success) {
        // Üyelik bilgilerini güncelle
        if (_currentMember != null && _currentMember!.id == memberId) {
          await loadActiveMembership(memberId);
        }
        return true;
      } else {
        _error = "Üyelik eklenemedi";
        return false;
      }
    } catch (e) {
      _error = "Üyelik eklenirken hata: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Provider'ı temizle (çıkış yapıldığında)
  void clear() {
    _currentMember = null;
    _activePackage = null;
    _membersList = [];
    _error = null;
    notifyListeners();
  }
}
