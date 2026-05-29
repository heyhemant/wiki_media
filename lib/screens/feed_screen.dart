import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../models/page_model.dart';
import '../services/profile_service.dart';
import '../services/database_helper.dart';
import '../services/feed_algorithm.dart';
import '../utils/design_system.dart';
import '../widgets/post_card.dart';
import 'article_webview_screen.dart';

class FeedScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final VoidCallback onDataReset;

  const FeedScreen({
    super.key,
    required this.onThemeChanged,
    required this.onDataReset,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with AutomaticKeepAliveClientMixin {
  final ProfileService _profileService = ProfileService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FeedAlgorithm _feedAlgorithm = FeedAlgorithm();
  final ScrollController _scrollController = ScrollController();

  final List<WikipediaPage> _loadedPages = [];
  bool _isLoadingNext = false;
  int _maxIndexReached = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _ensureBuffer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Ensures that there are always at least 10 cards ahead of the current scroll position.
  Future<void> _ensureBuffer() async {
    if (_isLoadingNext) return;
    
    // We want to maintain a buffer of ~10 items ahead of what the user has seen.
    const int bufferSize = 7;
    
    while (_loadedPages.length < _maxIndexReached + bufferSize) {
      _isLoadingNext = true;
      try {
        final int nextId = await _feedAlgorithm.getNextPostId();
        final Map<String, dynamic>? pageMap = await _dbHelper.getPage(nextId);
        
        if (pageMap != null) {
          final categories = pageMap['all_categories'].toString().split(',').toSet();
          final page = WikipediaPage.fromSqlMap(pageMap, categories);
          
          if (mounted) {
            setState(() {
              _loadedPages.add(page);
            });
            // We record the impression as soon as it's added to the buffer to ensure
            // the algorithm doesn't pick the same or similar posts for the rest of the buffer.
            _profileService.recordScrollPast(page.id, page.allCategories);
          }
        } else {
          // If for some reason we can't find the page, break to avoid infinite loop
          break;
        }
      } catch (e) {
        debugPrint('Error buffering next post: $e');
        break;
      } finally {
        _isLoadingNext = false;
      }
      
      // Yield to allow UI updates between loads
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _onScroll() {
    // If we've scrolled within 2 screens of the bottom, double-check the buffer
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels < 2000) {
      _ensureBuffer();
    }
  }

  void _onLikeToggle(WikipediaPage page) {
    setState(() {
      _profileService.toggleLike(page.id, page.allCategories);
    });
  }

  void _onCardTap(WikipediaPage page) async {
    _profileService.recordArticleClick(page.allCategories);
    final String lang = _profileService.openMainWiki ? 'en' : 'simple';
    
    // Construct URI properly for mobile Wikipedia
    final String pathTitle = page.title.replaceAll(' ', '_');
    final uri = Uri.https('$lang.m.wikipedia.org', '/wiki/$pathTitle');
    final url = uri.toString();
    
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleWebViewScreen(
          url: url,
          page: page,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _onImageTap(WikipediaPage page) {
    _profileService.recordImageClick(page.allCategories);
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _loadedPages.clear();
      _maxIndexReached = 0;
    });
    await _ensureBuffer();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          S.of(context).appTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
        backgroundColor: colors.appBarBackground,
        elevation: 0.5,
      ),
      body: _loadedPages.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _refreshFeed,
              color: AppColors.primary,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 20),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _loadedPages.length + 1,
                itemBuilder: (context, index) {
                  // Track how far the user has scrolled to maintain the buffer
                  if (index > _maxIndexReached && index < _loadedPages.length) {
                    _maxIndexReached = index;
                    // Trigger buffer check in background
                    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureBuffer());
                  }

                  if (index == _loadedPages.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                  }

                  final page = _loadedPages[index];
                  final isLiked = _profileService.likedPosts.contains(page.id);

                  return PostCard(
                    key: ValueKey(page.id),
                    page: page,
                    isLiked: isLiked,
                    onLikeToggle: () => _onLikeToggle(page),
                    onCardTap: () => _onCardTap(page),
                    onImageTap: () => _onImageTap(page),
                  );
                },
              ),
            ),
    );
  }
}
