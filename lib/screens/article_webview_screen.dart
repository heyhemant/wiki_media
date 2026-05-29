import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/page_model.dart';
import '../services/profile_service.dart';
import '../utils/design_system.dart';

class ArticleWebViewScreen extends StatefulWidget {
  final String url;
  final WikipediaPage page;

  const ArticleWebViewScreen({
    super.key,
    required this.url,
    required this.page,
  });

  @override
  State<ArticleWebViewScreen> createState() => _ArticleWebViewScreenState();
}

class _ArticleWebViewScreenState extends State<ArticleWebViewScreen> {
  late final WebViewController _controller;
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress > 80 && _isLoading) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Webview Error: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );

    // Enable DOM storage which is often required by modern sites like Wikipedia
    _controller.enableZoom(true);
    
    _controller.loadRequest(Uri.parse(widget.url));
  }

  void _onLikeToggle() {
    setState(() {
      _profileService.toggleLike(widget.page.id, widget.page.allCategories);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isLiked = _profileService.likedPosts.contains(widget.page.id);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.page.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: colors.appBarBackground,
        foregroundColor: colors.appBarForeground,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onLikeToggle,
        backgroundColor: colors.bottomNavBackground,
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? colors.likeColor : colors.iconSecondary,
        ),
      ),
    );
  }
}
