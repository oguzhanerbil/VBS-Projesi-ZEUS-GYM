
# ZEUS GYM

## 📌 Proje Özeti

ZEUS GYM, modern spor salonlarının dijital yönetimini hedefleyen, Flutter ile geliştirilmiş ve MySQL veritabanı desteğiyle çalışan bir mobil uygulamadır. Üyelik yönetimi, ders planlama, eğitmen atamaları, ödeme ve giriş-çıkış takibi gibi işlemleri otomatize ederek kullanıcı deneyimini ve işletme verimliliğini artırır. Sistem, farklı kullanıcı rollerine (Admin, Eğitmen, Üye) özel paneller sunar ve güvenli veri yönetimi sağlar.

## ⚙️ Geliştirme Ortamı

* **IDE:** Visual Studio Code / Android Studio
* **Dil:** Dart
* **Framework:** Flutter
* **Veritabanı:** MySQL
* **Min SDK:** Flutter SDK 3.x
* **Test Ortamı:** Android Emulator & Gerçek Cihaz
* **Versiyon Kontrol:** Git & GitHub

## 🗃️ Veritabanı Yapısı

Proje kapsamında kullanılan başlıca tablolar:

* `kullanici` - Tüm kullanıcıların temel bilgileri
* `uye` - Üyelere özel bilgiler ve üyelik durumu
* `uyelikpaketi` - Üyelik paket tanımları
* `ders` - Ders programları
* `derskatilim` - Ders katılım kayıtları
* `odeme` - Ödeme işlemleri
* `bildirim` - Bildirim kayıtları
* `giriskaydi` - Giriş-çıkış kayıtları
* `login_log` - Giriş logları

İlişkiler yabancı anahtarlar ile tanımlanmış, veritabanı 3NF’ye göre normalleştirilmiştir. Ayrıca view ve trigger yapıları kullanılmıştır.

## 🔧 Kurulum ve Çalıştırma

1. Bu repoyu klonlayın:

   ```bash
   git clone https://github.com/oguzhanerbil/VBS-Projesi-ZEUS-GYM/
   ```

2. Android Studio ile projeyi açın:

   * `File > Open > gym` dizinini seçin.

3. Emulator veya fiziksel bir cihazda uygulamayı çalıştırın:

   * `Run > Run 'app'`, Shift+F10 veya terminale `flutter run` yazarak çalıştırın.

## 🗈️ Arayüzden Görüntüler

| Giriş Sayfası                              | Eğitmen Sayfası                            | Yönetici Sayfası                      |
| -------------------------------------- | ---------------------------------------- | -------------------------------------- |
| ![giris](/login_page.jpeg)    | ![egitmen](/egitmen_page.jpeg)    | ![yonetici](/admin_page.jpeg)|

## 📁 Proje Dosyaları

* `grupno_rapor.docx` – IEEE formatlı proje raporu 


## 📚 Kaynaklar

* [MySQL 8.0 Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)
* [Flutter Documentation](https://flutter.dev/docs)
* [Provider Package](https://pub.dev/packages/provider)
* [mysql_utils Package](https://pub.dev/packages/mysql_utils)

## 🧑‍🏫 Proje Ekibi

| İsim | GitHub |
|------|--------|
| Oğuzhan Erbil | [oguzhanerbil](https://github.com/oguzhanerbil) |
| Emirhan Oktay | [Punisher](https://github.com/Punisher) |
| Efekan Demir | [EfekanDemir](https://github.com/EfekanDemir) |


---

© 2025 – Kocaeli Üniversitesi Bilgisayar Mühendisliği – VTYS Final Projesi
