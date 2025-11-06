import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../data/models/post_model.dart';
import '../../../providers/app_providers.dart';
import 'common/share_button.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final postAuthor = ref.watch(userByIdProvider(post.postedBy));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and timestamp
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    postAuthor.when(
                      data: (user) => user?.username.isNotEmpty == true
                          ? user!.username[0].toUpperCase()
                          : 'U',
                      loading: () => 'U',
                      error: (_, __) => 'U',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postAuthor.when(
                          data: (user) => user?.username ?? 'Unknown User',
                          loading: () => 'Loading...',
                          error: (_, __) => 'Unknown User',
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        DateFormat('MMM d, y • h:mm a').format(post.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content
            if (post.content.isNotEmpty) ...[
              Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
            ],

            // Post images
            if (post.imageUrls.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: post.imageUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              children: [
                // Like button
                IconButton(
                  icon: Icon(
                    post.hasLiked(currentUser.value?.id ?? '')
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: post.hasLiked(currentUser.value?.id ?? '')
                        ? Colors.red
                        : null,
                  ),
                  onPressed: () async {
                    if (currentUser.value != null) {
                      final firestoreService = ref.read(
                        firestoreServiceProvider,
                      );
                      final currentUserData = currentUser.value!;

                      if (post.hasLiked(currentUserData.id)) {
                        await firestoreService.unlikePost(
                          post.id,
                          currentUserData.id,
                        );
                      } else {
                        await firestoreService.likePost(
                          post.id,
                          currentUserData.id,
                        );

                        // Create like notification (only if not liking own post)
                        if (post.postedBy != currentUserData.id) {
                          await firestoreService.createLikeNotification(
                            currentUserData.id,
                            post.postedBy,
                            currentUserData.username,
                            currentUserData.profilePhotoUrl,
                            post.id,
                            post.content.isNotEmpty
                                ? post.content
                                : 'Shared ${post.imageUrls.length} image(s)',
                          );
                        }
                      }
                    }
                  },
                ),
                Text('${post.likeCount}'),

                const SizedBox(width: 16),

                // Comment button
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    // TODO: Navigate to comments screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comments feature coming soon!'),
                      ),
                    );
                  },
                ),
                Text('${post.commentCount}'),

                const Spacer(),

                // Share button
                ShareButton(
                  shareType: ShareType.post,
                  content: post.content,
                  imageUrl: post.imageUrls.isNotEmpty
                      ? post.imageUrls.first
                      : null,
                  authorName: postAuthor.when(
                    data: (user) => user?.username,
                    loading: () => null,
                    error: (_, __) => null,
                  ),
                  icon: Icons.share_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
