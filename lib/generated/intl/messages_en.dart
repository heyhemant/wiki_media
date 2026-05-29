// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(title) => "Articleer : ${title}";

  static String m1(name) =>
      "Are you sure you want to delete profile \"${name}\"? All category scores and history will be lost.";

  static String m2(downloaded, total) =>
      "Downloaded ${downloaded} MB of ${total} MB";

  static String m3(name) =>
      "This will wipe all category scores and statistics for the current profile \"${name}\". This action cannot be undone.";

  static String m4(count, total, percent) =>
      "Writing to local cache: ${count} of ${total} (${percent}%)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addProfile": MessageLookupByLibrary.simpleMessage("Add Profile"),
        "adultWarning": MessageLookupByLibrary.simpleMessage(
            "Warning: Since WikiMedia displays summaries and images from random Wikipedia articles, you might encounter sensitive or adult content. Please only proceed if you are an adult."),
        "animals": MessageLookupByLibrary.simpleMessage("Animals"),
        "anthropology": MessageLookupByLibrary.simpleMessage("Anthropology"),
        "appTitle": MessageLookupByLibrary.simpleMessage("WikiMedia"),
        "art": MessageLookupByLibrary.simpleMessage("Art"),
        "article": m0,
        "auto": MessageLookupByLibrary.simpleMessage("Auto"),
        "bottomCategories":
            MessageLookupByLibrary.simpleMessage("Bottom Categories"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "categories": MessageLookupByLibrary.simpleMessage("Categories"),
        "chooseInterests": MessageLookupByLibrary.simpleMessage(
            "Choose starting interests (Optional)"),
        "continueButton":
            MessageLookupByLibrary.simpleMessage("I\'m an adult, continue"),
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "createProfile": MessageLookupByLibrary.simpleMessage("Create Profile"),
        "customInterests":
            MessageLookupByLibrary.simpleMessage("Custom Interests:"),
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "dataSetupDescription": MessageLookupByLibrary.simpleMessage(
            "WikiMedia loads content offline. To get started, we need to download and set up the Simple Wikipedia dataset."),
        "dataSetupRequired":
            MessageLookupByLibrary.simpleMessage("Data Setup Required"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAllData":
            MessageLookupByLibrary.simpleMessage("Delete All Data"),
        "deleteAllDataConfirm":
            MessageLookupByLibrary.simpleMessage("Delete All Data?"),
        "deleteAllDataDesc": MessageLookupByLibrary.simpleMessage(
            "This will wipe the entire SQLite database, reset all profiles, and clear all settings. You will need to re-download the database. This cannot be undone."),
        "deleteEverything":
            MessageLookupByLibrary.simpleMessage("Delete Everything"),
        "deleteProfileConfirm":
            MessageLookupByLibrary.simpleMessage("Delete Profile?"),
        "deleteProfileDesc": m1,
        "downloadAndSetup":
            MessageLookupByLibrary.simpleMessage("Download & Setup"),
        "downloadSize": MessageLookupByLibrary.simpleMessage(
            "Download size: ~35 MB\nDecompressed local size: ~250 MB"),
        "downloadedProgress": m2,
        "downloadingDatabase":
            MessageLookupByLibrary.simpleMessage("Downloading Database..."),
        "games": MessageLookupByLibrary.simpleMessage("Games"),
        "general": MessageLookupByLibrary.simpleMessage("General"),
        "hemant": MessageLookupByLibrary.simpleMessage("Hemant"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "humanSexuality":
            MessageLookupByLibrary.simpleMessage("Human Sexuality"),
        "importingArticles":
            MessageLookupByLibrary.simpleMessage("Importing Articles..."),
        "keepAppOpen":
            MessageLookupByLibrary.simpleMessage("Please keep the app open."),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "liked": MessageLookupByLibrary.simpleMessage("Liked"),
        "mathematics": MessageLookupByLibrary.simpleMessage("Mathematics"),
        "music": MessageLookupByLibrary.simpleMessage("Music"),
        "nature": MessageLookupByLibrary.simpleMessage("Nature"),
        "noLikedArticles": MessageLookupByLibrary.simpleMessage(
            "You have not liked any articles yet!"),
        "noRecords": MessageLookupByLibrary.simpleMessage("No records yet."),
        "openInEnglishWiki":
            MessageLookupByLibrary.simpleMessage("Open in English Wikipedia"),
        "openInEnglishWikiDesc": MessageLookupByLibrary.simpleMessage(
            "Open links in the standard English Wikipedia instead of Simple English Wikipedia."),
        "places": MessageLookupByLibrary.simpleMessage("Places"),
        "postsScrolledSession":
            MessageLookupByLibrary.simpleMessage("Posts Scrolled (Session)"),
        "postsScrolledTotal":
            MessageLookupByLibrary.simpleMessage("Posts Scrolled (Total)"),
        "preparingFeed": MessageLookupByLibrary.simpleMessage(
            "Preparing recommendation feed..."),
        "preparingFiles":
            MessageLookupByLibrary.simpleMessage("Preparing files..."),
        "processingDataset":
            MessageLookupByLibrary.simpleMessage("Processing Dataset..."),
        "profileNameHint":
            MessageLookupByLibrary.simpleMessage("Profile name..."),
        "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "resetAlgorithm":
            MessageLookupByLibrary.simpleMessage("Reset Algorithm"),
        "resetAlgorithmConfirm":
            MessageLookupByLibrary.simpleMessage("Reset Algorithm?"),
        "resetAlgorithmDesc": m3,
        "science": MessageLookupByLibrary.simpleMessage("Science"),
        "scoringDesc": MessageLookupByLibrary.simpleMessage(
            "Your feed is tailored using actions on categories:\n\n• Scroll past post: -5 points\n• Like post: +50 to +100+ points\n• Read article: +75 points\n• Open image: +100 points\n\nHigher category scores increase the likelihood of selection by the algorithm."),
        "scoringMechanism":
            MessageLookupByLibrary.simpleMessage("Scoring Mechanism"),
        "searchCategories": MessageLookupByLibrary.simpleMessage(
            "Or search for custom categories"),
        "searchHint": MessageLookupByLibrary.simpleMessage(
            "Search: e.g. physics, estonia..."),
        "settingUpDatabase":
            MessageLookupByLibrary.simpleMessage("Setting up database..."),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "sociology": MessageLookupByLibrary.simpleMessage("Sociology"),
        "somethingWentWrong":
            MessageLookupByLibrary.simpleMessage("Oops, Something Went Wrong"),
        "stats": MessageLookupByLibrary.simpleMessage("Stats"),
        "storeData": MessageLookupByLibrary.simpleMessage("Store data"),
        "storeDataDesc": MessageLookupByLibrary.simpleMessage(
            "Save category scores and history locally. If disabled, feed resets on restart."),
        "tapCardToRead":
            MessageLookupByLibrary.simpleMessage("Tap card to read article"),
        "technology": MessageLookupByLibrary.simpleMessage("Technology"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "timeSpentSession":
            MessageLookupByLibrary.simpleMessage("Time Spent (Session)"),
        "timeSpentTotal":
            MessageLookupByLibrary.simpleMessage("Time Spent (Total)"),
        "topCategories": MessageLookupByLibrary.simpleMessage("Top Categories"),
        "tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
        "writingToCache": m4
      };
}
