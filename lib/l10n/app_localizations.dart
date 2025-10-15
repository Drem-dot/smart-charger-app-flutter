import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Smart Charger'**
  String get appName;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navStationList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get navStationList;

  /// No description provided for @navAddStation.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAddStation;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Find charging stations by address...'**
  String get searchPlaceholder;

  /// No description provided for @directionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directionsTooltip;

  /// No description provided for @directionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Directions '**
  String get directionsTitle;

  /// No description provided for @directionsButton.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directionsButton;

  /// No description provided for @cannotOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps.'**
  String get cannotOpenMaps;

  /// Displays the distance to the charging station
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String stationCardDistance(String distance);

  /// No description provided for @sheetStationName.
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get sheetStationName;

  /// No description provided for @sheetAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get sheetAddress;

  /// No description provided for @sheetStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sheetStatusLabel;

  /// No description provided for @sheetConnectorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Connectors'**
  String get sheetConnectorsLabel;

  /// No description provided for @sheetOperatingHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Operating Hours'**
  String get sheetOperatingHoursLabel;

  /// No description provided for @sheetParkingDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Parking Details'**
  String get sheetParkingDetailsLabel;

  /// No description provided for @sheetReportProblemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get sheetReportProblemTooltip;

  /// No description provided for @sheetConnectorDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connector Details:'**
  String get sheetConnectorDetailsTitle;

  /// No description provided for @sheetConnectorTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Connectors:'**
  String get sheetConnectorTotalTitle;

  /// No description provided for @sheetConnectorInfo.
  ///
  /// In en, this message translates to:
  /// **'{count} ports'**
  String sheetConnectorInfo(String count);

  /// No description provided for @sheetConnectorPowerInfo.
  ///
  /// In en, this message translates to:
  /// **'{count} x {power}kW ports'**
  String sheetConnectorPowerInfo(String count, String power);

  /// No description provided for @noInfo.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get noInfo;

  /// No description provided for @addStationScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Station'**
  String get addStationScreenTitle;

  /// No description provided for @addStationMapLocation.
  ///
  /// In en, this message translates to:
  /// **'Location on Map *'**
  String get addStationMapLocation;

  /// No description provided for @addStationMapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to place a pin or drag the pin for the exact location.'**
  String get addStationMapHint;

  /// No description provided for @addStationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Station Name *'**
  String get addStationNameLabel;

  /// No description provided for @addStationNameValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get addStationNameValidator;

  /// No description provided for @addStationAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address *'**
  String get addStationAddressLabel;

  /// No description provided for @addStationAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search...'**
  String get addStationAddressHint;

  /// No description provided for @addStationAddressValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address'**
  String get addStationAddressValidator;

  /// No description provided for @addStationNoAddressFound.
  ///
  /// In en, this message translates to:
  /// **'No places found.'**
  String get addStationNoAddressFound;

  /// No description provided for @addStationConnectorType.
  ///
  /// In en, this message translates to:
  /// **'Connector Types'**
  String get addStationConnectorType;

  /// No description provided for @addStationPower.
  ///
  /// In en, this message translates to:
  /// **'Power (kW)'**
  String get addStationPower;

  /// No description provided for @addStationOperatingHoursHint.
  ///
  /// In en, this message translates to:
  /// **'Operating hours (e.g., 24/7)'**
  String get addStationOperatingHoursHint;

  /// No description provided for @addStationPricingDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Pricing details'**
  String get addStationPricingDetailsHint;

  /// No description provided for @addStationNetworkOperatorHint.
  ///
  /// In en, this message translates to:
  /// **'Network operator'**
  String get addStationNetworkOperatorHint;

  /// No description provided for @addStationAdminInfo.
  ///
  /// In en, this message translates to:
  /// **'Information for Admin'**
  String get addStationAdminInfo;

  /// No description provided for @addStationOwnerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner Name *'**
  String get addStationOwnerNameLabel;

  /// No description provided for @addStationOwnerNameValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter owner\'s name'**
  String get addStationOwnerNameValidator;

  /// No description provided for @addStationOwnerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner Phone Number *'**
  String get addStationOwnerPhoneLabel;

  /// No description provided for @addStationOwnerPhoneValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get addStationOwnerPhoneValidator;

  /// No description provided for @addStationImages.
  ///
  /// In en, this message translates to:
  /// **'Station Images (optional)'**
  String get addStationImages;

  /// No description provided for @addStationTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Station Type *'**
  String get addStationTypeTitle;

  /// No description provided for @stationTypeCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get stationTypeCar;

  /// No description provided for @stationTypeBike.
  ///
  /// In en, this message translates to:
  /// **'Motorbike'**
  String get stationTypeBike;

  /// No description provided for @addStationSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get addStationSubmitButton;

  /// No description provided for @addStationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{stationName}\" has been added and is pending review.'**
  String addStationSuccessMessage(String stationName);

  /// No description provided for @addStationMapPinValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a location on the map.'**
  String get addStationMapPinValidator;

  /// No description provided for @addStationMaxImages.
  ///
  /// In en, this message translates to:
  /// **'You can only select up to 4 images.'**
  String get addStationMaxImages;

  /// No description provided for @stationListPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Station List'**
  String get stationListPageTitle;

  /// No description provided for @stationListPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by location...'**
  String get stationListPageSearchHint;

  /// No description provided for @stationListError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String stationListError(String error);

  /// No description provided for @stationListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No charging stations found.'**
  String get stationListEmpty;

  /// No description provided for @settingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Info'**
  String get settingsPageTitle;

  /// No description provided for @settingsPartnership.
  ///
  /// In en, this message translates to:
  /// **'Partnership Introduction'**
  String get settingsPartnership;

  /// No description provided for @settingsUserGuide.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get settingsUserGuide;

  /// No description provided for @settingsOwnerGuide.
  ///
  /// In en, this message translates to:
  /// **'Station Owner Guide'**
  String get settingsOwnerGuide;

  /// No description provided for @settingsShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get settingsShareApp;

  /// No description provided for @settingsShareAppMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a nationwide charging station search app with full data. Visit the link https://sacthongminh.com to look up stations or install the Smart Charging app'**
  String get settingsShareAppMessage;

  /// No description provided for @ownerGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'List Your Charging Station on the Map'**
  String get ownerGuideTitle;

  /// No description provided for @ownerGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your interest in contributing to the Smart Charger network. Listing your charging station on our system is completely free and takes only a few minutes.'**
  String get ownerGuideIntro;

  /// No description provided for @ownerGuideStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Prepare Information'**
  String get ownerGuideStep1Title;

  /// No description provided for @ownerGuideStep1Content.
  ///
  /// In en, this message translates to:
  /// **'To ensure a smooth station addition process, please have the following information ready:\n• Exact name of the charging station.\n• Detailed address.\n• Precise location on the map (you will select it by dropping a pin).\n• Number and type of connectors (e.g., CCS2, Type 2...).\n• Power output of each connector type (e.g., 60kW, 120kW...).\n• Operating hours (e.g., 24/7, 8 AM - 10 PM).\n• Pricing details or parking fees (if any).'**
  String get ownerGuideStep1Content;

  /// No description provided for @ownerGuideStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Use the \"Add Station\" Feature'**
  String get ownerGuideStep2Title;

  /// No description provided for @ownerGuideStep2Content.
  ///
  /// In en, this message translates to:
  /// **'• From the main map screen, tap the \"Add Station\" button (plus icon).\n• A small map will appear; move and long-press to \"drop a pin\" at your station\'s exact location, then tap \"Confirm.\"\n• Fill in all the prepared information from Step 1 into the form.\n• Double-check everything and tap \"Submit.\"'**
  String get ownerGuideStep2Content;

  /// No description provided for @ownerGuideStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Await Approval'**
  String get ownerGuideStep3Title;

  /// No description provided for @ownerGuideStep3Content.
  ///
  /// In en, this message translates to:
  /// **'• After you submit the information, our team will proceed with verification.\n• This process may take 1-3 business days.\n• Once approved, your charging station will officially appear on the map for thousands of EV users to see.\n\nThank you for your contribution!'**
  String get ownerGuideStep3Content;

  /// No description provided for @reportSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportSheetTitle;

  /// No description provided for @reportSheetReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason for reporting*'**
  String get reportSheetReasonLabel;

  /// No description provided for @reportSheetReasonValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason'**
  String get reportSheetReasonValidator;

  /// No description provided for @reportSheetDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue details (optional)'**
  String get reportSheetDetailsLabel;

  /// No description provided for @reportSheetDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe more...'**
  String get reportSheetDetailsHint;

  /// No description provided for @reportSheetPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get reportSheetPhoneLabel;

  /// No description provided for @reportSheetSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get reportSheetSubmitButton;

  /// No description provided for @reportReasonStationNotWorking.
  ///
  /// In en, this message translates to:
  /// **'Station not working/No power'**
  String get reportReasonStationNotWorking;

  /// No description provided for @reportReasonConnectorBroken.
  ///
  /// In en, this message translates to:
  /// **'Connector broken/Not charging'**
  String get reportReasonConnectorBroken;

  /// No description provided for @reportReasonInfoIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Information in app is incorrect'**
  String get reportReasonInfoIncorrect;

  /// No description provided for @reportReasonLocationIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Location on map is incorrect'**
  String get reportReasonLocationIncorrect;

  /// No description provided for @reportReasonPaymentIssue.
  ///
  /// In en, this message translates to:
  /// **'Payment issue'**
  String get reportReasonPaymentIssue;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other reason (please describe in details)'**
  String get reportReasonOther;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Comments'**
  String get reviewsTitle;

  /// No description provided for @reviewsImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get reviewsImagesTitle;

  /// No description provided for @reviewsYourReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Review:'**
  String get reviewsYourReviewTitle;

  /// No description provided for @reviewsNewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Write your comment...'**
  String get reviewsNewCommentHint;

  /// No description provided for @reviewsEditCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Edit your comment...'**
  String get reviewsEditCommentHint;

  /// No description provided for @reviewsSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get reviewsSubmitButton;

  /// No description provided for @reviewsUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get reviewsUpdateButton;

  /// No description provided for @reviewsDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get reviewsDeleteButton;

  /// No description provided for @reviewsDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete review?'**
  String get reviewsDeleteDialogTitle;

  /// No description provided for @reviewsDeleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this review?'**
  String get reviewsDeleteDialogContent;

  /// No description provided for @reviewsDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reviewsDialogCancel;

  /// No description provided for @reviewsDialogDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get reviewsDialogDelete;

  /// No description provided for @reviewsRatingValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating.'**
  String get reviewsRatingValidator;

  /// No description provided for @reviewsNoOtherReviews.
  ///
  /// In en, this message translates to:
  /// **'No other reviews yet.'**
  String get reviewsNoOtherReviews;

  /// No description provided for @reviewsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading reviews: {error}'**
  String reviewsLoadError(String error);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get yourLocation;

  /// No description provided for @chooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get chooseOnMap;

  /// No description provided for @chooseStartPoint.
  ///
  /// In en, this message translates to:
  /// **'Choose start point'**
  String get chooseStartPoint;

  /// No description provided for @chooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get chooseDestination;

  /// No description provided for @swapTooltip.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swapTooltip;

  /// No description provided for @reportSendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your report!'**
  String get reportSendSuccess;

  /// No description provided for @userGuideWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Smart Charger!'**
  String get userGuideWelcome;

  /// No description provided for @userGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'The app helps you easily find and navigate to electric vehicle charging stations nationwide. Here is a guide to the main features:'**
  String get userGuideIntro;

  /// No description provided for @userGuideSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Search and Explore'**
  String get userGuideSection1Title;

  /// No description provided for @userGuideSection1Content.
  ///
  /// In en, this message translates to:
  /// **'• Use the search bar at the top to quickly move the map to a specific address or city.\n• Pan and zoom the map to discover charging stations around you. Stations will be automatically loaded and displayed.'**
  String get userGuideSection1Content;

  /// No description provided for @userGuideSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Find Routes and View Details'**
  String get userGuideSection2Title;

  /// No description provided for @userGuideSection2Content.
  ///
  /// In en, this message translates to:
  /// **'• Tap the \"Directions\" button (arrow icon) next to the search bar to open the route planning interface.\n• Choose your start and end points by: using your current location, selecting on the map, or searching for an address.\n• After the route is drawn, tap the \"Find Stations on Route\" button to filter and display only the charging stations along your route.'**
  String get userGuideSection2Content;

  /// No description provided for @userGuideSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. View Station Information'**
  String get userGuideSection3Title;

  /// No description provided for @userGuideSection3Content.
  ///
  /// In en, this message translates to:
  /// **'• Tap a charging station icon on the map to open the detailed information panel.\n• The panel will display full details: address, number of connectors, power, operating hours, and pricing information.'**
  String get userGuideSection3Content;

  /// No description provided for @userGuideSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Navigate to the Station'**
  String get userGuideSection4Title;

  /// No description provided for @userGuideSection4Content.
  ///
  /// In en, this message translates to:
  /// **'• In the detailed information panel, tap the \"Directions\" button. The app will automatically open Google Maps to start navigating you.'**
  String get userGuideSection4Content;

  /// No description provided for @userGuideSection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Report an Issue'**
  String get userGuideSection5Title;

  /// No description provided for @userGuideSection5Content.
  ///
  /// In en, this message translates to:
  /// **'• If the station information is incorrect or you encounter a problem while charging, please tap \"Report an Issue\" in the detailed information panel to help us improve the data.'**
  String get userGuideSection5Content;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
