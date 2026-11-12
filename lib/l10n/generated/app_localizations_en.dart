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
      'This removes your local account, saved estimates, activity logs, and preferences from this device. This cannot be undone. Continue?';

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
  String trackerPeriodTotal(int year) {
    return '$year total';
  }

  @override
  String get trackerCoverage =>
      'Includes logged electricity only. Transport, food, and other activities are not included yet.';

  @override
  String get trackerViewInsights => 'View insights';

  @override
  String get trackerViewRecommendations => 'View recommendations';

  @override
  String get trackerInsights => 'Insights';

  @override
  String get trackerRecommendations => 'Recommendations';

  @override
  String get trackerInsightsCoverage =>
      'These insights include logged electricity only. Transport, food, and other activities are not included yet.';

  @override
  String get trackerRecommendationsCoverage =>
      'These recommendations use your logged electricity only. They are scenarios based on your entries, not promises.';

  @override
  String get trackerRecommendationScenarioLabel => 'Scenario — not a promise';

  @override
  String trackerRecommendationPeakMonth(String month) {
    return 'Peak month: $month';
  }

  @override
  String get trackerRecommendationCutPrefix => 'A ';

  @override
  String trackerRecommendationCutSuffix(String month) {
    return '% cut in $month would have saved';
  }

  @override
  String get trackerRecommendationAverageMonth =>
      'Average across months with entries';

  @override
  String trackerRecommendationLowestMonth(String month) {
    return 'Lowest month: $month';
  }

  @override
  String get trackerRecommendationMonthlyGap =>
      'Gap from average to lowest month';

  @override
  String get trackerRecommendationBudgetPrefix => 'At least ';

  @override
  String get trackerRecommendationBudgetMiddle => '% of the ';

  @override
  String get trackerRecommendationBudgetSuffix =>
      ' t CO2e/person/year budget by ';

  @override
  String get trackerRecommendationBudgetEnd => ' — from electricity alone.';

  @override
  String trackerInsightsYear(int year) {
    return '$year insights total';
  }

  @override
  String get trackerMonthlyTotals => 'Monthly totals';

  @override
  String trackerShareOfYear(String value) {
    return '$value% of year';
  }

  @override
  String get trackerShareUnavailable => 'Share unavailable when total is zero.';

  @override
  String trackerHighestMonth(String month, String value) {
    return 'Highest month: $month — $value kg CO2';
  }

  @override
  String get trackerLargestContributions => 'Largest contributions';

  @override
  String get trackerNoActivities => 'No activities logged for this period yet.';

  @override
  String get trackerAddEntry => 'Add activity';

  @override
  String get trackerElectricity => 'Home energy — electricity';

  @override
  String get trackerElectricityUnit => 'Enter electricity use in kWh.';

  @override
  String get trackerTransport => 'Transport';

  @override
  String get trackerFood => 'Food';

  @override
  String get trackerFactorUnavailable => 'Factor not available yet.';

  @override
  String get trackerSelectedRegionFactorUnavailable =>
      'No cited electricity factor is available for the selected region.';

  @override
  String get trackerAddElectricity => 'Add electricity';

  @override
  String get trackerDateLabel => 'Date';

  @override
  String get trackerAmountLabel => 'Amount';

  @override
  String get trackerInvalidAmount => 'Enter a finite, nonnegative amount.';

  @override
  String get trackerSaveEntry => 'Save activity';

  @override
  String get trackerDeleteEntry => 'Delete activity';

  @override
  String get trackerLoadFailure => 'Activities could not be loaded.';

  @override
  String get trackerSaveFailure => 'The activity could not be saved.';

  @override
  String get trackerDeleteFailure => 'The activity could not be deleted.';

  @override
  String get ecoFriendlyProductSuggestions =>
      'Eco-Friendly Product Suggestions';

  @override
  String get productSearchLabel => 'Search by name or note';

  @override
  String get productClearSearch => 'Clear search';

  @override
  String get productCategoryFilter => 'Category';

  @override
  String get productAllCategories => 'All categories';

  @override
  String get productSortLabel => 'Sort by name';

  @override
  String get productSortAscending => 'A–Z';

  @override
  String get productSortDescending => 'Z–A';

  @override
  String get productNoMatches =>
      'No products match your current search and category.';

  @override
  String get productClearFilters => 'Clear search and filters';

  @override
  String get productDetail => 'Product details';

  @override
  String get productNoteLabel => 'Note';

  @override
  String get productCatalogLoadFailure =>
      'Product suggestions could not be loaded.';

  @override
  String get challengeProgressLoadFailure =>
      'Challenge progress could not be loaded.';

  @override
  String get challengeProgressSaveFailure =>
      'Challenge progress could not be saved.';

  @override
  String get challengeThemeLabel => 'Theme';

  @override
  String get challengeDurationLabel => 'Duration';

  @override
  String get challengeStart => 'Start challenge';

  @override
  String get challengeReset => 'Reset challenge';

  @override
  String get challengeCompleted => 'Completed';

  @override
  String challengeProgressSemanticsLabel(int completed, int total) {
    return '$completed of $total days completed';
  }

  @override
  String challengeDayLabel(int day) {
    return 'Day $day';
  }

  @override
  String get sustainableLivingChallenges => 'Sustainable Living Challenges';

  @override
  String get certificationsGuide => 'Green Certifications & Labels Guide';

  @override
  String get certificationsSection => 'Certifications';

  @override
  String get certificationDisclaimer =>
      'Certifications are awarded by independent bodies; this app does not certify any brand.';

  @override
  String get certificationSearchLabel => 'Search by name or meaning';

  @override
  String get certificationClearSearch => 'Clear search';

  @override
  String get certificationCategoryFilter => 'Category';

  @override
  String get certificationAllCategories => 'All categories';

  @override
  String get certificationNoMatches =>
      'No certifications match your current search and category.';

  @override
  String get certificationClearFilters => 'Clear search and category filter';

  @override
  String get certificationDetail => 'Certification details';

  @override
  String get certificationMeaningLabel => 'Meaning';

  @override
  String get certificationWhereSeenLabel => 'Where you may see it';

  @override
  String get checkBrandSection => 'Check a brand';

  @override
  String get wasteReductionTracker => 'Waste Reduction Tracker';

  @override
  String get wasteEstimateNote => 'These waste amounts are your own estimates.';

  @override
  String get wasteMonthSummary => 'Current month summary';

  @override
  String get wasteMonthTotal => 'Month total';

  @override
  String get wasteMonthEmpty => 'No waste logged this month yet.';

  @override
  String get wasteLogSection => 'Waste log';

  @override
  String get wasteNoEntries => 'No waste logged yet.';

  @override
  String get wasteAddEntry => 'Add waste entry';

  @override
  String get wasteDeleteEntry => 'Delete waste entry';

  @override
  String get wasteDateLabel => 'Date';

  @override
  String get wasteCategoryLabel => 'Category';

  @override
  String get wasteAmountLabel => 'Amount';

  @override
  String get wasteSaveEntry => 'Save entry';

  @override
  String get wasteInvalidAmount => 'Enter a finite amount greater than zero.';

  @override
  String get wasteLoadFailure => 'Waste entries could not be loaded.';

  @override
  String get wasteSaveFailure => 'The waste entry could not be saved.';

  @override
  String get wasteDeleteFailure => 'The waste entry could not be deleted.';

  @override
  String get wastePlastic => 'Plastic';

  @override
  String get wastePaperCardboard => 'Paper & cardboard';

  @override
  String get wasteGlass => 'Glass';

  @override
  String get wasteMetal => 'Metal';

  @override
  String get wasteOrganic => 'Organic';

  @override
  String get wasteOther => 'Other';

  @override
  String get wasteWeeklyPlanner => 'Weekly planner';

  @override
  String get wastePlannerOwnScheduleNote =>
      'These are your settings only; the app does not know your local collection schedule.';

  @override
  String wastePlannerSummary(String recyclingDay, String compostDay) {
    return 'Recycling: $recyclingDay · Compost: $compostDay';
  }

  @override
  String get wasteRecyclingDay => 'Recycling collection day';

  @override
  String get wasteCompostDay => 'Compost day';

  @override
  String get wasteNotSet => 'Not set';

  @override
  String get wasteSetRecyclingDay => 'Set your recycling collection day.';

  @override
  String get wasteSetCompostDay => 'Set your compost day.';

  @override
  String get wastePlannerLoadFailure =>
      'Your weekly planner settings could not be loaded.';

  @override
  String get wastePlannerSaveFailure =>
      'Your weekly planner settings could not be saved.';

  @override
  String get wasteTipsSection => 'Tips';

  @override
  String get wasteTipKeepBinsCloseTitle => 'Keep both bins close';

  @override
  String get wasteTipKeepBinsCloseText =>
      'Keep a small recycling bin beside the main bin — sorting is easier when both are within reach.';

  @override
  String get wasteTipCompostScrapsTitle => 'Compost the right scraps';

  @override
  String get wasteTipCompostScrapsText =>
      'Compost fruit and vegetable scraps, eggshells, and coffee grounds — keep meat and dairy out of a home compost pile.';

  @override
  String get wasteTipRinseRecyclingTitle => 'Rinse before recycling';

  @override
  String get wasteTipRinseRecyclingText =>
      'Rinse containers before recycling — food residue can spoil a whole batch of recyclables.';

  @override
  String get wasteTipFlattenCardboardTitle => 'Flatten cardboard';

  @override
  String get wasteTipFlattenCardboardText =>
      'Flatten cardboard boxes — they take a fraction of the space and are easier to store until collection day.';

  @override
  String get wasteTipBuyLooseTitle => 'Buy loose where you can';

  @override
  String get wasteTipBuyLooseText =>
      'Buy loose produce instead of pre-packed where you can — less packaging enters the house in the first place.';

  @override
  String get wasteTipDonateRepairTitle => 'Donate or repair first';

  @override
  String get wasteTipDonateRepairText =>
      'Keep a \"donate or repair\" box — items you no longer use leave the house useful instead of becoming waste.';

  @override
  String get recipeSearchLabel => 'Search by recipe name or ingredient';

  @override
  String get recipeClearSearch => 'Clear recipe search';

  @override
  String get recipeSeasonFilter => 'Season';

  @override
  String get recipeNoMatches => 'No recipes match your search and season.';

  @override
  String get recipeClearFilters => 'Clear search and season';

  @override
  String get recipeCatalogLoadFailure => 'Recipes could not be loaded.';

  @override
  String get recipeDetail => 'Recipe details';

  @override
  String get recipePreparationTime => 'Preparation time';

  @override
  String get recipeServings => 'Servings';

  @override
  String get recipeSeasonalNote => 'Seasonal note';

  @override
  String get recipeIngredients => 'Ingredients';

  @override
  String get recipeSteps => 'Steps';

  @override
  String get recipesMealPlanning => 'Sustainable Recipes & Meal Planning';

  @override
  String get energyConservationTips => 'Energy Conservation Tips';

  @override
  String get energyTipSearchLabel => 'Search by title or text';

  @override
  String get energyTipClearSearch => 'Clear energy tip search';

  @override
  String get energyTipCategoryFilter => 'Category';

  @override
  String get energyTipAllCategories => 'All categories';

  @override
  String get energyTipNoMatches =>
      'No energy tips match your current search and category.';

  @override
  String get energyTipClearFilters => 'Clear search and category';

  @override
  String get energyTipCatalogLoadFailure => 'Energy tips could not be loaded.';

  @override
  String get ecoTravelSuggestions => 'Eco-Travel Suggestions';

  @override
  String get travelTripSection => 'Your trips';

  @override
  String get travelGuideSection => 'Travel guide';

  @override
  String get travelTransportGuidance => 'Travel guidance';

  @override
  String get travelNoTrips => 'No trips planned yet.';

  @override
  String get travelAddTrip => 'Plan a trip';

  @override
  String get travelEditTrip => 'Edit trip';

  @override
  String get travelTitleLabel => 'Trip title';

  @override
  String get travelDestinationLabel => 'Destination';

  @override
  String get travelModeLabel => 'Transport mode';

  @override
  String get travelDateLabel => 'Date (optional)';

  @override
  String get travelNoDate => 'No date set';

  @override
  String get travelChooseDate => 'Choose date';

  @override
  String get travelClearDate => 'Clear date';

  @override
  String get travelNotesLabel => 'Notes (optional)';

  @override
  String get travelSaveTrip => 'Save trip';

  @override
  String get travelUpdateTrip => 'Update trip';

  @override
  String get travelDeleteTrip => 'Delete trip';

  @override
  String get travelEditTripTooltip => 'Edit trip';

  @override
  String get travelTitleRequired => 'Enter a trip title.';

  @override
  String get travelDestinationRequired => 'Enter a destination.';

  @override
  String get travelLoadFailure => 'Planned trips could not be loaded.';

  @override
  String get travelGuideLoadFailure => 'The travel guide could not be loaded.';

  @override
  String get travelSaveFailure => 'The trip could not be saved.';

  @override
  String get travelDeleteFailure => 'The trip could not be deleted.';

  @override
  String get travelTipsSection => 'Tips';

  @override
  String get communityJournal => 'Community Journal';

  @override
  String get communityLocalOnly =>
      'Your posts are stored only on this device. Nothing is uploaded or shared.';

  @override
  String get communityFeedHeading => 'Your journal';

  @override
  String get communityNoPosts =>
      'No posts yet. Add your first post to start your personal record.';

  @override
  String get communityAddPost => 'Write a post';

  @override
  String get communityNewPostTitle => 'New journal post';

  @override
  String get communityEditPostTitle => 'Edit journal post';

  @override
  String get communityPostTitleLabel => 'Title';

  @override
  String get communityPostBodyLabel => 'What did you try?';

  @override
  String get communityTitleRequired => 'Enter a title.';

  @override
  String get communityBodyRequired => 'Enter the post text.';

  @override
  String get communitySavePost => 'Save post';

  @override
  String get communityUpdatePost => 'Update post';

  @override
  String get communityEditPostTooltip => 'Edit post';

  @override
  String get communityDeletePostTooltip => 'Delete post';

  @override
  String get communityLoadFailure => 'Your journal could not be loaded.';

  @override
  String get communitySaveFailure => 'The post could not be saved.';

  @override
  String get communityUpdateFailure => 'The post could not be updated.';

  @override
  String get communityDeleteFailure => 'The post could not be deleted.';

  @override
  String get communityGuidelinesHeading => 'Community guidelines';

  @override
  String get communityGuidelineShareTitle => 'Share what you tried';

  @override
  String get communityGuidelineShareText =>
      'Posts about your own efforts, challenges, and results help you see your own progress over time.';

  @override
  String get communityGuidelineSpecificTitle => 'Be specific';

  @override
  String get communityGuidelineSpecificText =>
      'What you changed, for how long, and what happened — specific posts are the ones worth re-reading.';

  @override
  String get communityGuidelineHonestTitle => 'Be honest about results';

  @override
  String get communityGuidelineHonestText =>
      'A challenge that did not work is as useful a record as one that did.';

  @override
  String get communityGuidelineDeviceTitle => 'Your journal, your device';

  @override
  String get communityGuidelineDeviceText =>
      'In this version the forum is a personal, on-device feed. A shared community would arrive in a later version.';

  @override
  String get progressDashboard => 'Sustainability Progress Dashboard';

  @override
  String get progressOverallEmpty =>
      'Your progress will appear here as you use the app.';

  @override
  String get progressCarbonTitle => 'Carbon footprint';

  @override
  String get progressCarbonEmpty =>
      'No activity logged yet. Start in Carbon Footprint Tracker.';

  @override
  String get progressCarbonTotal => 'All-time emissions';

  @override
  String get progressMonthlyTrendThisYear => 'Monthly trend this year';

  @override
  String get progressNoCurrentYearTrend => 'No entries recorded this year yet.';

  @override
  String get progressWasteTitle => 'Waste reduction';

  @override
  String get progressWasteEmpty =>
      'No waste logged yet. Start in Waste Reduction Tracker.';

  @override
  String get progressWasteTotal => 'All-time waste logged';

  @override
  String get progressChallengesTitle => 'Challenges';

  @override
  String get progressChallengesEmpty =>
      'No challenges joined yet. Start in Sustainable Living Challenges.';

  @override
  String get progressChallengesJoined => 'Challenges joined';

  @override
  String get progressDaysChecked => 'Days checked off';

  @override
  String get progressTravelTitle => 'Travel';

  @override
  String get progressTravelEmpty =>
      'No trips planned yet. Start in Eco-Travel Suggestions.';

  @override
  String get progressTripsPlanned => 'Trips planned';

  @override
  String get progressJournalTitle => 'Journal';

  @override
  String get progressJournalEmpty =>
      'No posts written yet. Start in Community Journal.';

  @override
  String get progressPostsWritten => 'Posts written';

  @override
  String get progressPurchasesScope =>
      'Purchases are not tracked in this app, so they do not appear on this dashboard.';

  @override
  String get progressLoadFailure => 'Your progress could not be loaded.';

  @override
  String get educationalContent => 'Educational Content';

  @override
  String get educationalSearchLabel => 'Search by title or body';

  @override
  String get educationalClearSearch => 'Clear article search';

  @override
  String get educationalTopicFilter => 'Topic';

  @override
  String get educationalAllTopics => 'All topics';

  @override
  String get educationalSortLabel => 'Sort';

  @override
  String get educationalSortTitle => 'Title (A–Z)';

  @override
  String get educationalSortShortestRead => 'Shortest read';

  @override
  String get educationalNoMatches => 'No articles match your search and topic.';

  @override
  String get educationalClearFilters => 'Clear search and filters';

  @override
  String get educationalMinuteUnit => 'min';

  @override
  String get educationalReadLabel => 'read';

  @override
  String get educationalArticle => 'Article';

  @override
  String get educationalTakeaway => 'Takeaway';

  @override
  String get educationalCatalogLoadFailure =>
      'Educational articles could not be loaded.';

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
