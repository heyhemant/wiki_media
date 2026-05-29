import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WikiMedia'**
  String get appTitle;

  /// No description provided for @preparingFeed.
  ///
  /// In en, this message translates to:
  /// **'Preparing recommendation feed...'**
  String get preparingFeed;

  /// No description provided for @dataSetupRequired.
  ///
  /// In en, this message translates to:
  /// **'Data Setup Required'**
  String get dataSetupRequired;

  /// No description provided for @dataSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'WikiMedia loads content offline. To get started, we need to download and set up the Simple Wikipedia dataset.'**
  String get dataSetupDescription;

  /// No description provided for @downloadSize.
  ///
  /// In en, this message translates to:
  /// **'Download size: ~35 MB\nDecompressed local size: ~250 MB'**
  String get downloadSize;

  /// No description provided for @downloadAndSetup.
  ///
  /// In en, this message translates to:
  /// **'Download & Setup'**
  String get downloadAndSetup;

  /// No description provided for @settingUpDatabase.
  ///
  /// In en, this message translates to:
  /// **'Setting up database...'**
  String get settingUpDatabase;

  /// No description provided for @keepAppOpen.
  ///
  /// In en, this message translates to:
  /// **'Please keep the app open.'**
  String get keepAppOpen;

  /// No description provided for @downloadingDatabase.
  ///
  /// In en, this message translates to:
  /// **'Downloading Database...'**
  String get downloadingDatabase;

  /// No description provided for @downloadedProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {downloaded} MB of {total} MB'**
  String downloadedProgress(Object downloaded, Object total);

  /// No description provided for @processingDataset.
  ///
  /// In en, this message translates to:
  /// **'Processing Dataset...'**
  String get processingDataset;

  /// No description provided for @preparingFiles.
  ///
  /// In en, this message translates to:
  /// **'Preparing files...'**
  String get preparingFiles;

  /// No description provided for @importingArticles.
  ///
  /// In en, this message translates to:
  /// **'Importing Articles...'**
  String get importingArticles;

  /// No description provided for @writingToCache.
  ///
  /// In en, this message translates to:
  /// **'Writing to local cache: {count} of {total} ({percent}%)'**
  String writingToCache(Object count, Object percent, Object total);

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops, Something Went Wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// No description provided for @anthropology.
  ///
  /// In en, this message translates to:
  /// **'Anthropology'**
  String get anthropology;

  /// No description provided for @places.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get places;

  /// No description provided for @sociology.
  ///
  /// In en, this message translates to:
  /// **'Sociology'**
  String get sociology;

  /// No description provided for @art.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get art;

  /// No description provided for @mathematics.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get mathematics;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @humanSexuality.
  ///
  /// In en, this message translates to:
  /// **'Human Sexuality'**
  String get humanSexuality;

  /// No description provided for @chooseInterests.
  ///
  /// In en, this message translates to:
  /// **'Choose starting interests (Optional)'**
  String get chooseInterests;

  /// No description provided for @customInterests.
  ///
  /// In en, this message translates to:
  /// **'Custom Interests:'**
  String get customInterests;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Or search for custom categories'**
  String get searchCategories;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search: e.g. physics, estonia...'**
  String get searchHint;

  /// No description provided for @adultWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Since WikiMedia displays summaries and images from random Wikipedia articles, you might encounter sensitive or adult content. Please only proceed if you are an adult.'**
  String get adultWarning;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'I\'m an adult, continue'**
  String get continueButton;

  /// No description provided for @storeData.
  ///
  /// In en, this message translates to:
  /// **'Store data'**
  String get storeData;

  /// No description provided for @storeDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Save category scores and history locally. If disabled, feed resets on restart.'**
  String get storeDataDesc;

  /// No description provided for @openInEnglishWiki.
  ///
  /// In en, this message translates to:
  /// **'Open in English Wikipedia'**
  String get openInEnglishWiki;

  /// No description provided for @openInEnglishWikiDesc.
  ///
  /// In en, this message translates to:
  /// **'Open links in the standard English Wikipedia instead of Simple English Wikipedia.'**
  String get openInEnglishWikiDesc;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @resetAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'Reset Algorithm'**
  String get resetAlgorithm;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllData;

  /// No description provided for @resetAlgorithmConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset Algorithm?'**
  String get resetAlgorithmConfirm;

  /// No description provided for @resetAlgorithmDesc.
  ///
  /// In en, this message translates to:
  /// **'This will wipe all category scores and statistics for the current profile \"{name}\". This action cannot be undone.'**
  String resetAlgorithmDesc(Object name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete Everything'**
  String get deleteEverything;

  /// No description provided for @deleteAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data?'**
  String get deleteAllDataConfirm;

  /// No description provided for @deleteAllDataDesc.
  ///
  /// In en, this message translates to:
  /// **'This will wipe the entire SQLite database, reset all profiles, and clear all settings. You will need to re-download the database. This cannot be undone.'**
  String get deleteAllDataDesc;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add Profile'**
  String get addProfile;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Profile name...'**
  String get profileNameHint;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @deleteProfileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile?'**
  String get deleteProfileConfirm;

  /// No description provided for @deleteProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete profile \"{name}\"? All category scores and history will be lost.'**
  String deleteProfileDesc(Object name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @liked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get liked;

  /// No description provided for @postsScrolledTotal.
  ///
  /// In en, this message translates to:
  /// **'Posts Scrolled (Total)'**
  String get postsScrolledTotal;

  /// No description provided for @postsScrolledSession.
  ///
  /// In en, this message translates to:
  /// **'Posts Scrolled (Session)'**
  String get postsScrolledSession;

  /// No description provided for @timeSpentTotal.
  ///
  /// In en, this message translates to:
  /// **'Time Spent (Total)'**
  String get timeSpentTotal;

  /// No description provided for @timeSpentSession.
  ///
  /// In en, this message translates to:
  /// **'Time Spent (Session)'**
  String get timeSpentSession;

  /// No description provided for @scoringMechanism.
  ///
  /// In en, this message translates to:
  /// **'Scoring Mechanism'**
  String get scoringMechanism;

  /// No description provided for @scoringDesc.
  ///
  /// In en, this message translates to:
  /// **'Your feed is tailored using actions on categories:\n\n• Scroll past post: -5 points\n• Like post: +50 to +100+ points\n• Read article: +75 points\n• Open image: +100 points\n\nHigher category scores increase the likelihood of selection by the algorithm.'**
  String get scoringDesc;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get topCategories;

  /// No description provided for @bottomCategories.
  ///
  /// In en, this message translates to:
  /// **'Bottom Categories'**
  String get bottomCategories;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet.'**
  String get noRecords;

  /// No description provided for @noLikedArticles.
  ///
  /// In en, this message translates to:
  /// **'You have not liked any articles yet!'**
  String get noLikedArticles;

  /// No description provided for @tapCardToRead.
  ///
  /// In en, this message translates to:
  /// **'Tap card to read article'**
  String get tapCardToRead;

  /// No description provided for @article.
  ///
  /// In en, this message translates to:
  /// **'Articleer : {title}'**
  String article(Object title);

  /// No description provided for @hemant.
  ///
  /// In en, this message translates to:
  /// **'Hemant'**
  String get hemant;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
