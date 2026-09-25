// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'STT Merve';

  @override
  String get homeTitle => 'Voice Notes';

  @override
  String get editAndSave => 'Edit and Save Recording';

  @override
  String get micPermissionDenied => 'Microphone permission denied.';

  @override
  String get micPermissionDeniedDesc =>
      'Please allow microphone access in settings.';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get speechUnavailable => 'Speech recognition is unavailable.';

  @override
  String get speechUnavailableDesc =>
      'Please make sure speech recognition is enabled on your device.';

  @override
  String get genericError => 'An error occurred.';

  @override
  String get stop => 'Stop';

  @override
  String get talk => 'Talk';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get serverConnectionTitle => 'Server Connection';

  @override
  String get serverConnectionDesc =>
      'Enter the Command Center server address here (e.g., http://192.168.1.100:5000)';

  @override
  String get serverUrlLabel => 'Server URL';

  @override
  String get serverUrlHint => 'http://192.168.1.100:5000';

  @override
  String get testAndSaveButton => 'Test and Save Connection';

  @override
  String get appConfigTitle => 'App Configuration';

  @override
  String get viewConfigButton => 'View Configuration';

  @override
  String get serverUpdateSuccess => 'Server address updated successfully';

  @override
  String get serverUpdateError => 'An error occurred. Please try again.';

  @override
  String get pendingEntriesTitle => 'Pending Entries';

  @override
  String get syncSuccess => 'Synchronization completed successfully';

  @override
  String get syncError => 'An error occurred during synchronization.';

  @override
  String get configUpdateSuccess => 'Configuration updated';

  @override
  String get configUpdateError =>
      'An error occurred while updating configuration.';

  @override
  String get noEntriesFound => 'No pending entries found.';

  @override
  String get editEntryTitle => 'Edit Entry';

  @override
  String get textLabel => 'Text';

  @override
  String get selectCategory => 'Select Category:';

  @override
  String get selectType => 'Select Type:';

  @override
  String get configMissingError => 'Configuration not found. Please sync.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get selectCategoryAndTypeError => 'Please select a category and type';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get categoryDistributionTitle => 'Category Distribution';

  @override
  String get noDataFound => 'No data found';

  @override
  String get dailyRecordCountTitle => 'Daily Record Count (Last 7 Days)';

  @override
  String get totalRecords => 'Total Records';

  @override
  String get currentConfigurationTitle => 'Current Configuration';

  @override
  String get serverAddressLabel => 'Server Address:';

  @override
  String get categoriesAndTypesTitle => 'Categories and Types:';

  @override
  String get noConfigurationLoaded => 'No configuration loaded yet.';

  @override
  String get allowedTypesLabel => 'Allowed Types:';
}
