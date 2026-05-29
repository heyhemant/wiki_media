// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `WikiMedia`
  String get appTitle {
    return Intl.message(
      'WikiMedia',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Preparing recommendation feed...`
  String get preparingFeed {
    return Intl.message(
      'Preparing recommendation feed...',
      name: 'preparingFeed',
      desc: '',
      args: [],
    );
  }

  /// `Data Setup Required`
  String get dataSetupRequired {
    return Intl.message(
      'Data Setup Required',
      name: 'dataSetupRequired',
      desc: '',
      args: [],
    );
  }

  /// `WikiMedia loads content offline. To get started, we need to download and set up the Simple Wikipedia dataset.`
  String get dataSetupDescription {
    return Intl.message(
      'WikiMedia loads content offline. To get started, we need to download and set up the Simple Wikipedia dataset.',
      name: 'dataSetupDescription',
      desc: '',
      args: [],
    );
  }

  /// `Download size: ~35 MB\nDecompressed local size: ~250 MB`
  String get downloadSize {
    return Intl.message(
      'Download size: ~35 MB\nDecompressed local size: ~250 MB',
      name: 'downloadSize',
      desc: '',
      args: [],
    );
  }

  /// `Download & Setup`
  String get downloadAndSetup {
    return Intl.message(
      'Download & Setup',
      name: 'downloadAndSetup',
      desc: '',
      args: [],
    );
  }

  /// `Setting up database...`
  String get settingUpDatabase {
    return Intl.message(
      'Setting up database...',
      name: 'settingUpDatabase',
      desc: '',
      args: [],
    );
  }

  /// `Please keep the app open.`
  String get keepAppOpen {
    return Intl.message(
      'Please keep the app open.',
      name: 'keepAppOpen',
      desc: '',
      args: [],
    );
  }

  /// `Downloading Database...`
  String get downloadingDatabase {
    return Intl.message(
      'Downloading Database...',
      name: 'downloadingDatabase',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded {downloaded} MB of {total} MB`
  String downloadedProgress(Object downloaded, Object total) {
    return Intl.message(
      'Downloaded $downloaded MB of $total MB',
      name: 'downloadedProgress',
      desc: '',
      args: [downloaded, total],
    );
  }

  /// `Processing Dataset...`
  String get processingDataset {
    return Intl.message(
      'Processing Dataset...',
      name: 'processingDataset',
      desc: '',
      args: [],
    );
  }

  /// `Preparing files...`
  String get preparingFiles {
    return Intl.message(
      'Preparing files...',
      name: 'preparingFiles',
      desc: '',
      args: [],
    );
  }

  /// `Importing Articles...`
  String get importingArticles {
    return Intl.message(
      'Importing Articles...',
      name: 'importingArticles',
      desc: '',
      args: [],
    );
  }

  /// `Writing to local cache: {count} of {total} ({percent}%)`
  String writingToCache(Object count, Object total, Object percent) {
    return Intl.message(
      'Writing to local cache: $count of $total ($percent%)',
      name: 'writingToCache',
      desc: '',
      args: [count, total, percent],
    );
  }

  /// `Oops, Something Went Wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Oops, Something Went Wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get tryAgain {
    return Intl.message(
      'Try Again',
      name: 'tryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Profiles`
  String get profiles {
    return Intl.message(
      'Profiles',
      name: 'profiles',
      desc: '',
      args: [],
    );
  }

  /// `Stats`
  String get stats {
    return Intl.message(
      'Stats',
      name: 'stats',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Nature`
  String get nature {
    return Intl.message(
      'Nature',
      name: 'nature',
      desc: '',
      args: [],
    );
  }

  /// `Science`
  String get science {
    return Intl.message(
      'Science',
      name: 'science',
      desc: '',
      args: [],
    );
  }

  /// `Animals`
  String get animals {
    return Intl.message(
      'Animals',
      name: 'animals',
      desc: '',
      args: [],
    );
  }

  /// `Anthropology`
  String get anthropology {
    return Intl.message(
      'Anthropology',
      name: 'anthropology',
      desc: '',
      args: [],
    );
  }

  /// `Places`
  String get places {
    return Intl.message(
      'Places',
      name: 'places',
      desc: '',
      args: [],
    );
  }

  /// `Sociology`
  String get sociology {
    return Intl.message(
      'Sociology',
      name: 'sociology',
      desc: '',
      args: [],
    );
  }

  /// `Art`
  String get art {
    return Intl.message(
      'Art',
      name: 'art',
      desc: '',
      args: [],
    );
  }

  /// `Mathematics`
  String get mathematics {
    return Intl.message(
      'Mathematics',
      name: 'mathematics',
      desc: '',
      args: [],
    );
  }

  /// `Games`
  String get games {
    return Intl.message(
      'Games',
      name: 'games',
      desc: '',
      args: [],
    );
  }

  /// `Technology`
  String get technology {
    return Intl.message(
      'Technology',
      name: 'technology',
      desc: '',
      args: [],
    );
  }

  /// `Music`
  String get music {
    return Intl.message(
      'Music',
      name: 'music',
      desc: '',
      args: [],
    );
  }

  /// `Human Sexuality`
  String get humanSexuality {
    return Intl.message(
      'Human Sexuality',
      name: 'humanSexuality',
      desc: '',
      args: [],
    );
  }

  /// `Choose starting interests (Optional)`
  String get chooseInterests {
    return Intl.message(
      'Choose starting interests (Optional)',
      name: 'chooseInterests',
      desc: '',
      args: [],
    );
  }

  /// `Custom Interests:`
  String get customInterests {
    return Intl.message(
      'Custom Interests:',
      name: 'customInterests',
      desc: '',
      args: [],
    );
  }

  /// `Or search for custom categories`
  String get searchCategories {
    return Intl.message(
      'Or search for custom categories',
      name: 'searchCategories',
      desc: '',
      args: [],
    );
  }

  /// `Search: e.g. physics, estonia...`
  String get searchHint {
    return Intl.message(
      'Search: e.g. physics, estonia...',
      name: 'searchHint',
      desc: '',
      args: [],
    );
  }

  /// `Warning: Since WikiMedia displays summaries and images from random Wikipedia articles, you might encounter sensitive or adult content. Please only proceed if you are an adult.`
  String get adultWarning {
    return Intl.message(
      'Warning: Since WikiMedia displays summaries and images from random Wikipedia articles, you might encounter sensitive or adult content. Please only proceed if you are an adult.',
      name: 'adultWarning',
      desc: '',
      args: [],
    );
  }

  /// `I'm an adult, continue`
  String get continueButton {
    return Intl.message(
      'I\'m an adult, continue',
      name: 'continueButton',
      desc: '',
      args: [],
    );
  }

  /// `Store data`
  String get storeData {
    return Intl.message(
      'Store data',
      name: 'storeData',
      desc: '',
      args: [],
    );
  }

  /// `Save category scores and history locally. If disabled, feed resets on restart.`
  String get storeDataDesc {
    return Intl.message(
      'Save category scores and history locally. If disabled, feed resets on restart.',
      name: 'storeDataDesc',
      desc: '',
      args: [],
    );
  }

  /// `Open in English Wikipedia`
  String get openInEnglishWiki {
    return Intl.message(
      'Open in English Wikipedia',
      name: 'openInEnglishWiki',
      desc: '',
      args: [],
    );
  }

  /// `Open links in the standard English Wikipedia instead of Simple English Wikipedia.`
  String get openInEnglishWikiDesc {
    return Intl.message(
      'Open links in the standard English Wikipedia instead of Simple English Wikipedia.',
      name: 'openInEnglishWikiDesc',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Reset Algorithm`
  String get resetAlgorithm {
    return Intl.message(
      'Reset Algorithm',
      name: 'resetAlgorithm',
      desc: '',
      args: [],
    );
  }

  /// `Delete All Data`
  String get deleteAllData {
    return Intl.message(
      'Delete All Data',
      name: 'deleteAllData',
      desc: '',
      args: [],
    );
  }

  /// `Reset Algorithm?`
  String get resetAlgorithmConfirm {
    return Intl.message(
      'Reset Algorithm?',
      name: 'resetAlgorithmConfirm',
      desc: '',
      args: [],
    );
  }

  /// `This will wipe all category scores and statistics for the current profile "{name}". This action cannot be undone.`
  String resetAlgorithmDesc(Object name) {
    return Intl.message(
      'This will wipe all category scores and statistics for the current profile "$name". This action cannot be undone.',
      name: 'resetAlgorithmDesc',
      desc: '',
      args: [name],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Delete Everything`
  String get deleteEverything {
    return Intl.message(
      'Delete Everything',
      name: 'deleteEverything',
      desc: '',
      args: [],
    );
  }

  /// `Delete All Data?`
  String get deleteAllDataConfirm {
    return Intl.message(
      'Delete All Data?',
      name: 'deleteAllDataConfirm',
      desc: '',
      args: [],
    );
  }

  /// `This will wipe the entire SQLite database, reset all profiles, and clear all settings. You will need to re-download the database. This cannot be undone.`
  String get deleteAllDataDesc {
    return Intl.message(
      'This will wipe the entire SQLite database, reset all profiles, and clear all settings. You will need to re-download the database. This cannot be undone.',
      name: 'deleteAllDataDesc',
      desc: '',
      args: [],
    );
  }

  /// `Add Profile`
  String get addProfile {
    return Intl.message(
      'Add Profile',
      name: 'addProfile',
      desc: '',
      args: [],
    );
  }

  /// `Create Profile`
  String get createProfile {
    return Intl.message(
      'Create Profile',
      name: 'createProfile',
      desc: '',
      args: [],
    );
  }

  /// `Profile name...`
  String get profileNameHint {
    return Intl.message(
      'Profile name...',
      name: 'profileNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Delete Profile?`
  String get deleteProfileConfirm {
    return Intl.message(
      'Delete Profile?',
      name: 'deleteProfileConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete profile "{name}"? All category scores and history will be lost.`
  String deleteProfileDesc(Object name) {
    return Intl.message(
      'Are you sure you want to delete profile "$name"? All category scores and history will be lost.',
      name: 'deleteProfileDesc',
      desc: '',
      args: [name],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  /// `Liked`
  String get liked {
    return Intl.message(
      'Liked',
      name: 'liked',
      desc: '',
      args: [],
    );
  }

  /// `Posts Scrolled (Total)`
  String get postsScrolledTotal {
    return Intl.message(
      'Posts Scrolled (Total)',
      name: 'postsScrolledTotal',
      desc: '',
      args: [],
    );
  }

  /// `Posts Scrolled (Session)`
  String get postsScrolledSession {
    return Intl.message(
      'Posts Scrolled (Session)',
      name: 'postsScrolledSession',
      desc: '',
      args: [],
    );
  }

  /// `Time Spent (Total)`
  String get timeSpentTotal {
    return Intl.message(
      'Time Spent (Total)',
      name: 'timeSpentTotal',
      desc: '',
      args: [],
    );
  }

  /// `Time Spent (Session)`
  String get timeSpentSession {
    return Intl.message(
      'Time Spent (Session)',
      name: 'timeSpentSession',
      desc: '',
      args: [],
    );
  }

  /// `Scoring Mechanism`
  String get scoringMechanism {
    return Intl.message(
      'Scoring Mechanism',
      name: 'scoringMechanism',
      desc: '',
      args: [],
    );
  }

  /// `Your feed is tailored using actions on categories:\n\n• Scroll past post: -5 points\n• Like post: +50 to +100+ points\n• Read article: +75 points\n• Open image: +100 points\n\nHigher category scores increase the likelihood of selection by the algorithm.`
  String get scoringDesc {
    return Intl.message(
      'Your feed is tailored using actions on categories:\n\n• Scroll past post: -5 points\n• Like post: +50 to +100+ points\n• Read article: +75 points\n• Open image: +100 points\n\nHigher category scores increase the likelihood of selection by the algorithm.',
      name: 'scoringDesc',
      desc: '',
      args: [],
    );
  }

  /// `Top Categories`
  String get topCategories {
    return Intl.message(
      'Top Categories',
      name: 'topCategories',
      desc: '',
      args: [],
    );
  }

  /// `Bottom Categories`
  String get bottomCategories {
    return Intl.message(
      'Bottom Categories',
      name: 'bottomCategories',
      desc: '',
      args: [],
    );
  }

  /// `No records yet.`
  String get noRecords {
    return Intl.message(
      'No records yet.',
      name: 'noRecords',
      desc: '',
      args: [],
    );
  }

  /// `You have not liked any articles yet!`
  String get noLikedArticles {
    return Intl.message(
      'You have not liked any articles yet!',
      name: 'noLikedArticles',
      desc: '',
      args: [],
    );
  }

  /// `Tap card to read article`
  String get tapCardToRead {
    return Intl.message(
      'Tap card to read article',
      name: 'tapCardToRead',
      desc: '',
      args: [],
    );
  }

  /// `Articleer : {title}`
  String article(Object title) {
    return Intl.message(
      'Articleer : $title',
      name: 'article',
      desc: '',
      args: [title],
    );
  }

  /// `Hemant`
  String get hemant {
    return Intl.message(
      'Hemant',
      name: 'hemant',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
