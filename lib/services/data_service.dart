import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:brotli/brotli.dart';
import 'database_helper.dart';

typedef DownloadProgressCallback = void Function(int bytesDownloaded, int totalBytes);
typedef ImportProgressCallback = void Function(int itemsImported, int totalItems);
typedef SetupProgressCallback = void Function(double progress, String status);

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  /// List of all page IDs in the database.
  final List<int> allPageIds = [];

  /// Set of all available category names, for picker searching.
  final Set<String> allCategoryNames = {};

  bool _isInitialized = false;
  bool _categoriesLoaded = false;
  bool get isInitialized => _isInitialized;

  Future<bool> isDatabasePopulated() async {
    final count = await DatabaseHelper().getPageCount();
    return count > 0;
  }

  /// Downloads, decompresses, parses, and populates SQLite.
  Future<void> setupDatabase({
    required String downloadUrl,
    required DownloadProgressCallback onDownloadProgress,
    required SetupProgressCallback onSetupProgress,
    required ImportProgressCallback onImportProgress,
  }) async {
    // 1. Download Brotli file chunk-by-chunk to monitor progress
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(downloadUrl));
    final response = await client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to download data: HTTP ${response.statusCode}');
    }

    final contentLength = response.contentLength ?? 228005406; // Fallback size from settings
    final List<int> compressedBytes = [];
    int downloaded = 0;

    await for (final chunk in response.stream) {
      compressedBytes.addAll(chunk);
      downloaded += chunk.length;
      onDownloadProgress(downloaded, contentLength);
    }
    client.close();

    // 2. Decompress and process JSON in a background Isolate
    // We use a manual Isolate to receive progress updates during decompression and processing.
    final receivePort = ReceivePort();
    await Isolate.spawn(_decompressAndProcessIsolateWithProgress, {
      'sendPort': receivePort.sendPort,
      'compressedBytes': compressedBytes,
    });

    Map<String, dynamic>? processedData;
    final completer = Completer<void>();

    receivePort.listen((message) {
      if (message is Map) {
        if (message.containsKey('progress')) {
          onSetupProgress(message['progress'] as double, message['status'] as String);
        } else if (message.containsKey('result')) {
          processedData = message['result'] as Map<String, dynamic>;
          receivePort.close();
          completer.complete();
        } else if (message.containsKey('error')) {
          receivePort.close();
          completer.completeError(message['error']);
        }
      }
    });

    await completer.future;

    if (processedData == null) {
      throw Exception('Failed to process data: result was null');
    }
    
    final List<Map<String, dynamic>> pageMaps = List<Map<String, dynamic>>.from(processedData!['pages']);
    
    // 3. Batch import rows into SQLite database on the main thread
    final dbHelper = DatabaseHelper();
    await dbHelper.clearDatabase(); // Clean slate

    final total = pageMaps.length;
    const batchSize = 5000;
    
    for (int i = 0; i < total; i += batchSize) {
      final end = (i + batchSize < total) ? i + batchSize : total;
      final batch = pageMaps.sublist(i, end);
      await dbHelper.insertPagesBulk(batch);
      onImportProgress(end, total);
    }
  }

  /// Minimal initialization. Category names are lazy-loaded when needed.
  Future<void> initializeScoringCache() async {
    _isInitialized = true;
  }

  /// Lazy loads category names for the search/picker UI.
  Future<void> loadCategoryNames() async {
    if (_categoriesLoaded) return;
    
    final dbHelper = DatabaseHelper();
    final categoryData = await dbHelper.getAllCategoryStrings();
    
    allCategoryNames.clear();
    for (final row in categoryData) {
      final String catsStr = row['categories'] as String;
      if (catsStr.isEmpty) continue;
      
      final List<String> cats = catsStr.split(',');
      for (final cat in cats) {
        final trimmed = cat.trim();
        if (trimmed.isNotEmpty) {
          allCategoryNames.add(trimmed);
        }
      }
    }
    _categoriesLoaded = true;
  }

  void clearCache() {
    allPageIds.clear();
    allCategoryNames.clear();
    _isInitialized = false;
    _categoriesLoaded = false;
  }
}

/// Run inside background Isolate: Handles Brotli decompression, JSON decoding,
/// and computes the recursive categories mapping.
void _decompressAndProcessIsolateWithProgress(Map<String, dynamic> params) {
  final SendPort sendPort = params['sendPort'];
  final List<int> compressedBytes = params['compressedBytes'];

  try {
    // 1. Decompress Brotli with chunked progress
    sendPort.send({'progress': 0.0, 'status': 'Starting decompression...'});
    
    final List<int> decompressed = [];
    final outputSink = ByteConversionSink.withCallback((result) {
      decompressed.addAll(result);
    });
    final inputSink = const BrotliDecoder().startChunkedConversion(outputSink);
    
    const int chunkSize = 1024 * 1024; // 1MB chunks
    for (int i = 0; i < compressedBytes.length; i += chunkSize) {
      final end = (i + chunkSize < compressedBytes.length) ? i + chunkSize : compressedBytes.length;
      inputSink.add(compressedBytes.sublist(i, end));
      
      final progress = end / compressedBytes.length * 0.4; // First 40% is decompression
      sendPort.send({'progress': progress, 'status': 'Decompressing Brotli dataset...'});
    }
    inputSink.close();
    
    // 2. Decode UTF-8 string
    sendPort.send({'progress': 0.45, 'status': 'Decoding UTF-8 text...'});
    final jsonString = utf8.decode(decompressed);
    
    // 3. JSON decode
    sendPort.send({'progress': 0.5, 'status': 'Parsing JSON structures...'});
    final rawData = jsonDecode(jsonString) as Map<String, dynamic>;

    final List<dynamic> rawPages = rawData['pages'] as List<dynamic>;
    final Map<String, dynamic> subCategories = rawData['subCategories'] as Map<String, dynamic>;

    final recursiveCache = <String, Set<String>>{};

    Set<String> computeTransitiveCategories(List<dynamic> initialCats) {
      final Set<String> allCats = Set<String>.from(initialCats.map((e) => e.toString().toLowerCase().trim()));
      final List<String> pendingQueue = allCats.toList();

      for (int i = 0; i < pendingQueue.length; i++) {
        final cat = pendingQueue[i];
        final subs = List<String>.from(subCategories[cat] ?? []);
        if (subs.isEmpty) continue;

        Set<String>? cachedVal = recursiveCache[cat];
        if (cachedVal == null) {
          recursiveCache[cat] = {};
          cachedVal = _recursiveCategoriesHelper(subCategories, subs, recursiveCache);
          recursiveCache[cat] = cachedVal;
        }
        
        for (final sub in subs) {
          if (allCats.add(sub)) pendingQueue.add(sub);
        }
        for (final cacheCat in cachedVal) {
          if (allCats.add(cacheCat)) pendingQueue.add(cacheCat);
        }
      }
      return allCats;
    }

    final List<Map<String, dynamic>> preparedPages = [];

    // 4. Processing loop with progress
    for (int i = 0; i < rawPages.length; i++) {
      final rawPage = rawPages[i];
      final String title = rawPage[0] as String;
      final int id = rawPage[1] as int;
      final String text = rawPage[2] as String;
      final String? thumb = rawPage[3] as String?;
      final List<dynamic> categories = rawPage[4] as List<dynamic>;
      final List<dynamic> links = rawPage[5] as List<dynamic>;

      final Set<String> computedAllCategories = computeTransitiveCategories(categories);
      computedAllCategories.add('p:$id');
      for (final linkId in links) {
        computedAllCategories.add('p:$linkId');
      }

      preparedPages.add({
        'id': id,
        'title': title,
        'text': text,
        'thumb': thumb,
        'categories': categories.join(','),
        'links': links.join(','),
        'all_categories': computedAllCategories.join(','),
      });

      // Report progress every 500 items (final 50% of progress bar)
      if (i % 500 == 0 || i == rawPages.length - 1) {
        final loopProgress = 0.5 + (i / rawPages.length * 0.5);
        sendPort.send({
          'progress': loopProgress,
          'status': 'Processing pages: $i of ${rawPages.length}'
        });
      }
    }

    sendPort.send({
      'result': {'pages': preparedPages}
    });
  } catch (e) {
    sendPort.send({'error': e.toString()});
  }
}

/// Recursively traverses categories to find child-parent relationships.
Set<String> _recursiveCategoriesHelper(
  Map<String, dynamic> subCategories,
  List<String> categories,
  Map<String, Set<String>> cache,
) {
  final Set<String> allCategories = Set<String>.from(categories.map((e) => e.toLowerCase()));
  final List<String> list = allCategories.toList();

  for (final cat in list) {
    final subs = List<String>.from(subCategories[cat] ?? []);
    if (subs.isEmpty) continue;

    Set<String>? cachedVal = cache[cat];
    if (cachedVal == null) {
      cache[cat] = {}; // break cycle
      cachedVal = _recursiveCategoriesHelper(subCategories, subs, cache);
      cache[cat] = cachedVal;
    }
    
    allCategories.addAll(subs);
    allCategories.addAll(cachedVal);
  }
  
  return allCategories;
}
