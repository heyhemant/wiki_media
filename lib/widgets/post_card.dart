import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../generated/l10n.dart';
import '../models/page_model.dart';
import '../utils/design_system.dart';

class PostCard extends StatefulWidget {
  final WikipediaPage page;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final VoidCallback onCardTap;
  final VoidCallback onImageTap;

  const PostCard({
    super.key,
    required this.page,
    required this.isLiked,
    required this.onLikeToggle,
    required this.onCardTap,
    required this.onImageTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeAnimController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  void _triggerLikeAnimation() {
    if (!widget.isLiked) {
      _likeAnimController.forward(from: 0.0);
    }
    widget.onLikeToggle();
  }

  void _showImageLightbox(BuildContext context) {
    final colors = AppColors.of(context);
    widget.onImageTap();
    final String imageUrl = 'https://commons.wikimedia.org/w/index.php?title=Special:Redirect/file/${widget.page.thumb!.replaceAll(' ', '_')}';
    
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: InteractiveViewer(
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            elevation: 0,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white, size: 60),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final themeData = Theme.of(context);

    final String? thumbUrl = widget.page.thumb != null && widget.page.thumb!.trim().isNotEmpty
        ? 'https://commons.wikimedia.org/w/index.php?title=Special:Redirect/file/${widget.page.thumb!.replaceAll(' ', '_')}&width=512'
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: colors.cardBackground == Colors.white ? 2 : 0,
      color: colors.cardBackground,
      shadowColor: colors.cardBackground == Colors.white ? Colors.black12 : Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onCardTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Scrollable layout not needed inside Card, use simple Column
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header/Title
              Text(
                widget.page.title,
                style: themeData.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              
              // Text snippet
              Text(
                widget.page.text,
                style: themeData.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              
              // Page categories list tags
              if (widget.page.categories.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: widget.page.categories.take(3).map((cat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.chipBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textDimmed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Optional Image Thumbnail
              if (thumbUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () => _showImageLightbox(context),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      width: double.infinity,
                      color: colors.chipBackground,
                      child: CachedNetworkImage(
                        imageUrl: thumbUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Actions Footer (Like button and read indicator)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).tapCardToRead,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _triggerLikeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Icon(
                        widget.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: widget.isLiked ? colors.likeColor : colors.iconSecondary,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
