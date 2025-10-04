import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/social_post_model.dart';
import '../../core/theme/app_theme.dart';

class SocialPostCard extends StatefulWidget {
  final SocialPostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRetweet;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const SocialPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onRetweet,
    this.onBookmark,
    this.onShare,
  });

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });

    if (_isLiked) {
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
      });
    }

    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.darkSurface
        : AppTheme.lightSurface;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryTextColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and timestamp
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.accentBlue.withOpacity(0.1),
                  backgroundImage: widget.post.userAvatarUrl != null
                      ? CachedNetworkImageProvider(widget.post.userAvatarUrl!)
                      : null,
                  child: widget.post.userAvatarUrl == null
                      ? Text(
                          widget.post.username.isNotEmpty
                              ? widget.post.username[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.inter(
                            color: AppTheme.accentBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Username and handle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.post.username,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.post.userHandle,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.post.timeAgo,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // More options
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                  onPressed: () {
                    // TODO: Show post options
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content
            if (widget.post.content.isNotEmpty) ...[
              Text(
                widget.post.content,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: textColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Post image
            if (widget.post.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: widget.post.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: borderColor.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: borderColor.withOpacity(0.3),
                      child: Icon(
                        Icons.error_outline,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              children: [
                // Comment button
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  count: widget.post.commentCount,
                  onTap: widget.onComment,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 24),

                // Retweet button
                _ActionButton(
                  icon: Icons.repeat,
                  count: widget.post.retweetCount,
                  onTap: widget.onRetweet,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 24),

                // Like button
                AnimatedBuilder(
                  animation: _likeAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _likeAnimation.value,
                      child: _ActionButton(
                        icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                        count: widget.post.likeCount + (_isLiked ? 1 : 0),
                        onTap: _handleLike,
                        color: _isLiked ? Colors.red : secondaryTextColor,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),

                // Bookmark button
                _ActionButton(
                  icon: Icons.bookmark_border,
                  count: widget.post.bookmarkCount,
                  onTap: widget.onBookmark,
                  color: secondaryTextColor,
                ),

                const Spacer(),

                // Share button
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                  onPressed: widget.onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.count,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}











