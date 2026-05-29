// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WikiMedia';

  @override
  String get preparingFeed => 'Preparing recommendation feed...';

  @override
  String get dataSetupRequired => 'Data Setup Required';

  @override
  String get dataSetupDescription =>
      'WikiMedia loads content offline. To get started, we need to download and set up the Simple Wikipedia dataset.';

  @override
  String get downloadSize =>
      'Download size: ~35 MB\nDecompressed local size: ~250 MB';

  @override
  String get downloadAndSetup => 'Download & Setup';

  @override
  String get settingUpDatabase => 'Setting up database...';

  @override
  String get keepAppOpen => 'Please keep the app open.';

  @override
  String get downloadingDatabase => 'Downloading Database...';

  @override
  String downloadedProgress(Object downloaded, Object total) {
    return 'Downloaded $downloaded MB of $total MB';
  }

  @override
  String get processingDataset => 'Processing Dataset...';

  @override
  String get preparingFiles => 'Preparing files...';

  @override
  String get importingArticles => 'Importing Articles...';

  @override
  String writingToCache(Object count, Object percent, Object total) {
    return 'Writing to local cache: $count of $total ($percent%)';
  }

  @override
  String get somethingWentWrong => 'Oops, Something Went Wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get home => 'Home';

  @override
  String get profiles => 'Profiles';

  @override
  String get stats => 'Stats';

  @override
  String get settings => 'Settings';

  @override
  String get nature => 'Nature';

  @override
  String get science => 'Science';

  @override
  String get animals => 'Animals';

  @override
  String get anthropology => 'Anthropology';

  @override
  String get places => 'Places';

  @override
  String get sociology => 'Sociology';

  @override
  String get art => 'Art';

  @override
  String get mathematics => 'Mathematics';

  @override
  String get games => 'Games';

  @override
  String get technology => 'Technology';

  @override
  String get music => 'Music';

  @override
  String get humanSexuality => 'Human Sexuality';

  @override
  String get chooseInterests => 'Choose starting interests (Optional)';

  @override
  String get customInterests => 'Custom Interests:';

  @override
  String get searchCategories => 'Or search for custom categories';

  @override
  String get searchHint => 'Search: e.g. physics, estonia...';

  @override
  String get adultWarning =>
      'Warning: Since WikiMedia displays summaries and images from random Wikipedia articles, you might encounter sensitive or adult content. Please only proceed if you are an adult.';

  @override
  String get continueButton => 'I\'m an adult, continue';

  @override
  String get storeData => 'Store data';

  @override
  String get storeDataDesc =>
      'Save category scores and history locally. If disabled, feed resets on restart.';

  @override
  String get openInEnglishWiki => 'Open in English Wikipedia';

  @override
  String get openInEnglishWikiDesc =>
      'Open links in the standard English Wikipedia instead of Simple English Wikipedia.';

  @override
  String get theme => 'Theme';

  @override
  String get auto => 'Auto';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get resetAlgorithm => 'Reset Algorithm';

  @override
  String get deleteAllData => 'Delete All Data';

  @override
  String get resetAlgorithmConfirm => 'Reset Algorithm?';

  @override
  String resetAlgorithmDesc(Object name) {
    return 'This will wipe all category scores and statistics for the current profile \"$name\". This action cannot be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get deleteEverything => 'Delete Everything';

  @override
  String get deleteAllDataConfirm => 'Delete All Data?';

  @override
  String get deleteAllDataDesc =>
      'This will wipe the entire SQLite database, reset all profiles, and clear all settings. You will need to re-download the database. This cannot be undone.';

  @override
  String get addProfile => 'Add Profile';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get profileNameHint => 'Profile name...';

  @override
  String get create => 'Create';

  @override
  String get deleteProfileConfirm => 'Delete Profile?';

  @override
  String deleteProfileDesc(Object name) {
    return 'Are you sure you want to delete profile \"$name\"? All category scores and history will be lost.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get general => 'General';

  @override
  String get categories => 'Categories';

  @override
  String get liked => 'Liked';

  @override
  String get postsScrolledTotal => 'Posts Scrolled (Total)';

  @override
  String get postsScrolledSession => 'Posts Scrolled (Session)';

  @override
  String get timeSpentTotal => 'Time Spent (Total)';

  @override
  String get timeSpentSession => 'Time Spent (Session)';

  @override
  String get scoringMechanism => 'Scoring Mechanism';

  @override
  String get scoringDesc =>
      'Your feed is tailored using actions on categories:\n\n• Scroll past post: -5 points\n• Like post: +50 to +100+ points\n• Read article: +75 points\n• Open image: +100 points\n\nHigher category scores increase the likelihood of selection by the algorithm.';

  @override
  String get topCategories => 'Top Categories';

  @override
  String get bottomCategories => 'Bottom Categories';

  @override
  String get noRecords => 'No records yet.';

  @override
  String get noLikedArticles => 'You have not liked any articles yet!';

  @override
  String get tapCardToRead => 'Tap card to read article';

  @override
  String article(Object title) {
    return 'Articleer : $title';
  }

  @override
  String get hemant => 'Hemant';
}
