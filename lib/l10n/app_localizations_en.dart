// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Smart Charger';

  @override
  String get navMap => 'Map';

  @override
  String get navStationList => 'List';

  @override
  String get navAddStation => 'Add';

  @override
  String get navSettings => 'Settings';

  @override
  String get searchPlaceholder => 'Find charging stations by address...';

  @override
  String get directionsTooltip => 'Directions';

  @override
  String get directionsTitle => 'Directions ';

  @override
  String get directionsButton => 'Directions';

  @override
  String get cannotOpenMaps => 'Could not open Google Maps.';

  @override
  String stationCardDistance(String distance) {
    return '$distance km';
  }

  @override
  String get sheetStationName => 'Station Name';

  @override
  String get sheetAddress => 'Address';

  @override
  String get sheetStatusLabel => 'Status';

  @override
  String get sheetConnectorsLabel => 'Connectors';

  @override
  String get sheetOperatingHoursLabel => 'Operating Hours';

  @override
  String get sheetParkingDetailsLabel => 'Parking Details';

  @override
  String get sheetReportProblemTooltip => 'Report an issue';

  @override
  String get sheetConnectorDetailsTitle => 'Connector Details:';

  @override
  String get sheetConnectorTotalTitle => 'Total Connectors:';

  @override
  String sheetConnectorInfo(String count) {
    return '$count ports';
  }

  @override
  String sheetConnectorPowerInfo(String count, String power) {
    return '$count x ${power}kW ports';
  }

  @override
  String get noInfo => 'Not available';

  @override
  String get addStationScreenTitle => 'Add New Station';

  @override
  String get addStationMapLocation => 'Location on Map *';

  @override
  String get addStationMapHint =>
      'Tap to place a pin or drag the pin for the exact location.';

  @override
  String get addStationNameLabel => 'Station Name *';

  @override
  String get addStationNameValidator => 'Please enter a name';

  @override
  String get addStationAddressLabel => 'Address *';

  @override
  String get addStationAddressHint => 'Start typing to search...';

  @override
  String get addStationAddressValidator => 'Please enter an address';

  @override
  String get addStationNoAddressFound => 'No places found.';

  @override
  String get addStationConnectorType => 'Connector Types';

  @override
  String get addStationPower => 'Power (kW)';

  @override
  String get addStationOperatingHoursHint => 'Operating hours (e.g., 24/7)';

  @override
  String get addStationPricingDetailsHint => 'Pricing details';

  @override
  String get addStationNetworkOperatorHint => 'Network operator';

  @override
  String get addStationAdminInfo => 'Information for Admin';

  @override
  String get addStationOwnerNameLabel => 'Owner Name *';

  @override
  String get addStationOwnerNameValidator => 'Please enter owner\'s name';

  @override
  String get addStationOwnerPhoneLabel => 'Owner Phone Number *';

  @override
  String get addStationOwnerPhoneValidator => 'Please enter phone number';

  @override
  String get addStationImages => 'Station Images (optional)';

  @override
  String get addStationTypeTitle => 'Station Type *';

  @override
  String get stationTypeCar => 'Car';

  @override
  String get stationTypeBike => 'Motorbike';

  @override
  String get addStationSubmitButton => 'Submit';

  @override
  String addStationSuccessMessage(String stationName) {
    return '\"$stationName\" has been added and is pending review.';
  }

  @override
  String get addStationMapPinValidator =>
      'Please select a location on the map.';

  @override
  String get addStationMaxImages => 'You can only select up to 4 images.';

  @override
  String get stationListPageTitle => 'Station List';

  @override
  String get stationListPageSearchHint => 'Search by location...';

  @override
  String stationListError(String error) {
    return 'Error: $error';
  }

  @override
  String get stationListEmpty => 'No charging stations found.';

  @override
  String get settingsPageTitle => 'Settings & Info';

  @override
  String get settingsPartnership => 'Partnership Introduction';

  @override
  String get settingsUserGuide => 'User Guide';

  @override
  String get settingsOwnerGuide => 'Station Owner Guide';

  @override
  String get settingsShareApp => 'Share App';

  @override
  String get settingsShareAppMessage =>
      'This is a nationwide charging station search app with full data. Visit the link https://sacthongminh.com to look up stations or install the Smart Charging app';

  @override
  String get ownerGuideTitle => 'List Your Charging Station on the Map';

  @override
  String get ownerGuideIntro =>
      'Thank you for your interest in contributing to the Smart Charger network. Listing your charging station on our system is completely free and takes only a few minutes.';

  @override
  String get ownerGuideStep1Title => 'Step 1: Prepare Information';

  @override
  String get ownerGuideStep1Content =>
      'To ensure a smooth station addition process, please have the following information ready:\n• Exact name of the charging station.\n• Detailed address.\n• Precise location on the map (you will select it by dropping a pin).\n• Number and type of connectors (e.g., CCS2, Type 2...).\n• Power output of each connector type (e.g., 60kW, 120kW...).\n• Operating hours (e.g., 24/7, 8 AM - 10 PM).\n• Pricing details or parking fees (if any).';

  @override
  String get ownerGuideStep2Title => 'Step 2: Use the \"Add Station\" Feature';

  @override
  String get ownerGuideStep2Content =>
      '• From the main map screen, tap the \"Add Station\" button (plus icon).\n• A small map will appear; move and long-press to \"drop a pin\" at your station\'s exact location, then tap \"Confirm.\"\n• Fill in all the prepared information from Step 1 into the form.\n• Double-check everything and tap \"Submit.\"';

  @override
  String get ownerGuideStep3Title => 'Step 3: Await Approval';

  @override
  String get ownerGuideStep3Content =>
      '• After you submit the information, our team will proceed with verification.\n• This process may take 1-3 business days.\n• Once approved, your charging station will officially appear on the map for thousands of EV users to see.\n\nThank you for your contribution!';

  @override
  String get reportSheetTitle => 'Report an Issue';

  @override
  String get reportSheetReasonLabel => 'Reason for reporting*';

  @override
  String get reportSheetReasonValidator => 'Please select a reason';

  @override
  String get reportSheetDetailsLabel => 'Issue details (optional)';

  @override
  String get reportSheetDetailsHint => 'Describe more...';

  @override
  String get reportSheetPhoneLabel => 'Phone number (optional)';

  @override
  String get reportSheetSubmitButton => 'Send Report';

  @override
  String get reportReasonStationNotWorking => 'Station not working/No power';

  @override
  String get reportReasonConnectorBroken => 'Connector broken/Not charging';

  @override
  String get reportReasonInfoIncorrect => 'Information in app is incorrect';

  @override
  String get reportReasonLocationIncorrect => 'Location on map is incorrect';

  @override
  String get reportReasonPaymentIssue => 'Payment issue';

  @override
  String get reportReasonOther => 'Other reason (please describe in details)';

  @override
  String get reviewsTitle => 'Reviews & Comments';

  @override
  String get reviewsImagesTitle => 'Images';

  @override
  String get reviewsYourReviewTitle => 'Your Review:';

  @override
  String get reviewsNewCommentHint => 'Write your comment...';

  @override
  String get reviewsEditCommentHint => 'Edit your comment...';

  @override
  String get reviewsSubmitButton => 'Submit Review';

  @override
  String get reviewsUpdateButton => 'Update';

  @override
  String get reviewsDeleteButton => 'Delete';

  @override
  String get reviewsDeleteDialogTitle => 'Delete review?';

  @override
  String get reviewsDeleteDialogContent =>
      'Are you sure you want to delete this review?';

  @override
  String get reviewsDialogCancel => 'Cancel';

  @override
  String get reviewsDialogDelete => 'Delete';

  @override
  String get reviewsRatingValidator => 'Please select a rating.';

  @override
  String get reviewsNoOtherReviews => 'No other reviews yet.';

  @override
  String reviewsLoadError(String error) {
    return 'Error loading reviews: $error';
  }

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get yourLocation => 'Your location';

  @override
  String get chooseOnMap => 'Choose on map';

  @override
  String get chooseStartPoint => 'Choose start point';

  @override
  String get chooseDestination => 'Choose destination';

  @override
  String get swapTooltip => 'Swap';

  @override
  String get reportSendSuccess => 'Thank you for your report!';

  @override
  String get userGuideWelcome => 'Welcome to Smart Charger!';

  @override
  String get userGuideIntro =>
      'The app helps you easily find and navigate to electric vehicle charging stations nationwide. Here is a guide to the main features:';

  @override
  String get userGuideSection1Title => '1. Search and Explore';

  @override
  String get userGuideSection1Content =>
      '• Use the search bar at the top to quickly move the map to a specific address or city.\n• Pan and zoom the map to discover charging stations around you. Stations will be automatically loaded and displayed.';

  @override
  String get userGuideSection2Title => '2. Find Routes and View Details';

  @override
  String get userGuideSection2Content =>
      '• Tap the \"Directions\" button (arrow icon) next to the search bar to open the route planning interface.\n• Choose your start and end points by: using your current location, selecting on the map, or searching for an address.\n• After the route is drawn, tap the \"Find Stations on Route\" button to filter and display only the charging stations along your route.';

  @override
  String get userGuideSection3Title => '3. View Station Information';

  @override
  String get userGuideSection3Content =>
      '• Tap a charging station icon on the map to open the detailed information panel.\n• The panel will display full details: address, number of connectors, power, operating hours, and pricing information.';

  @override
  String get userGuideSection4Title => '4. Navigate to the Station';

  @override
  String get userGuideSection4Content =>
      '• In the detailed information panel, tap the \"Directions\" button. The app will automatically open Google Maps to start navigating you.';

  @override
  String get userGuideSection5Title => '5. Report an Issue';

  @override
  String get userGuideSection5Content =>
      '• If the station information is incorrect or you encounter a problem while charging, please tap \"Report an Issue\" in the detailed information panel to help us improve the data.';
}
