import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'data_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  late SharedPreferences _prefs;

  // Settings
  bool storeData = true;
  bool openMainWiki = true; // true = en.wikipedia, false = simple.wikipedia
  String theme = 'auto'; // auto, light, dark
  String currentProfileId = 'default';
  List<String> profiles = ['default'];

  // Current Profile Data
  String profileName = 'Default';
  Map<String, int> categoryScores = {
    'given names': -1000,
    'surnames': -1000,
  };
  List<int> seenPosts = [];
  List<int> likedPosts = [];
  int timeSpentTotalMs = 0;

  // Runtime Stats
  int sessionPostsScrolled = 0;
  int sessionTimeSpentMs = 0;
  int postsWithoutLike = 0;
  DateTime _lastTimeSpentCheck = DateTime.now();

  Timer? _saveTimer;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    
    // Load Settings
    final settingsStr = _prefs.getString('wikimedia_settings');
    if (settingsStr != null) {
      try {
        final Map<String, dynamic> settings = jsonDecode(settingsStr);
        storeData = settings['storeData'] ?? true;
        openMainWiki = settings['openMainWiki'] ?? true;
        theme = settings['theme'] ?? 'auto';
        currentProfileId = settings['currentProfileId'] ?? 'default';
        profiles = List<String>.from(settings['profiles'] ?? ['default']);
      } catch (_) {}
    }

    await loadProfile(currentProfileId);
    _isInitialized = true;
  }

  Future<void> loadProfile(String profileId) async {
    currentProfileId = profileId;
    if (!profiles.contains(profileId)) {
      profiles.add(profileId);
    }
    
    final profileStr = _prefs.getString('wikimedia_profile_$profileId');
    if (profileStr != null) {
      try {
        final Map<String, dynamic> profile = jsonDecode(profileStr);
        profileName = profile['profileName'] ?? 'Default';
        
        final rawScores = profile['categoryScores'] as Map<String, dynamic>?;
        categoryScores = rawScores != null 
            ? rawScores.map((k, v) => MapEntry(k, v as int))
            : {'given names': -1000, 'surnames': -1000};
            
        seenPosts = List<int>.from(profile['seenPosts'] ?? []);
        likedPosts = List<int>.from(profile['likedPosts'] ?? []);
        timeSpentTotalMs = profile['timeSpentTotal'] ?? 0;
      } catch (_) {
        _loadDefaultProfileValues(profileId == 'default' ? 'Default' : profileId);
      }
    } else {
      _loadDefaultProfileValues(profileId == 'default' ? 'Default' : profileId);
    }

    sessionPostsScrolled = 0;
    sessionTimeSpentMs = 0;
    postsWithoutLike = 0;
    _lastTimeSpentCheck = DateTime.now();
    await saveSettings();
  }

  void _loadDefaultProfileValues(String name) {
    profileName = name;
    categoryScores = {
      'given names': -1000,
      'surnames': -1000,
    };
    seenPosts = [];
    likedPosts = [];
    timeSpentTotalMs = 0;
  }

  Future<void> saveProfile({bool immediate = false}) async {
    if (!storeData) return;

    if (immediate) {
      _performSave();
    } else {
      _saveTimer?.cancel();
      _saveTimer = Timer(const Duration(seconds: 2), () {
        _performSave();
      });
    }
  }

  Future<void> _performSave() async {
    final profileData = {
      'profileName': profileName,
      'categoryScores': categoryScores,
      'seenPosts': seenPosts,
      'likedPosts': likedPosts,
      'timeSpentTotal': timeSpentTotalMs,
    };
    
    await _prefs.setString('wikimedia_profile_$currentProfileId', jsonEncode(profileData));
  }

  Future<void> saveSettings() async {
    final settingsData = {
      'storeData': storeData,
      'openMainWiki': openMainWiki,
      'theme': theme,
      'currentProfileId': currentProfileId,
      'profiles': profiles,
    };
    await _prefs.setString('wikimedia_settings', jsonEncode(settingsData));
  }

  Future<void> createProfile(String name) async {
    final randomId = Random().nextInt(10000000).toString();
    
    // Save new profile
    final defaultProfile = {
      'profileName': name,
      'categoryScores': {
        'given names': -1000,
        'surnames': -1000,
      },
      'seenPosts': <int>[],
      'likedPosts': <int>[],
      'timeSpentTotal': 0,
    };
    await _prefs.setString('wikimedia_profile_$randomId', jsonEncode(defaultProfile));
    
    profiles.add(randomId);
    await loadProfile(randomId);
  }

  Future<void> deleteProfile(String profileId) async {
    await _prefs.remove('wikimedia_profile_$profileId');
    profiles.remove(profileId);
    
    if (currentProfileId == profileId) {
      if (profiles.isNotEmpty) {
        await loadProfile(profiles.first);
      } else {
        await loadProfile('default');
      }
    } else {
      await saveSettings();
    }
  }

  Future<void> resetAlgorithm() async {
    _loadDefaultProfileValues(profileName);
    sessionPostsScrolled = 0;
    sessionTimeSpentMs = 0;
    postsWithoutLike = 0;
    _lastTimeSpentCheck = DateTime.now();
    await saveProfile();
  }

  Future<void> resetEverything() async {
    // Clear local db
    await DatabaseHelper().clearDatabase();
    DataService().clearCache();

    // Clear preferences
    await _prefs.clear();

    // Reset settings in memory
    storeData = true;
    openMainWiki = true;
    theme = 'auto';
    currentProfileId = 'default';
    profiles = ['default'];
    _loadDefaultProfileValues('Default');

    sessionPostsScrolled = 0;
    sessionTimeSpentMs = 0;
    postsWithoutLike = 0;
    _lastTimeSpentCheck = DateTime.now();
  }

  // Engage/Interact with Posts
  void recordScrollPast(int postId, Set<String> categories) {
    seenPosts.add(postId);
    // Keep seenPosts list manageable (last 5000 items)
    if (seenPosts.length > 5000) {
      seenPosts.removeRange(0, seenPosts.length - 5000);
    }

    sessionPostsScrolled++;
    postsWithoutLike++;

    // Subtract 5 from each category
    for (final cat in categories) {
      categoryScores[cat] = (categoryScores[cat] ?? 0) - 5;
    }
    
    // Track time spent
    final now = DateTime.now();
    final timeSpent = min(10000, now.difference(_lastTimeSpentCheck).inMilliseconds);
    _lastTimeSpentCheck = now;
    timeSpentTotalMs += timeSpent;
    sessionTimeSpentMs += timeSpent;

    saveProfile();
  }

  void recordLike(int postId, Set<String> categories) {
    if (!likedPosts.contains(postId)) {
      likedPosts.add(postId);
    }
    final int scoreReward = 50 + postsWithoutLike * 4;
    postsWithoutLike = 0;

    for (final cat in categories) {
      categoryScores[cat] = (categoryScores[cat] ?? 0) + scoreReward;
    }

    saveProfile();
  }

  void recordUnlike(int postId, Set<String> categories) {
    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
    }
    
    // When unliking, we heavily penalize those categories to refine the algorithm
    for (final cat in categories) {
      categoryScores[cat] = (categoryScores[cat] ?? 0) - 100;
    }

    saveProfile();
  }

  void toggleLike(int postId, Set<String> categories) {
    if (likedPosts.contains(postId)) {
      recordUnlike(postId, categories);
    } else {
      recordLike(postId, categories);
    }
  }

  void recordArticleClick(Set<String> categories) {
    for (final cat in categories) {
      categoryScores[cat] = (categoryScores[cat] ?? 0) + 75;
    }
    saveProfile();
  }

  void recordImageClick(Set<String> categories) {
    for (final cat in categories) {
      categoryScores[cat] = (categoryScores[cat] ?? 0) + 100;
    }
    saveProfile();
  }

  // Profile-specific details formatted
  String getProfileName(String profileId) {
    if (profileId == 'default') return 'Default';
    final profileStr = _prefs.getString('wikimedia_profile_$profileId');
    if (profileStr != null) {
      try {
        final profile = jsonDecode(profileStr);
        return profile['profileName'] ?? profileId;
      } catch (_) {}
    }
    return profileId;
  }
}
