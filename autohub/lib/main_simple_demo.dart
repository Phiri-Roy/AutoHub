import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/feed/social_feed_screen.dart';

void main() {
  runApp(const SimpleDemoApp());
}

class SimpleDemoApp extends StatelessWidget {
  const SimpleDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Feed Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SimpleSocialFeedScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleSocialFeedScreen extends StatefulWidget {
  const SimpleSocialFeedScreen({super.key});

  @override
  State<SimpleSocialFeedScreen> createState() => _SimpleSocialFeedScreenState();
}

class _SimpleSocialFeedScreenState extends State<SimpleSocialFeedScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Sample data for demonstration
  final List<Map<String, dynamic>> _samplePosts = [
    {
      'id': '1',
      'content':
          'Just finished an amazing road trip through the mountains! The views were absolutely breathtaking. 🏔️✨',
      'imageUrl':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=450&fit=crop',
      'username': 'Alex Johnson',
      'userHandle': '@alexjohnson',
      'userAvatarUrl':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      'timeAgo': '5m',
      'likeCount': 2,
      'commentCount': 0,
      'retweetCount': 1,
      'bookmarkCount': 0,
    },
    {
      'id': '2',
      'content':
          'Working on some exciting new features for the app. Can\'t wait to share them with you all! 🚀',
      'username': 'Sarah Chen',
      'userHandle': '@sarahchen',
      'userAvatarUrl':
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
      'timeAgo': '2h',
      'likeCount': 3,
      'commentCount': 0,
      'retweetCount': 0,
      'bookmarkCount': 1,
    },
    {
      'id': '3',
      'content':
          'Beautiful sunset from my balcony tonight. Sometimes the simplest moments are the most precious. 🌅',
      'imageUrl':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=450&fit=crop',
      'username': 'Mike Rodriguez',
      'userHandle': '@mikerodriguez',
      'userAvatarUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      'timeAgo': '4h',
      'likeCount': 4,
      'commentCount': 0,
      'retweetCount': 1,
      'bookmarkCount': 0,
    },
    {
      'id': '4',
      'content':
          'Coffee and code - the perfect combination for a productive morning! ☕️💻',
      'username': 'Emma Wilson',
      'userHandle': '@emmawilson',
      'userAvatarUrl':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      'timeAgo': '1d',
      'likeCount': 3,
      'commentCount': 0,
      'retweetCount': 0,
      'bookmarkCount': 2,
    },
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
            backgroundImage: const NetworkImage(
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
            ),
          ),
        ),
        title: Text(
          'Feed',
          style: TextStyle(
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
                  return _buildSimplePostCard(
                    post,
                    isDark,
                    textColor,
                    secondaryTextColor,
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

  Widget _buildSimplePostCard(
    Map<String, dynamic> post,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final backgroundColor = isDark
        ? AppTheme.darkSurface
        : AppTheme.lightSurface;
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
                  backgroundImage: NetworkImage(post['userAvatarUrl']),
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
                            post['username'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post['userHandle'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        post['timeAgo'],
                        style: TextStyle(
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
            if (post['content'] != null) ...[
              Text(
                post['content'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: textColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Post image
            if (post['imageUrl'] != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    post['imageUrl'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: borderColor.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: borderColor.withOpacity(0.3),
                        child: Icon(
                          Icons.error_outline,
                          color: secondaryTextColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              children: [
                // Comment button
                _buildActionButton(
                  Icons.chat_bubble_outline,
                  post['commentCount'],
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comments feature coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  secondaryTextColor,
                ),
                const SizedBox(width: 24),

                // Retweet button
                _buildActionButton(Icons.repeat, post['retweetCount'], () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Retweeted ${post['username']}\'s post'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }, secondaryTextColor),
                const SizedBox(width: 24),

                // Like button
                _buildActionButton(
                  Icons.favorite_border,
                  post['likeCount'],
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Liked ${post['username']}\'s post'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  secondaryTextColor,
                ),
                const SizedBox(width: 24),

                // Bookmark button
                _buildActionButton(
                  Icons.bookmark_border,
                  post['bookmarkCount'],
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bookmarked ${post['username']}\'s post'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  secondaryTextColor,
                ),

                const Spacer(),

                // Share button
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    int count,
    VoidCallback onTap,
    Color color,
  ) {
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
                style: TextStyle(
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

  Widget _buildShimmerLoading() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppTheme.darkBorder.withOpacity(0.3)
        : AppTheme.lightBorder.withOpacity(0.3);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: baseColor,
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
                              color: baseColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: baseColor,
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
                    color: baseColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







