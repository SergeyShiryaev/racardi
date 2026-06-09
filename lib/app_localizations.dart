import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'lib/app_localizations.dart';
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
    Locale('ru')
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @importExport.
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get importExport;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @sendExportMail.
  ///
  /// In en, this message translates to:
  /// **'Send Export by Email'**
  String get sendExportMail;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @columnsCount.
  ///
  /// In en, this message translates to:
  /// **'Number of Columns'**
  String get columnsCount;

  /// No description provided for @portrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait:'**
  String get portrait;

  /// No description provided for @landscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape:'**
  String get landscape;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @firstTime.
  ///
  /// In en, this message translates to:
  /// **'First time'**
  String get firstTime;

  /// No description provided for @searchCards.
  ///
  /// In en, this message translates to:
  /// **'Search cards...'**
  String get searchCards;

  /// No description provided for @noCards.
  ///
  /// In en, this message translates to:
  /// **'No cards'**
  String get noCards;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get addCard;

  /// No description provided for @selectBarcode.
  ///
  /// In en, this message translates to:
  /// **'Select barcode'**
  String get selectBarcode;

  /// No description provided for @racardiWallet.
  ///
  /// In en, this message translates to:
  /// **'Racardi Wallet'**
  String get racardiWallet;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.1.1'**
  String get version;

  /// No description provided for @aboutInfo.
  ///
  /// In en, this message translates to:
  /// **'Dedicated to a fluffy friend who went over the rainbow.'**
  String get aboutInfo;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @exportChooseAction.
  ///
  /// In en, this message translates to:
  /// **'Choose an action to save or load data'**
  String get exportChooseAction;

  /// No description provided for @exportSent.
  ///
  /// In en, this message translates to:
  /// **'Export sent by email'**
  String get exportSent;

  /// No description provided for @exportCompleted.
  ///
  /// In en, this message translates to:
  /// **'Export completed'**
  String get exportCompleted;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export error'**
  String get exportError;

  /// No description provided for @exportErrorSend.
  ///
  /// In en, this message translates to:
  /// **'Send error'**
  String get exportErrorSend;

  /// No description provided for @locationTracking.
  ///
  /// In en, this message translates to:
  /// **'This app uses your location to automatically open discount cards and track where they are used.'**
  String get locationTracking;

  /// No description provided for @cameraScanning.
  ///
  /// In en, this message translates to:
  /// **'App uses camera to scan barcodes on discount cards.'**
  String get cameraScanning;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'App uses photo library to add card images.'**
  String get photoLibrary;

  /// No description provided for @frontSide.
  ///
  /// In en, this message translates to:
  /// **'Front side'**
  String get frontSide;

  /// No description provided for @backSide.
  ///
  /// In en, this message translates to:
  /// **'Back side'**
  String get backSide;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get noImages;

  /// No description provided for @zoomHint.
  ///
  /// In en, this message translates to:
  /// **'✌️ Zoom with fingers / Double tap = reset'**
  String get zoomHint;

  /// No description provided for @barcodeFront.
  ///
  /// In en, this message translates to:
  /// **'Barcode front'**
  String get barcodeFront;

  /// No description provided for @barcodeBack.
  ///
  /// In en, this message translates to:
  /// **'Barcode back'**
  String get barcodeBack;

  /// No description provided for @barcodeBoth.
  ///
  /// In en, this message translates to:
  /// **'Both sides'**
  String get barcodeBoth;

  /// No description provided for @usageLocations.
  ///
  /// In en, this message translates to:
  /// **'📍 Usage locations'**
  String get usageLocations;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t find such a card'**
  String get notFound;

  /// No description provided for @noSavedLocations.
  ///
  /// In en, this message translates to:
  /// **'No saved locations'**
  String get noSavedLocations;

  /// No description provided for @firstVisit.
  ///
  /// In en, this message translates to:
  /// **'First time'**
  String get firstVisit;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @editing.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get editing;

  /// No description provided for @imageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image'**
  String get imageSaveFailed;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// No description provided for @deleteCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete card?'**
  String get deleteCardConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @barcodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to recognize barcode. Enter manually.'**
  String get barcodeFailed;

  /// No description provided for @cardUpdated.
  ///
  /// In en, this message translates to:
  /// **'✅ Card updated'**
  String get cardUpdated;

  /// No description provided for @cardSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Save error'**
  String get cardSaveFailed;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get editCard;

  /// No description provided for @autoDetectBarcode.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect barcode'**
  String get autoDetectBarcode;

  /// No description provided for @barcodeDetected.
  ///
  /// In en, this message translates to:
  /// **'✅ Barcode detected'**
  String get barcodeDetected;

  /// No description provided for @barcodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'❌ Barcode not found'**
  String get barcodeNotFound;

  /// No description provided for @barcodeLocation.
  ///
  /// In en, this message translates to:
  /// **'Side with barcode:'**
  String get barcodeLocation;

  /// No description provided for @front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get front;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @errorSending.
  ///
  /// In en, this message translates to:
  /// **'Send error'**
  String get errorSending;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
