// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sustainable Living Guide';

  @override
  String get loading => 'Loading';

  @override
  String get foundationDestination => 'Foundation destination';

  @override
  String get onboarding => 'Get started';

  @override
  String get chooseRegion => 'Choose a region';

  @override
  String get regionDemoOnly => 'Demo region (demo only)';

  @override
  String get regionPakistan => 'Pakistan';

  @override
  String displayLanguage(String languageTag) {
    return 'Display language: $languageTag';
  }

  @override
  String get noRegionSelected => 'No region selected';

  @override
  String savedRegionUnavailable(String regionId) {
    return 'The saved region ($regionId) is unavailable. Select a region explicitly.';
  }

  @override
  String get regionSelectionUnavailable =>
      'That region is not available in this app version.';

  @override
  String get regionPreferencesFailure =>
      'Region preferences could not be loaded or saved.';

  @override
  String regionCurrency(String currencyCode) {
    return 'Currency: $currencyCode';
  }

  @override
  String get transportDataUnavailable =>
      'Transport data unavailable — no cited factor is included in this pack.';

  @override
  String get recipeImpactDataUnavailable =>
      'Recipe impact data unavailable — no cited impact factors are included in this pack.';

  @override
  String get onboardingIntro =>
      'Choose a region with available sourced data, or use the clearly labelled demo fixture.';

  @override
  String get assumptionAnnualizedPerPerson =>
      'Annualized per-person activity inputs.';

  @override
  String get annualElectricityUse => 'Annual electricity use (kWh)';

  @override
  String get annualTravel => 'Annual travel (km)';

  @override
  String get calculateDemoEstimate => 'Calculate demo estimate';

  @override
  String get calculateSourcedEstimate => 'Calculate estimate';

  @override
  String get skipAndContinueAsGuest => 'Skip and continue as guest';

  @override
  String get incompleteEstimateAnswers =>
      'Please answer each question to see an estimate.';

  @override
  String get invalidEstimateAnswer =>
      'Enter a valid nonnegative number for each answer.';

  @override
  String get estimateDataUnavailable => 'Demo estimate data is unavailable.';

  @override
  String get sourcedEstimateDataUnavailable =>
      'Sourced estimate data is unavailable.';

  @override
  String get regionalEstimateContext =>
      'This estimate uses only factors available in the selected regional pack. Missing activity data is not estimated.';

  @override
  String get estimateResult => 'Your estimated footprint';

  @override
  String estimateAnnualValue(String value, String unit) {
    return '$value $unit';
  }

  @override
  String get estimateLoadFailure =>
      'The estimate could not be loaded or saved.';

  @override
  String get continueToHome => 'Continue to Home';

  @override
  String get viewEstimate => 'View your saved estimate';

  @override
  String get startupFailure => 'The app could not load local data.';

  @override
  String get demoOnlyWarning => 'DEMO ONLY — not a verified estimate';

  @override
  String get regionalAverage => 'Regional average';

  @override
  String get globalAverage => 'Global average';

  @override
  String get temperatureBudget => '1.5°C-aligned budget';

  @override
  String get factorsUsedInEstimate => 'Factors used in this estimate';

  @override
  String get electricityFactor => 'Electricity';

  @override
  String get transportFactor => 'Transport';

  @override
  String factorApplication(
    String category,
    String rate,
    String numerator,
    String denominator,
  ) {
    return '$category: $rate $numerator per $denominator';
  }

  @override
  String factorSourceDetails(String title, String publisher) {
    return 'Source: $title — $publisher';
  }

  @override
  String factorValidFrom(String date) {
    return 'Factor valid from: $date';
  }

  @override
  String get budgetShareTitle => 'Lifestyle budget share';

  @override
  String get budgetSharePrefix => 'at least';

  @override
  String get budgetShareSuffix => 'of the';

  @override
  String get budgetBenchmarkByYear => 'by';

  @override
  String get budgetShareUnavailable =>
      'A budget share is not shown because this estimate cannot be compared with the cited benchmark.';

  @override
  String get categoryBreakdownTitle => 'Category breakdown';

  @override
  String get estimateCoverageTitle => 'Estimate coverage';

  @override
  String get coverageIncludedTitle => 'Included categories';

  @override
  String get coverageExcludedTitle => 'Not included from available factors';

  @override
  String get coverageNoIncludedCategories =>
      'No included categories are recorded in this estimate.';

  @override
  String get coverageNoExcludedCategories =>
      'No other categories are listed in this estimate\'s available factor data.';

  @override
  String get coverageFactorScopeNote =>
      'This coverage list reflects categories present in the selected estimate factors; it does not infer categories absent from that data.';

  @override
  String get demoOnlyTag => 'DEMO ONLY';

  @override
  String get foodFactor => 'Food';

  @override
  String get wasteFactor => 'Waste';

  @override
  String get otherFactor => 'Other';

  @override
  String get referenceUnavailable => 'Comparison unavailable';

  @override
  String get contextualReferenceOnly =>
      'Contextual reference only — methods, units, periods, or boundaries differ, so no comparison ring is shown.';

  @override
  String referenceMethodology(String methodology) {
    return 'Methodology: $methodology';
  }

  @override
  String get zeroReferenceCannotBeCharted =>
      'A zero reference cannot be shown as a comparison ring.';

  @override
  String estimateComparisonValue(String value, String unit) {
    return 'Your estimate: $value $unit';
  }

  @override
  String referenceComparisonValue(String value, String unit) {
    return 'Reference: $value $unit';
  }

  @override
  String comparisonPeriod(String period) {
    return 'Period: $period';
  }

  @override
  String comparisonSource(String title, String publisher) {
    return 'Source: $title — $publisher';
  }

  @override
  String referenceShare(int percent) {
    return '$percent% of reference';
  }

  @override
  String publicationYear(int year) {
    return 'Publication year: $year';
  }

  @override
  String get account => 'Account';

  @override
  String get accountOptionalGuest =>
      'Account is optional. You can browse as a guest.';

  @override
  String get accountLoginIdentifier => 'Email or username';

  @override
  String get accountPassword => 'Password';

  @override
  String get createLocalAccount => 'Create local account';

  @override
  String get logIn => 'Log in';

  @override
  String get register => 'Register';

  @override
  String get accountPleaseWait => 'Please wait...';

  @override
  String get accountCreatedOnDevice => 'Account created on this device.';

  @override
  String get accountAlreadyExists =>
      'An account with this identifier already exists.';

  @override
  String get accountInvalidCredentials =>
      'Identifier or password is incorrect.';

  @override
  String get accountLoginThrottled =>
      'Too many failed attempts. Try again later.';

  @override
  String get accountInvalidIdentifier => 'Enter a valid email or username.';

  @override
  String get accountInvalidPassword =>
      'Use a password with at least 8 characters.';

  @override
  String accountSignedIn(String identifier) {
    return 'Signed in locally as $identifier.';
  }

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacyPolicyLoadFailure =>
      'The privacy policy could not be loaded.';

  @override
  String get loadingPrivacyPolicy => 'Loading privacy policy...';

  @override
  String get settings => 'Settings';

  @override
  String get privacyControls => 'Privacy and personal data';

  @override
  String get exportMyData => 'Export my data';

  @override
  String get exportDataDescription =>
      'Create a copy of your app data to share or save.';

  @override
  String get deleteLocalData => 'Delete local data';

  @override
  String get deleteDataDescription =>
      'Permanently remove personal data stored by this app.';

  @override
  String get deleteLocalDataConfirmation =>
      'This removes your local account, saved estimates, and preferences from this device. This cannot be undone. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmDeletion => 'Delete my data';

  @override
  String get deletionCancelled =>
      'Deletion cancelled. Your data was not changed.';

  @override
  String get userDataDeleted => 'Local data deleted. Returning to guest Home.';

  @override
  String get userDataDeletionFailure =>
      'Local data could not be fully deleted. Check available storage and try again.';

  @override
  String get userDataExportShared => 'The data export was shared.';

  @override
  String get userDataExportDismissed =>
      'The share sheet was closed. No export was sent.';

  @override
  String get userDataExportUnavailable =>
      'Sharing is unavailable on this device.';

  @override
  String get userDataExportFailure =>
      'The data export could not be prepared or shared.';

  @override
  String get aboutUs => 'About Us';

  @override
  String get imageGallery => 'Image Gallery';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get exploreModules => 'Explore sustainable living';

  @override
  String get moreNavigation => 'More navigation';

  @override
  String get carbonFootprintTracker => 'Carbon Footprint Tracker';

  @override
  String get ecoFriendlyProductSuggestions =>
      'Eco-Friendly Product Suggestions';

  @override
  String get sustainableLivingChallenges => 'Sustainable Living Challenges';

  @override
  String get certificationsGuide => 'Green Certifications & Labels Guide';

  @override
  String get wasteReductionTracker => 'Waste Reduction Tracker';

  @override
  String get recipesMealPlanning => 'Sustainable Recipes & Meal Planning';

  @override
  String get energyConservationTips => 'Energy Conservation Tips';

  @override
  String get ecoTravelSuggestions => 'Eco-Travel Suggestions';

  @override
  String get communityJournal => 'Community Journal';

  @override
  String get progressDashboard => 'Sustainability Progress Dashboard';

  @override
  String get educationalContent => 'Educational Content';

  @override
  String get moduleDetailsComingSoon =>
      'Detailed features will be available in a future update.';

  @override
  String get aboutDescription =>
      'Sustainable Living Guide helps people explore practical sustainability topics. This foundation version provides offline navigation to each module.';

  @override
  String get galleryEmpty => 'No gallery images are available yet.';

  @override
  String get contactUnavailable =>
      'Contact information is not available in this foundation version.';
}
