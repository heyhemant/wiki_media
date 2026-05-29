import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/profile_service.dart';
import 'services/data_service.dart';
import 'screens/start_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'generated/l10n.dart';
import 'utils/design_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WikiMediaApp());
}

class WikiMediaApp extends StatefulWidget {
  const WikiMediaApp({super.key});

  @override
  State<WikiMediaApp> createState() => _WikiMediaAppState();
}

class _WikiMediaAppState extends State<WikiMediaApp> {
  final ProfileService _profileService = ProfileService();
  
  // Keep key to force re-render on reset/re-initialization
  Key _appKey = UniqueKey();

  void _updateTheme() {
    setState(() {
      // Just trigger a rebuild of the MaterialApp to pick up the new themeMode
    });
  }

  void _resetApp() {
    setState(() {
      _appKey = UniqueKey();
    });
  }

  ThemeMode _getThemeMode() {
    switch (_profileService.theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'auto':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: _appKey,
      onGenerateTitle: (context) => S.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.scaffoldLight,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.scaffoldDark,
        useMaterial3: true,
      ),
      themeMode: _getThemeMode(),
      home: AppBootstrap(
        onThemeChanged: _updateTheme,
        onDataReset: _resetApp,
      ),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final VoidCallback onDataReset;

  const AppBootstrap({
    super.key,
    required this.onThemeChanged,
    required this.onDataReset,
  });

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

enum AppState {
  checking,
  needsDownload,
  downloading,
  decompressing,
  importing,
  initializingCache,
  pickInterests,
  showFeed,
  error
}

class _AppBootstrapState extends State<AppBootstrap> {
  final DataService _dataService = DataService();
  final ProfileService _profileService = ProfileService();
  
  AppState _state = AppState.checking;
  double _downloadProgress = 0.0;
  int _downloadedBytes = 0;
  int _totalBytesToDownload = 0;
  
  int _importedCount = 0;
  int _totalImportItems = 0;
  
  bool _hasLaunched = false;
  
  double _setupProgress = 0.0;
  String _setupStatus = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _state = AppState.checking;
    });

    try {
      // Initialize profile service in the background during bootstrap
      await _profileService.init();

      final isPopulated = await _dataService.isDatabasePopulated();
      if (!isPopulated) {
        setState(() {
          _state = AppState.needsDownload;
        });
      } else {
        _initializeCacheAndProceed();
      }
    } catch (e) {
      setState(() {
        _state = AppState.error;
        _errorMessage = 'Database verification error: $e';
      });
    }
  }

  Future<void> _initializeCacheAndProceed() async {
    setState(() {
      _state = AppState.initializingCache;
    });

    try {
      await _dataService.initializeScoringCache();
      
      setState(() {
        // If user has not seen any posts yet, show the interest selection screen
        if (_profileService.seenPosts.isEmpty) {
          _state = AppState.pickInterests;
        } else {
          _state = AppState.showFeed;
        }
      });
    } catch (e) {
      setState(() {
        _state = AppState.error;
        _errorMessage = 'Failed to load recommendation cache: $e';
      });
    }
  }

  Future<void> _startDatabaseDownload() async {
    setState(() {
      _state = AppState.downloading;
      _downloadProgress = 0.0;
      _downloadedBytes = 0;
      _totalBytesToDownload = 0;
      _setupProgress = 0.0;
      _setupStatus = '';
      _errorMessage = '';
    });

    try {
      // URL pointing to the production dataset (35MB)
      const downloadUrl = 'https://github.com/heyhemant/wiki_media/releases/download/v1.0.0/smoldata.json.br';

      _hasLaunched = false;

      await _dataService.setupDatabase(
        downloadUrl: downloadUrl,
        onDownloadProgress: (downloaded, total) {
          if (!mounted) return;
          setState(() {
            _downloadedBytes = downloaded;
            _totalBytesToDownload = total;
            _downloadProgress = total > 0 ? downloaded / total : 0.0;
            
            if (downloaded == total) {
              _state = AppState.decompressing;
            }
          });
        },
        onSetupProgress: (progress, status) {
          if (!mounted || _hasLaunched) return;
          setState(() {
            _setupProgress = progress;
            _setupStatus = status;
          });
        },
        onImportProgress: (imported, total) {
          if (!mounted) return;
          setState(() {
            _importedCount = imported;
            _totalImportItems = total;
            if (!_hasLaunched) {
              _state = AppState.importing;
            }
          });
        },
      );

      if (mounted) {
        setState(() {
          _hasLaunched = true;
        });
        await _initializeCacheAndProceed();
      }
    } catch (e) {
      setState(() {
        _state = AppState.error;
        _errorMessage = 'Download or setup failed: $e\nMake sure you have active internet connectivity.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case AppState.checking:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
        
      case AppState.needsDownload:
        return _buildDownloadPrompt();
        
      case AppState.downloading:
      case AppState.decompressing:
      case AppState.importing:
        return _buildSetupProgress();
        
      case AppState.initializingCache:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(S.of(context).preparingFeed, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
        
      case AppState.pickInterests:
        return StartScreen(
          onStart: () {
            setState(() {
              _state = AppState.showFeed;
            });
          },
        );
        
      case AppState.showFeed:
        return MainNavigationScreen(
          onThemeChanged: widget.onThemeChanged,
          onDataReset: widget.onDataReset,
        );
        
      case AppState.error:
        return _buildErrorScreen();
    }
  }

  Widget _buildDownloadPrompt() {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.download_for_offline, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                S.of(context).dataSetupRequired,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                S.of(context).dataSetupDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).downloadSize,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  onPressed: _startDatabaseDownload,
                  child: Text(S.of(context).downloadAndSetup, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupProgress() {
    String statusTitle = S.of(context).settingUpDatabase;
    String statusSubtitle = S.of(context).keepAppOpen;
    double? progressValue;

    if (_state == AppState.downloading) {
      statusTitle = S.of(context).downloadingDatabase;
      final mbDownloaded = (_downloadedBytes / 1024 / 1024).toStringAsFixed(1);
      final mbTotal = (_totalBytesToDownload / 1024 / 1024).toStringAsFixed(1);
      statusSubtitle = S.of(context).downloadedProgress(mbDownloaded, mbTotal);
      progressValue = _downloadProgress;
    } else if (_state == AppState.decompressing) {
      statusTitle = S.of(context).processingDataset;
      statusSubtitle = _setupStatus.isEmpty ? S.of(context).preparingFiles : _setupStatus;
      progressValue = _setupProgress;
    } else if (_state == AppState.importing) {
      statusTitle = S.of(context).importingArticles;
      final percent = (_totalImportItems > 0) ? (_importedCount / _totalImportItems * 100).toStringAsFixed(0) : '0';
      statusSubtitle = S.of(context).writingToCache(_importedCount.toString(), _totalImportItems.toString(), percent);
      progressValue = (_totalImportItems > 0) ? _importedCount / _totalImportItems : 0.0;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storage_outlined, size: 60, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              statusTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              statusSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 32),
            if (progressValue != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 10,
                  backgroundColor: Colors.white12,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(progressValue * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ] else ...[
              const CircularProgressIndicator(color: AppColors.primary),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 24),
            Text(
              S.of(context).somethingWentWrong,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, height: 1.4),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: _checkStatus,
                child: Text(S.of(context).tryAgain, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
