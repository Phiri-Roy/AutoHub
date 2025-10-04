import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/social_post_model.dart';
import '../../widgets/social_post_card.dart';

class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Sample data for demonstration
  final List<SocialPostModel> _samplePosts = [
    SocialPostModel(
      id: '1',
      content:
          'Just finished an amazing road trip through the mountains! The views were absolutely breathtaking. 🏔️✨',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=450&fit=crop',
      postedBy: 'user1',
      username: 'Alex Johnson',
      userHandle: '@alexjohnson',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      likes: ['user2', 'user3'],
      comments: [],
      retweets: ['user4'],
      bookmarks: [],
    ),
    SocialPostModel(
      id: '2',
      content:
          'Working on some exciting new features for the app. Can\'t wait to share them with you all! 🚀',
      postedBy: 'user2',
      username: 'Sarah Chen',
      userHandle: '@sarahchen',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: ['user1', 'user3', 'user5'],
      comments: [],
      retweets: [],
      bookmarks: ['user1'],
    ),
    SocialPostModel(
      id: '3',
      content:
          'Beautiful sunset from my balcony tonight. Sometimes the simplest moments are the most precious. 🌅',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=450&fit=crop',
      postedBy: 'user3',
      username: 'Mike Rodriguez',
      userHandle: '@mikerodriguez',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      likes: ['user1', 'user2', 'user4', 'user6'],
      comments: [],
      retweets: ['user2'],
      bookmarks: [],
    ),
    SocialPostModel(
      id: '4',
      content:
          'Coffee and code - the perfect combination for a productive morning! ☕️💻',
      postedBy: 'user4',
      username: 'Emma Wilson',
      userHandle: '@emmawilson',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      likes: ['user1', 'user3', 'user5'],
      comments: [],
      retweets: [],
      bookmarks: ['user2', 'user3'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start FAB animation
    _fabAnimationController.forward();

    // Listen to scroll for FAB visibility
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 100) {
      _fabAnimationController.reverse();
    } else {
      _fabAnimationController.forward();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  void _onCompose() {
    // TODO: Navigate to compose screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compose feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryTextColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.accentBlue.withOpacity(0.1),
            backgroundImage: const CachedNetworkImageProvider(
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
            ),
            child: null,
          ),
        ),
        title: Text(
          'Feed',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.star_outline, color: secondaryTextColor),
            onPressed: () {
              // TODO: Show filters or favorites
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.accentBlue,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Shimmer loading effect
            if (_isLoading)
              SliverToBoxAdapter(child: _buildShimmerLoading())
            else
              // Posts list
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = _samplePosts[index];
                  return SocialPostCard(
                    post: post,
                    onLike: () {
                      // TODO: Handle like
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Liked ${post.username}\'s post'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onComment: () {
                      // TODO: Handle comment
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Comments feature coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onRetweet: () {
                      // TODO: Handle retweet
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Retweeted ${post.username}\'s post'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onBookmark: () {
                      // TODO: Handle bookmark
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bookmarked ${post.username}\'s post'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onShare: () {
                      // TODO: Handle share
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share feature coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                }, childCount: _samplePosts.length),
              ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton(
              onPressed: _onCompose,
              backgroundColor: AppTheme.accentBlue,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppTheme.darkBorder.withOpacity(0.3)
        : AppTheme.lightBorder.withOpacity(0.3);
    final highlightColor = isDark
        ? AppTheme.darkBorder.withOpacity(0.1)
        : AppTheme.lightBorder.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: baseColor, width: 1),
            ),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 80,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
