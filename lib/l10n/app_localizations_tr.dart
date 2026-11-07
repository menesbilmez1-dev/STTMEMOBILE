// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'STT Merve';

  @override
  String get homeTitle => 'Sesli Notlar';

  @override
  String get editAndSave => 'Kaydı Düzenle ve Kaydet';

  @override
  String get micPermissionDenied => 'Mikrofon izni verilmedi.';

  @override
  String get micPermissionDeniedDesc =>
      'Lütfen ayarlardan mikrofon erişimine izin verin.';

  @override
  String get goToSettings => 'Ayarlara Git';

  @override
  String get speechUnavailable => 'Ses tanıma kullanılamıyor.';

  @override
  String get speechUnavailableDesc =>
      'Lütfen cihazınızın ses tanıma özelliklerinin aktif olduğundan emin olun.';

  @override
  String get genericError => 'Bir hata oluştu.';

  @override
  String get stop => 'Durdur';

  @override
  String get talk => 'Konuş';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get serverConnectionTitle => 'Sunucu Bağlantısı';

  @override
  String get serverConnectionDesc =>
      'Komut Merkezi sunucu adresini buraya girin (örn: http://192.168.1.100:8080)';

  @override
  String get serverUrlLabel => 'Sunucu URL';

  @override
  String get serverUrlHint => 'http://192.168.1.100:8080';

  @override
  String get testAndSaveButton => 'Bağlantıyı Test Et ve Kaydet';

  @override
  String get appConfigTitle => 'Uygulama Konfigürasyonu';

  @override
  String get viewConfigButton => 'Konfigürasyonu Görüntüle';

  @override
  String get serverUpdateSuccess => 'Sunucu adresi başarıyla güncellendi';

  @override
  String get serverUpdateError => 'Bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get pendingEntriesTitle => 'Bekleyen Kayıtlar';

  @override
  String get syncSuccess => 'Senkronizasyon başarıyla tamamlandı';

  @override
  String get syncError => 'Senkronizasyon sırasında bir hata oluştu.';

  @override
  String get configUpdateSuccess => 'Konfigürasyon güncellendi';

  @override
  String get configUpdateError =>
      'Konfigürasyon güncellenirken bir hata oluştu.';

  @override
  String get configUpdateButton => 'Konfigürasyonu Getir';

  @override
  String get noEntriesFound => 'Bekleyen kayıt bulunamadı.';

  @override
  String get editEntryTitle => 'Kaydı Düzenle';

  @override
  String get textLabel => 'Metin';

  @override
  String get selectCategory => 'Kategori Seçin:';

  @override
  String get selectType => 'Tip Seçin:';

  @override
  String get configMissingError =>
      'Konfigürasyon bulunamadı. Lütfen senkronize edin.';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get selectCategoryAndTypeError => 'Lütfen kategori ve tip seçin';

  @override
  String get statisticsTitle => 'İstatistikler';

  @override
  String get categoryDistributionTitle => 'Kategori Dağılımı';

  @override
  String get noDataFound => 'Veri bulunamadı';

  @override
  String get dailyRecordCountTitle => 'Günlük Kayıt Sayısı (Son 7 Gün)';

  @override
  String get totalRecords => 'Toplam Kayıt';

  @override
  String get currentConfigurationTitle => 'Mevcut Konfigürasyon';

  @override
  String get serverAddressLabel => 'Sunucu Adresi:';

  @override
  String get categoriesAndTypesTitle => 'Kategori ve Türler:';

  @override
  String get noConfigurationLoaded => 'Henüz bir konfigürasyon yüklenmedi.';

  @override
  String get allowedTypesLabel => 'İzin Verilen Türler:';

  @override
  String get reviewSpeechDraft => 'Ses taslağını incele';

  @override
  String get addCommand => 'Komut ekle';

  @override
  String get removeCommand => 'Komutu kaldır';

  @override
  String get saveReviewedBatch => 'İncelenen grubu kaydet';

  @override
  String get transcriptLabel => 'Algılanan konuşma';

  @override
  String get unparsedTranscript =>
      'Komut algılanamadı. Kaydetmeden önce komutları düzeltin veya ekleyin.';

  @override
  String get mustHaveTwoCommands =>
      'Bir ses kaydı en az iki komut içermelidir.';

  @override
  String get invalidCommandBatch =>
      'Komutlar yapılandırılmış kategori/tür çiftlerini kullanmalı, değer içermeli ve farklı sütunlara yazılmalıdır.';

  @override
  String get reviewSaveError =>
      'İncelenen taslak kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get awaitingReview => 'İnceleme bekliyor';

  @override
  String get draftSaved =>
      'Konuşma taslak olarak kaydedildi. Eşitlemeden önce inceleyin.';

  @override
  String get syncCompletedWithDrafts =>
      'Onaylanan kayıtlar eşitlendi. Ses taslakları inceleme bekliyor.';

  @override
  String get emptyCategoryLabel => '(Kategori yok)';
}
