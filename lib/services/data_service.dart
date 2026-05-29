import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:brotli/brotli.dart';
import 'package:path/path.dart' as p;
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
    final client = http.Client();
    final tempDir = await Directory.systemTemp.createTemp('wikimedia_dataset_');
    final compressedFile = File(p.join(tempDir.path, 'dataset.br'));
    final decompressedFile = File(p.join(tempDir.path, 'dataset.json'));

    final receivePort = ReceivePort();
    final readyCompleter = Completer<void>();
    var cleanupDone = false;
    var imported = 0;
    var totalPages = 0;

    Future<void> cleanup() async {
      if (cleanupDone) return;
      cleanupDone = true;
      try {
        client.close();
        if (await compressedFile.exists()) {
          await compressedFile.delete();
        }
        if (await decompressedFile.exists()) {
          await decompressedFile.delete();
        }
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (_) {
        // Ignore cleanup failures.
      }
    }

    final dbHelper = DatabaseHelper();

    late final StreamSubscription subscription;
    subscription = receivePort.listen((rawMessage) async {
      if (rawMessage is! Map<String, dynamic>) {
        return;
      }

      if (rawMessage.containsKey('error')) {
        final errorMessage = rawMessage['error'] as String;
        if (!readyCompleter.isCompleted) {
          readyCompleter.completeError(Exception(errorMessage));
        }
        await cleanup();
        await subscription.cancel();
        receivePort.close();
        return;
      }

      if (rawMessage['readyToLaunch'] == true) {
        if (!readyCompleter.isCompleted) {
          readyCompleter.complete();
        }
      }

      if (rawMessage.containsKey('progress')) {
        onSetupProgress(rawMessage['progress'] as double, rawMessage['status'] as String);
      }

      if (rawMessage.containsKey('totalPages')) {
        totalPages = rawMessage['totalPages'] as int;
      }

      if (rawMessage.containsKey('pages')) {
        final batch = List<Map<String, dynamic>>.from(rawMessage['pages'] as List<dynamic>);
        await dbHelper.insertPagesBulk(batch);
        imported += batch.length;
        onImportProgress(imported, totalPages > 0 ? totalPages : imported);
      }

      if (rawMessage['done'] == true) {
        if (!readyCompleter.isCompleted) {
          readyCompleter.complete();
        }
        await cleanup();
        await subscription.cancel();
        receivePort.close();
      }
    });

    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        await cleanup();
        throw Exception('Failed to download data: HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      int downloaded = 0;
      final compressedSink = compressedFile.openWrite();

      await for (final chunk in response.stream) {
        compressedSink.add(chunk);
        downloaded += chunk.length;
        onDownloadProgress(downloaded, contentLength);
      }

      await compressedSink.close();

      final dbHelper = DatabaseHelper();
      await dbHelper.clearDatabase();

      await Isolate.spawn(_decompressAndProcessIsolateWithProgress, {
        'sendPort': receivePort.sendPort,
        'compressedFilePath': compressedFile.path,
        'decompressedFilePath': decompressedFile.path,
      });

      await readyCompleter.future;
    } catch (e) {
      await cleanup();
      rethrow;
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

/// Run inside a background isolate: Downloads, decompresses, and processes
/// the dataset without keeping the full JSON payload in memory.
Future<void> _decompressAndProcessIsolateWithProgress(Map<String, dynamic> params) async {
  final SendPort sendPort = params['sendPort'] as SendPort;
  final String compressedFilePath = params['compressedFilePath'] as String;
  final String decompressedFilePath = params['decompressedFilePath'] as String;

  try {
    sendPort.send({'progress': 0.0, 'status': 'Starting decompression...'});

    final compressedFile = File(compressedFilePath);
    final decompressedFile = File(decompressedFilePath);
    final raf = decompressedFile.openSync(mode: FileMode.write);

    try {
      final outputSink = ByteConversionSink.withCallback((result) {
        raf.writeFromSync(result);
      });
      final inputSink = const BrotliDecoder().startChunkedConversion(outputSink);

      await for (final chunk in compressedFile.openRead()) {
        inputSink.add(chunk);
      }

      inputSink.close();
    } finally {
      raf.close();
    }

    sendPort.send({'progress': 0.3, 'status': 'Reading category metadata...'});
    final pageProcessor = _PageJsonProcessor(decompressedFile, sendPort);
    final subCategories = await pageProcessor.extractSubCategories();

    sendPort.send({'progress': 0.45, 'status': 'Processing pages...'});
    await pageProcessor.processPages(subCategories);
  } catch (e) {
    sendPort.send({'error': e.toString()});
  }
}

class _PageJsonProcessor {
  final File file;
  final SendPort sendPort;

  _PageJsonProcessor(this.file, this.sendPort);

  Future<Map<String, dynamic>> extractSubCategories() async {
    final stream = file.openRead().transform(utf8.decoder);
    final reader = _JsonTextReader(stream);

    await reader.skipWhitespace();
    await reader.expectChar('{');

    while (true) {
      await reader.skipWhitespace();
      final next = await reader.peekChar();
      if (next == null) {
        throw Exception('Unexpected end of dataset while reading top-level object.');
      }
      if (next == '}') {
        await reader.readChar();
        break;
      }

      if (next != ',') {
        final rawKey = await reader.readRawValue();
        final key = jsonDecode(rawKey) as String;
        await reader.skipWhitespace();
        await reader.expectChar(':');
        await reader.skipWhitespace();

        if (key == 'subCategories') {
          final rawValue = await reader.readRawValue();
          final subCategories = jsonDecode(rawValue) as Map<String, dynamic>;
          return subCategories;
        }

        await reader.skipValue();
      } else {
        await reader.readChar();
      }
    }

    throw Exception('subCategories not found in dataset');
  }

  Future<void> processPages(Map<String, dynamic> subCategories) async {
    final stream = file.openRead().transform(utf8.decoder);
    final reader = _JsonTextReader(stream);

    await reader.skipWhitespace();
    await reader.expectChar('{');

    while (true) {
      await reader.skipWhitespace();
      final next = await reader.peekChar();
      if (next == null) {
        throw Exception('Unexpected end of dataset while reading top-level object.');
      }
      if (next == '}') {
        await reader.readChar();
        break;
      }

      if (next != ',') {
        final rawKey = await reader.readRawValue();
        final key = jsonDecode(rawKey) as String;
        await reader.skipWhitespace();
        await reader.expectChar(':');
        await reader.skipWhitespace();

        if (key == 'pages') {
          await reader.expectChar('[');
          await _readPagesArray(reader, subCategories);
          return;
        }

        await reader.skipValue();
      } else {
        await reader.readChar();
      }
    }

    throw Exception('pages not found in dataset');
  }

  Future<void> _readPagesArray(_JsonTextReader reader, Map<String, dynamic> subCategories) async {
    const batchSize = 1000;
    const startupBatchThreshold = 1000;
    final List<Map<String, dynamic>> batch = [];
    bool first = true;
    bool readySent = false;
    int processed = 0;

    while (true) {
      await reader.skipWhitespace();
      final next = await reader.peekChar();
      if (next == null) {
        throw Exception('Unexpected end of dataset while reading pages array.');
      }
      if (next == ']') {
        await reader.readChar();
        break;
      }

      if (!first) {
        await reader.expectChar(',');
        await reader.skipWhitespace();
      }
      first = false;

      final rawPage = await reader.readRawValue();
      final rawPageList = jsonDecode(rawPage) as List<dynamic>;
      final pageMap = _buildPageMap(rawPageList, subCategories);
      batch.add(pageMap);
      processed += 1;

      if (batch.length >= batchSize) {
        sendPort.send({'pages': batch.toList()});
        batch.clear();
      }

      if (!readySent && processed >= startupBatchThreshold) {
        sendPort.send({'readyToLaunch': true});
        readySent = true;
      }

      if (processed % 500 == 0) {
        sendPort.send({'progress': 0.5, 'status': 'Processed $processed pages...'});
      }
    }

    if (batch.isNotEmpty) {
      sendPort.send({'pages': batch.toList()});
    }

    if (!readySent) {
      sendPort.send({'readyToLaunch': true});
    }

    sendPort.send({'totalPages': processed});
    sendPort.send({'done': true});
  }

  Map<String, dynamic> _buildPageMap(List<dynamic> rawPage, Map<String, dynamic> subCategories) {
    final String title = rawPage[0] as String;
    final int id = rawPage[1] as int;
    final String text = rawPage[2] as String;
    final String? thumb = rawPage[3] as String?;
    final List<dynamic> categories = rawPage[4] as List<dynamic>;
    final List<dynamic> links = rawPage[5] as List<dynamic>;

    final Set<String> computedAllCategories = _computeTransitiveCategories(categories, subCategories);
    computedAllCategories.add('p:$id');
    for (final linkId in links) {
      computedAllCategories.add('p:$linkId');
    }

    return {
      'id': id,
      'title': title,
      'text': text,
      'thumb': thumb,
      'categories': categories.join(','),
      'links': links.join(','),
      'all_categories': computedAllCategories.join(','),
    };
  }

  Set<String> _computeTransitiveCategories(List<dynamic> initialCats, Map<String, dynamic> subCategories) {
    final recursiveCache = <String, Set<String>>{};
    final Set<String> allCats = Set<String>.from(
      initialCats.map((e) => e.toString().toLowerCase().trim()),
    );
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
}

class _JsonTextReader {
  final StreamIterator<String> _iterator;
  String _buffer = '';
  int _position = 0;
  bool _done = false;

  _JsonTextReader(Stream<String> stream) : _iterator = StreamIterator(stream);

  Future<bool> _ensure(int count) async {
    while (_buffer.length - _position < count) {
      if (_done) return false;
      final hasNext = await _iterator.moveNext();
      if (!hasNext) {
        _done = true;
        return _buffer.length - _position >= count;
      }
      _buffer = _buffer.substring(_position) + _iterator.current;
      _position = 0;
    }
    return true;
  }

  Future<String?> peekChar() async {
    final hasChar = await _ensure(1);
    if (!hasChar) return null;
    return _buffer[_position];
  }

  Future<String> readChar() async {
    final hasChar = await _ensure(1);
    if (!hasChar) {
      throw StateError('Unexpected end of stream');
    }
    final char = _buffer[_position];
    _position += 1;
    return char;
  }

  Future<void> skipWhitespace() async {
    while (true) {
      final char = await peekChar();
      if (char == null) return;
      if (char.trim().isEmpty) {
        await readChar();
        continue;
      }
      return;
    }
  }

  Future<void> expectChar(String expected) async {
    final char = await readChar();
    if (char != expected) {
      throw FormatException('Expected "$expected" but found "$char"');
    }
  }

  Future<String> readRawValue() async {
    await skipWhitespace();
    final next = await peekChar();
    if (next == null) {
      throw FormatException('Unexpected end of stream while reading value');
    }

    if (next == '{' || next == '[' || next == '"') {
      return await _readDelimited(next, next == '"' ? '"' : (next == '{' ? '}' : ']'));
    }

    final buffer = StringBuffer();
    while (true) {
      final char = await peekChar();
      if (char == null || char == ',' || char == ']' || char == '}' || char.trim().isEmpty) {
        break;
      }
      buffer.write(await readChar());
    }
    return buffer.toString();
  }

  Future<void> skipValue() async {
    await readRawValue();
  }

  Future<String> _readDelimited(String opener, String closer) async {
    final buffer = StringBuffer();
    final bool isString = opener == '"';
    bool inString = false;
    bool escaped = false;
    int depth = 0;

    if (isString) {
      await expectChar('"');
      buffer.write('"');
      while (true) {
        final char = await readChar();
        buffer.write(char);
        if (escaped) {
          escaped = false;
          continue;
        }
        if (char == '\\') {
          escaped = true;
          continue;
        }
        if (char == '"') {
          break;
        }
      }
      return buffer.toString();
    }

    await expectChar(opener);
    buffer.write(opener);
    depth = 1;

    while (true) {
      final char = await readChar();
      buffer.write(char);
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (char == '\\') {
          escaped = true;
        } else if (char == '"') {
          inString = false;
        }
        continue;
      }

      if (char == '"') {
        inString = true;
      } else if (char == opener) {
        depth += 1;
      } else if (char == closer) {
        depth -= 1;
        if (depth == 0) {
          break;
        }
      }
    }

    return buffer.toString();
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
