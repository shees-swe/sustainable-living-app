import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application title shown in app metadata.
  ///
  /// In en, this message translates to:
  /// **'Sustainable Living Guide'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @foundationDestination.
  ///
  /// In en, this message translates to:
  /// **'Foundation destination'**
  String get foundationDestination;

  /// No description provided for @onboarding.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboarding;

  /// No description provided for @chooseRegion.
  ///
  /// In en, this message translates to:
  /// **'Choose a region'**
  String get chooseRegion;

  /// No description provided for @regionDemoOnly.
  ///
  /// In en, this message translates to:
  /// **'Demo region (demo only)'**
  String get regionDemoOnly;

  /// No description provided for @regionPakistan.
  ///
  /// In en, this message translates to:
  /// **'Pakistan'**
  String get regionPakistan;

  /// No description provided for @displayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Display language: {languageTag}'**
  String displayLanguage(String languageTag);

  /// No description provided for @noRegionSelected.
  ///
  /// In en, this message translates to:
  /// **'No region selected'**
  String get noRegionSelected;

  /// No description provided for @savedRegionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The saved region ({regionId}) is unavailable. Select a region explicitly.'**
  String savedRegionUnavailable(String regionId);

  /// No description provided for @regionSelectionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'That region is not available in this app version.'**
  String get regionSelectionUnavailable;

  /// No description provided for @regionPreferencesFailure.
  ///
  /// In en, this message translates to:
  /// **'Region preferences could not be loaded or saved.'**
  String get regionPreferencesFailure;

  /// No description provided for @regionCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency: {currencyCode}'**
  String regionCurrency(String currencyCode);

  /// No description provided for @transportDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Transport data unavailable — no cited factor is included in this pack.'**
  String get transportDataUnavailable;

  /// No description provided for @recipeImpactDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Recipe impact data unavailable — no cited impact factors are included in this pack.'**
  String get recipeImpactDataUnavailable;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a region with available sourced data, or use the clearly labelled demo fixture.'**
  String get onboardingIntro;

  /// No description provided for @assumptionAnnualizedPerPerson.
  ///
  /// In en, this message translates to:
  /// **'Annualized per-person activity inputs.'**
  String get assumptionAnnualizedPerPerson;

  /// No description provided for @annualElectricityUse.
  ///
  /// In en, this message translates to:
  /// **'Annual electricity use (kWh)'**
  String get annualElectricityUse;

  /// No description provided for @annualTravel.
  ///
  /// In en, this message translates to:
  /// **'Annual travel (km)'**
  String get annualTravel;

  /// No description provided for @calculateDemoEstimate.
  ///
  /// In en, this message translates to:
  /// **'Calculate demo estimate'**
  String get calculateDemoEstimate;

  /// No description provided for @calculateSourcedEstimate.
  ///
  /// In en, this message translates to:
  /// **'Calculate estimate'**
  String get calculateSourcedEstimate;

  /// No description provided for @skipAndContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Skip and continue as guest'**
  String get skipAndContinueAsGuest;

  /// No description provided for @incompleteEstimateAnswers.
  ///
  /// In en, this message translates to:
  /// **'Please answer each question to see an estimate.'**
  String get incompleteEstimateAnswers;

  /// No description provided for @invalidEstimateAnswer.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid nonnegative number for each answer.'**
  String get invalidEstimateAnswer;

  /// No description provided for @estimateDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Demo estimate data is unavailable.'**
  String get estimateDataUnavailable;

  /// No description provided for @sourcedEstimateDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sourced estimate data is unavailable.'**
  String get sourcedEstimateDataUnavailable;

  /// No description provided for @regionalEstimateContext.
  ///
  /// In en, this message translates to:
  /// **'This estimate uses only factors available in the selected regional pack. Missing activity data is not estimated.'**
  String get regionalEstimateContext;

  /// No description provided for @estimateResult.
  ///
  /// In en, this message translates to:
  /// **'Your estimated footprint'**
  String get estimateResult;

  /// No description provided for @estimateAnnualValue.
  ///
  /// In en, this message translates to:
  /// **'{value} {unit}'**
  String estimateAnnualValue(String value, String unit);

  /// No description provided for @estimateLoadFailure.
  ///
  /// In en, this message translates to:
  /// **'The estimate could not be loaded or saved.'**
  String get estimateLoadFailure;

  /// No description provided for @continueToHome.
  ///
  /// In en, this message translates to:
  /// **'Continue to Home'**
  String get continueToHome;

  /// No description provided for @viewEstimate.
  ///
  /// In en, this message translates to:
  /// **'View your saved estimate'**
  String get viewEstimate;

  /// No description provided for @startupFailure.
  ///
  /// In en, this message translates to:
  /// **'The app could not load local data.'**
  String get startupFailure;

  /// No description provided for @demoOnlyWarning.
  ///
  /// In en, this message translates to:
  /// **'DEMO ONLY — not a verified estimate'**
  String get demoOnlyWarning;

  /// No description provided for @regionalAverage.
  ///
  /// In en, this message translates to:
  /// **'Regional average'**
  String get regionalAverage;

  /// No description provided for @globalAverage.
  ///
  /// In en, this message translates to:
  /// **'Global average'**
  String get globalAverage;

  /// No description provided for @temperatureBudget.
  ///
  /// In en, this message translates to:
  /// **'1.5°C-aligned budget'**
  String get temperatureBudget;

  /// No description provided for @factorsUsedInEstimate.
  ///
  /// In en, this message translates to:
  /// **'Factors used in this estimate'**
  String get factorsUsedInEstimate;

  /// No description provided for @electricityFactor.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricityFactor;

  /// No description provided for @transportFactor.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transportFactor;

  /// No description provided for @factorApplication.
  ///
  /// In en, this message translates to:
  /// **'{category}: {rate} {numerator} per {denominator}'**
  String factorApplication(
    String category,
    String rate,
    String numerator,
    String denominator,
  );

  /// No description provided for @factorSourceDetails.
  ///
  /// In en, this message translates to:
  /// **'Source: {title} — {publisher}'**
  String factorSourceDetails(String title, String publisher);

  /// No description provided for @factorValidFrom.
  ///
  /// In en, this message translates to:
  /// **'Factor valid from: {date}'**
  String factorValidFrom(String date);

  /// No description provided for @budgetShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle budget share'**
  String get budgetShareTitle;

  /// No description provided for @budgetSharePrefix.
  ///
  /// In en, this message translates to:
  /// **'at least'**
  String get budgetSharePrefix;

  /// No description provided for @budgetShareSuffix.
  ///
  /// In en, this message translates to:
  /// **'of the'**
  String get budgetShareSuffix;

  /// No description provided for @budgetBenchmarkByYear.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get budgetBenchmarkByYear;

  /// No description provided for @budgetShareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'A budget share is not shown because this estimate cannot be compared with the cited benchmark.'**
  String get budgetShareUnavailable;

  /// No description provided for @categoryBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Category breakdown'**
  String get categoryBreakdownTitle;

  /// No description provided for @estimateCoverageTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimate coverage'**
  String get estimateCoverageTitle;

  /// No description provided for @coverageIncludedTitle.
  ///
  /// In en, this message translates to:
  /// **'Included categories'**
  String get coverageIncludedTitle;

  /// No description provided for @coverageExcludedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not included from available factors'**
  String get coverageExcludedTitle;

  /// No description provided for @coverageNoIncludedCategories.
  ///
  /// In en, this message translates to:
  /// **'No included categories are recorded in this estimate.'**
  String get coverageNoIncludedCategories;

  /// No description provided for @coverageNoExcludedCategories.
  ///
  /// In en, this message translates to:
  /// **'No other categories are listed in this estimate\'s available factor data.'**
  String get coverageNoExcludedCategories;

  /// No description provided for @coverageFactorScopeNote.
  ///
  /// In en, this message translates to:
  /// **'This coverage list reflects categories present in the selected estimate factors; it does not infer categories absent from that data.'**
  String get coverageFactorScopeNote;

  /// No description provided for @demoOnlyTag.
  ///
  /// In en, this message translates to:
  /// **'DEMO ONLY'**
  String get demoOnlyTag;

  /// No description provided for @foodFactor.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get foodFactor;

  /// No description provided for @wasteFactor.
  ///
  /// In en, this message translates to:
  /// **'Waste'**
  String get wasteFactor;

  /// No description provided for @otherFactor.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherFactor;

  /// No description provided for @referenceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Comparison unavailable'**
  String get referenceUnavailable;

  /// No description provided for @contextualReferenceOnly.
  ///
  /// In en, this message translates to:
  /// **'Contextual reference only — methods, units, periods, or boundaries differ, so no comparison ring is shown.'**
  String get contextualReferenceOnly;

  /// No description provided for @referenceMethodology.
  ///
  /// In en, this message translates to:
  /// **'Methodology: {methodology}'**
  String referenceMethodology(String methodology);

  /// No description provided for @zeroReferenceCannotBeCharted.
  ///
  /// In en, this message translates to:
  /// **'A zero reference cannot be shown as a comparison ring.'**
  String get zeroReferenceCannotBeCharted;

  /// No description provided for @estimateComparisonValue.
  ///
  /// In en, this message translates to:
  /// **'Your estimate: {value} {unit}'**
  String estimateComparisonValue(String value, String unit);

  /// No description provided for @referenceComparisonValue.
  ///
  /// In en, this message translates to:
  /// **'Reference: {value} {unit}'**
  String referenceComparisonValue(String value, String unit);

  /// No description provided for @comparisonPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period: {period}'**
  String comparisonPeriod(String period);

  /// No description provided for @comparisonSource.
  ///
  /// In en, this message translates to:
  /// **'Source: {title} — {publisher}'**
  String comparisonSource(String title, String publisher);

  /// No description provided for @referenceShare.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of reference'**
  String referenceShare(int percent);

  /// Publication year of an estimate factor source.
  ///
  /// In en, this message translates to:
  /// **'Publication year: {year}'**
  String publicationYear(int year);

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountOptionalGuest.
  ///
  /// In en, this message translates to:
  /// **'Account is optional. You can browse as a guest.'**
  String get accountOptionalGuest;

  /// No description provided for @accountLoginIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get accountLoginIdentifier;

  /// No description provided for @accountPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPassword;

  /// No description provided for @createLocalAccount.
  ///
  /// In en, this message translates to:
  /// **'Create local account'**
  String get createLocalAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @accountPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get accountPleaseWait;

  /// No description provided for @accountCreatedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Account created on this device.'**
  String get accountCreatedOnDevice;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this identifier already exists.'**
  String get accountAlreadyExists;

  /// No description provided for @accountInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Identifier or password is incorrect.'**
  String get accountInvalidCredentials;

  /// No description provided for @accountLoginThrottled.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Try again later.'**
  String get accountLoginThrottled;

  /// No description provided for @accountInvalidIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email or username.'**
  String get accountInvalidIdentifier;

  /// No description provided for @accountInvalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Use a password with at least 8 characters.'**
  String get accountInvalidPassword;

  /// No description provided for @accountSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in locally as {identifier}.'**
  String accountSignedIn(String identifier);

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyLoadFailure.
  ///
  /// In en, this message translates to:
  /// **'The privacy policy could not be loaded.'**
  String get privacyPolicyLoadFailure;

  /// No description provided for @loadingPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Loading privacy policy...'**
  String get loadingPrivacyPolicy;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @privacyControls.
  ///
  /// In en, this message translates to:
  /// **'Privacy and personal data'**
  String get privacyControls;

  /// No description provided for @exportMyData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportMyData;

  /// No description provided for @exportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a copy of your app data to share or save.'**
  String get exportDataDescription;

  /// No description provided for @deleteLocalData.
  ///
  /// In en, this message translates to:
  /// **'Delete local data'**
  String get deleteLocalData;

  /// No description provided for @deleteDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove personal data stored by this app.'**
  String get deleteDataDescription;

  /// No description provided for @deleteLocalDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This removes your local account, saved estimates, activity logs, and preferences from this device. This cannot be undone. Continue?'**
  String get deleteLocalDataConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Delete my data'**
  String get confirmDeletion;

  /// No description provided for @deletionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Deletion cancelled. Your data was not changed.'**
  String get deletionCancelled;

  /// No description provided for @userDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Local data deleted. Returning to guest Home.'**
  String get userDataDeleted;

  /// No description provided for @userDataDeletionFailure.
  ///
  /// In en, this message translates to:
  /// **'Local data could not be fully deleted. Check available storage and try again.'**
  String get userDataDeletionFailure;

  /// No description provided for @userDataExportShared.
  ///
  /// In en, this message translates to:
  /// **'The data export was shared.'**
  String get userDataExportShared;

  /// No description provided for @userDataExportDismissed.
  ///
  /// In en, this message translates to:
  /// **'The share sheet was closed. No export was sent.'**
  String get userDataExportDismissed;

  /// No description provided for @userDataExportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sharing is unavailable on this device.'**
  String get userDataExportUnavailable;

  /// No description provided for @userDataExportFailure.
  ///
  /// In en, this message translates to:
  /// **'The data export could not be prepared or shared.'**
  String get userDataExportFailure;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @imageGallery.
  ///
  /// In en, this message translates to:
  /// **'Image Gallery'**
  String get imageGallery;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @exploreModules.
  ///
  /// In en, this message translates to:
  /// **'Explore sustainable living'**
  String get exploreModules;

  /// No description provided for @moreNavigation.
  ///
  /// In en, this message translates to:
  /// **'More navigation'**
  String get moreNavigation;

  /// No description provided for @carbonFootprintTracker.
  ///
  /// In en, this message translates to:
  /// **'Carbon Footprint Tracker'**
  String get carbonFootprintTracker;

  /// No description provided for @trackerPeriodTotal.
  ///
  /// In en, this message translates to:
  /// **'{year} total'**
  String trackerPeriodTotal(int year);

  /// No description provided for @trackerCoverage.
  ///
  /// In en, this message translates to:
  /// **'Includes logged electricity only. Transport, food, and other activities are not included yet.'**
  String get trackerCoverage;

  /// No description provided for @trackerViewInsights.
  ///
  /// In en, this message translates to:
  /// **'View insights'**
  String get trackerViewInsights;

  /// No description provided for @trackerInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get trackerInsights;

  /// No description provided for @trackerInsightsCoverage.
  ///
  /// In en, this message translates to:
  /// **'These insights include logged electricity only. Transport, food, and other activities are not included yet.'**
  String get trackerInsightsCoverage;

  /// No description provided for @trackerInsightsYear.
  ///
  /// In en, this message translates to:
  /// **'{year} insights total'**
  String trackerInsightsYear(int year);

  /// No description provided for @trackerMonthlyTotals.
  ///
  /// In en, this message translates to:
  /// **'Monthly totals'**
  String get trackerMonthlyTotals;

  /// No description provided for @trackerShareOfYear.
  ///
  /// In en, this message translates to:
  /// **'{value}% of year'**
  String trackerShareOfYear(String value);

  /// No description provided for @trackerShareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Share unavailable when total is zero.'**
  String get trackerShareUnavailable;

  /// No description provided for @trackerHighestMonth.
  ///
  /// In en, this message translates to:
  /// **'Highest month: {month} — {value} kg CO2'**
  String trackerHighestMonth(String month, String value);

  /// No description provided for @trackerLargestContributions.
  ///
  /// In en, this message translates to:
  /// **'Largest contributions'**
  String get trackerLargestContributions;

  /// No description provided for @trackerNoActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities logged for this period yet.'**
  String get trackerNoActivities;

  /// No description provided for @trackerAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add activity'**
  String get trackerAddEntry;

  /// No description provided for @trackerElectricity.
  ///
  /// In en, this message translates to:
  /// **'Home energy — electricity'**
  String get trackerElectricity;

  /// No description provided for @trackerElectricityUnit.
  ///
  /// In en, this message translates to:
  /// **'Enter electricity use in kWh.'**
  String get trackerElectricityUnit;

  /// No description provided for @trackerTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get trackerTransport;

  /// No description provided for @trackerFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get trackerFood;

  /// No description provided for @trackerFactorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Factor not available yet.'**
  String get trackerFactorUnavailable;

  /// No description provided for @trackerSelectedRegionFactorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No cited electricity factor is available for the selected region.'**
  String get trackerSelectedRegionFactorUnavailable;

  /// No description provided for @trackerAddElectricity.
  ///
  /// In en, this message translates to:
  /// **'Add electricity'**
  String get trackerAddElectricity;

  /// No description provided for @trackerDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get trackerDateLabel;

  /// No description provided for @trackerAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get trackerAmountLabel;

  /// No description provided for @trackerInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a finite, nonnegative amount.'**
  String get trackerInvalidAmount;

  /// No description provided for @trackerSaveEntry.
  ///
  /// In en, this message translates to:
  /// **'Save activity'**
  String get trackerSaveEntry;

  /// No description provided for @trackerDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete activity'**
  String get trackerDeleteEntry;

  /// No description provided for @trackerLoadFailure.
  ///
  /// In en, this message translates to:
  /// **'Activities could not be loaded.'**
  String get trackerLoadFailure;

  /// No description provided for @trackerSaveFailure.
  ///
  /// In en, this message translates to:
  /// **'The activity could not be saved.'**
  String get trackerSaveFailure;

  /// No description provided for @trackerDeleteFailure.
  ///
  /// In en, this message translates to:
  /// **'The activity could not be deleted.'**
  String get trackerDeleteFailure;

  /// No description provided for @ecoFriendlyProductSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Eco-Friendly Product Suggestions'**
  String get ecoFriendlyProductSuggestions;

  /// No description provided for @sustainableLivingChallenges.
  ///
  /// In en, this message translates to:
  /// **'Sustainable Living Challenges'**
  String get sustainableLivingChallenges;

  /// No description provided for @certificationsGuide.
  ///
  /// In en, this message translates to:
  /// **'Green Certifications & Labels Guide'**
  String get certificationsGuide;

  /// No description provided for @wasteReductionTracker.
  ///
  /// In en, this message translates to:
  /// **'Waste Reduction Tracker'**
  String get wasteReductionTracker;

  /// No description provided for @recipesMealPlanning.
  ///
  /// In en, this message translates to:
  /// **'Sustainable Recipes & Meal Planning'**
  String get recipesMealPlanning;

  /// No description provided for @energyConservationTips.
  ///
  /// In en, this message translates to:
  /// **'Energy Conservation Tips'**
  String get energyConservationTips;

  /// No description provided for @ecoTravelSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Eco-Travel Suggestions'**
  String get ecoTravelSuggestions;

  /// No description provided for @communityJournal.
  ///
  /// In en, this message translates to:
  /// **'Community Journal'**
  String get communityJournal;

  /// No description provided for @progressDashboard.
  ///
  /// In en, this message translates to:
  /// **'Sustainability Progress Dashboard'**
  String get progressDashboard;

  /// No description provided for @educationalContent.
  ///
  /// In en, this message translates to:
  /// **'Educational Content'**
  String get educationalContent;

  /// No description provided for @moduleDetailsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Detailed features will be available in a future update.'**
  String get moduleDetailsComingSoon;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sustainable Living Guide helps people explore practical sustainability topics. This foundation version provides offline navigation to each module.'**
  String get aboutDescription;

  /// No description provided for @galleryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No gallery images are available yet.'**
  String get galleryEmpty;

  /// No description provided for @contactUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Contact information is not available in this foundation version.'**
  String get contactUnavailable;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
