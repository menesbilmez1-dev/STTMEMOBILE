import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'STT Merve'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Notes'**
  String get homeTitle;

  /// No description provided for @editAndSave.
  ///
  /// In en, this message translates to:
  /// **'Edit and Save Recording'**
  String get editAndSave;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied.'**
  String get micPermissionDenied;

  /// No description provided for @micPermissionDeniedDesc.
  ///
  /// In en, this message translates to:
  /// **'Please allow microphone access in settings.'**
  String get micPermissionDeniedDesc;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is unavailable.'**
  String get speechUnavailable;

  /// No description provided for @speechUnavailableDesc.
  ///
  /// In en, this message translates to:
  /// **'Please make sure speech recognition is enabled on your device.'**
  String get speechUnavailableDesc;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get genericError;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @talk.
  ///
  /// In en, this message translates to:
  /// **'Talk'**
  String get talk;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @serverConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Connection'**
  String get serverConnectionTitle;

  /// No description provided for @serverConnectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the Command Center server address here (e.g., http://192.168.1.100:8080)'**
  String get serverConnectionDesc;

  /// No description provided for @serverUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrlLabel;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'http://192.168.1.100:8080'**
  String get serverUrlHint;

  /// No description provided for @testAndSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Test and Save Connection'**
  String get testAndSaveButton;

  /// No description provided for @appConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'App Configuration'**
  String get appConfigTitle;

  /// No description provided for @viewConfigButton.
  ///
  /// In en, this message translates to:
  /// **'View Configuration'**
  String get viewConfigButton;

  /// No description provided for @serverUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Server address updated successfully'**
  String get serverUpdateSuccess;

  /// No description provided for @serverUpdateError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get serverUpdateError;

  /// No description provided for @pendingEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Entries'**
  String get pendingEntriesTitle;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Synchronization completed successfully'**
  String get syncSuccess;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during synchronization.'**
  String get syncError;

  /// No description provided for @configUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Configuration updated'**
  String get configUpdateSuccess;

  /// No description provided for @configUpdateError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating configuration.'**
  String get configUpdateError;

  /// No description provided for @configUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Fetch Configuration'**
  String get configUpdateButton;

  /// No description provided for @noEntriesFound.
  ///
  /// In en, this message translates to:
  /// **'No pending entries found.'**
  String get noEntriesFound;

  /// No description provided for @editEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get editEntryTitle;

  /// No description provided for @textLabel.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textLabel;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category:'**
  String get selectCategory;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select Type:'**
  String get selectType;

  /// No description provided for @configMissingError.
  ///
  /// In en, this message translates to:
  /// **'Configuration not found. Please sync.'**
  String get configMissingError;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @selectCategoryAndTypeError.
  ///
  /// In en, this message translates to:
  /// **'Please select a category and type'**
  String get selectCategoryAndTypeError;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @categoryDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Distribution'**
  String get categoryDistributionTitle;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// No description provided for @dailyRecordCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Record Count (Last 7 Days)'**
  String get dailyRecordCountTitle;

  /// No description provided for @totalRecords.
  ///
  /// In en, this message translates to:
  /// **'Total Records'**
  String get totalRecords;

  /// No description provided for @currentConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Configuration'**
  String get currentConfigurationTitle;

  /// No description provided for @serverAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Server Address:'**
  String get serverAddressLabel;

  /// No description provided for @categoriesAndTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories and Types:'**
  String get categoriesAndTypesTitle;

  /// No description provided for @noConfigurationLoaded.
  ///
  /// In en, this message translates to:
  /// **'No configuration loaded yet.'**
  String get noConfigurationLoaded;

  /// No description provided for @allowedTypesLabel.
  ///
  /// In en, this message translates to:
  /// **'Allowed Types:'**
  String get allowedTypesLabel;

  /// No description provided for @reviewSpeechDraft.
  ///
  /// In en, this message translates to:
  /// **'Review speech draft'**
  String get reviewSpeechDraft;

  /// No description provided for @addCommand.
  ///
  /// In en, this message translates to:
  /// **'Add command'**
  String get addCommand;

  /// No description provided for @removeCommand.
  ///
  /// In en, this message translates to:
  /// **'Remove command'**
  String get removeCommand;

  /// No description provided for @saveReviewedBatch.
  ///
  /// In en, this message translates to:
  /// **'Save reviewed batch'**
  String get saveReviewedBatch;

  /// No description provided for @transcriptLabel.
  ///
  /// In en, this message translates to:
  /// **'Recognized speech'**
  String get transcriptLabel;

  /// No description provided for @unparsedTranscript.
  ///
  /// In en, this message translates to:
  /// **'No commands were recognized. Correct or add commands before saving.'**
  String get unparsedTranscript;

  /// No description provided for @mustHaveTwoCommands.
  ///
  /// In en, this message translates to:
  /// **'A speech record must contain at least two commands.'**
  String get mustHaveTwoCommands;

  /// No description provided for @invalidCommandBatch.
  ///
  /// In en, this message translates to:
  /// **'Commands must use configured category/type pairs, have values, and target different columns.'**
  String get invalidCommandBatch;

  /// No description provided for @reviewSaveError.
  ///
  /// In en, this message translates to:
  /// **'The reviewed draft could not be saved. Please try again.'**
  String get reviewSaveError;

  /// No description provided for @awaitingReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get awaitingReview;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Speech saved as a draft. Review it before syncing.'**
  String get draftSaved;

  /// No description provided for @syncCompletedWithDrafts.
  ///
  /// In en, this message translates to:
  /// **'Approved entries synced. Speech drafts still need review.'**
  String get syncCompletedWithDrafts;

  /// No description provided for @emptyCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'(No category)'**
  String get emptyCategoryLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
