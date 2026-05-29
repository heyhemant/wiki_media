import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../services/profile_service.dart';
import '../services/database_helper.dart';
import '../models/page_model.dart';
import '../utils/design_system.dart';
import 'article_webview_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final ProfileService _profileService = ProfileService();
  late TabController _tabController;
  
  bool _isLoadingLiked = true;
  List<Map<String, dynamic>> _likedPostsData = [];
  Map<int, String> _pageTitleMap = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLikedPostsAndResolveTitles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLikedPostsAndResolveTitles() async {
    setState(() {
      _isLoadingLiked = true;
    });

    final dbHelper = DatabaseHelper();
    
    // 1. Load liked posts
    if (_profileService.likedPosts.isNotEmpty) {
      _likedPostsData = await dbHelper.getPagesByIds(_profileService.likedPosts);
    } else {
      _likedPostsData = [];
    }

    // 2. Resolve titles for any 'p:id' categories in top/bottom scores
    final Set<int> pageIdsToResolve = {};
    final activeCategories = _profileService.categoryScores.keys;
    for (final cat in activeCategories) {
      if (cat.startsWith('p:')) {
        final id = int.tryParse(cat.substring(2));
        if (id != null) {
          pageIdsToResolve.add(id);
        }
      }
    }

    if (pageIdsToResolve.isNotEmpty) {
      final resolved = await dbHelper.getPagesByIds(pageIdsToResolve.toList());
      _pageTitleMap = {
        for (final row in resolved) row['id'] as int: row['title'] as String
      };
    }

    if (mounted) {
      setState(() {
        _isLoadingLiked = false;
      });
    }
  }

  String _formatTime(int ms) {
    final int totalSecs = ms ~/ 1000;
    final int hours = totalSecs ~/ 3600;
    final int minutes = (totalSecs % 3600) ~/ 60;
    final int seconds = totalSecs % 60;

    if (hours > 0) {
      return '$hours hour${hours == 1 ? '' : 's'}, $minutes minute${minutes == 1 ? '' : 's'}';
    } else if (minutes > 0) {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    } else {
      return '$seconds second${seconds == 1 ? '' : 's'}';
    }
  }

  String _formatCatName(String cat) {
    if (cat.startsWith('p:')) {
      final id = int.tryParse(cat.substring(2));
      if (id != null) {
        return S.of(context).article(_pageTitleMap[id] ?? "Page $id");
      }
    }
    return cat;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final colors = AppColors.of(context);

    // Filter non-zero scores and sort
    final sortedScores = _profileService.categoryScores.entries
        .where((e) => e.value != 0)
        .toList();
        
    final topCategories = List<MapEntry<String, int>>.from(sortedScores)
      ..sort((a, b) => b.value.compareTo(a.value));
      
    final bottomCategories = List<MapEntry<String, int>>.from(sortedScores)
      ..sort((a, b) => a.value.compareTo(b.value));

    final top100 = topCategories.take(100).toList();
    final bottom100 = bottomCategories.take(100).toList();

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(S.of(context).stats, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: colors.appBarBackground,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: S.of(context).general),
            Tab(text: S.of(context).categories),
            Tab(text: S.of(context).liked),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: General Stats
          _buildGeneralTab(colors),

          // Tab 2: Category lists (Top & Bottom collapsible)
          _buildCategoriesTab(top100, bottom100),

          // Tab 3: Liked Posts
          _buildLikedTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow(S.of(context).postsScrolledTotal, '${_profileService.seenPosts.length}'),
          _buildStatRow(S.of(context).postsScrolledSession, '${_profileService.sessionPostsScrolled}'),
          _buildStatRow(S.of(context).timeSpentTotal, _formatTime(_profileService.timeSpentTotalMs)),
          _buildStatRow(S.of(context).timeSpentSession, _formatTime(_profileService.sessionTimeSpentMs)),
          const SizedBox(height: 32),
          Text(
            S.of(context).scoringMechanism,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.chipBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              S.of(context).scoringDesc,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(List<MapEntry<String, int>> top, List<MapEntry<String, int>> bottom) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        ExpansionTile(
          initiallyExpanded: true,
          title: Text(S.of(context).topCategories, style: const TextStyle(fontWeight: FontWeight.bold)),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: top.isEmpty 
              ? [Padding(padding: const EdgeInsets.all(16), child: Text(S.of(context).noRecords))]
              : top.map((e) => _buildCategoryScoreRow(e.key, e.value)).toList(),
        ),
        ExpansionTile(
          title: Text(S.of(context).bottomCategories, style: const TextStyle(fontWeight: FontWeight.bold)),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: bottom.isEmpty 
              ? [Padding(padding: const EdgeInsets.all(16), child: Text(S.of(context).noRecords))]
              : bottom.map((e) => _buildCategoryScoreRow(e.key, e.value)).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryScoreRow(String name, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _formatCatName(name),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${score > 0 ? "+" : ""}$score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: score > 0 ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikedTab() {
    if (_isLoadingLiked) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_likedPostsData.isEmpty) {
      return Center(
        child: Text(S.of(context).noLikedArticles),
      );
    }

    return ListView.builder(
      itemCount: _likedPostsData.length,
      itemBuilder: (context, index) {
        final post = _likedPostsData[index];
        final title = post['title'] as String;
        
        return ListTile(
          leading: const Icon(Icons.favorite, color: Colors.red),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () async {
            final String lang = _profileService.openMainWiki ? 'en' : 'simple';
            final String pathTitle = title.replaceAll(' ', '_');
            final uri = Uri.https('$lang.m.wikipedia.org', '/wiki/$pathTitle');
            final url = uri.toString();
            
            final fullPageMap = await DatabaseHelper().getPage(post['id'] as int);
            if (fullPageMap == null || !mounted) return;

            final categories = fullPageMap['all_categories'].toString().split(',').toSet();
            final page = WikipediaPage.fromSqlMap(fullPageMap, categories);
            
            if (!context.mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleWebViewScreen(
                  url: url,
                  page: page,
                ),
              ),
            ).then((_) {
              if (mounted) {
                _loadLikedPostsAndResolveTitles();
              }
            });
          },
        );
      },
    );
  }
}
