import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/story_model.dart';

class StoryCircle extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;
  final bool isViewed;

  const StoryCircle({
    super.key,
    required this.story,
    required this.onTap,
    this.isViewed = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Story circle with gradient border
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isViewed
                    ? LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade300],
                      )
                    : LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                          Colors.orange,
                          Colors.pink,
                        ],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: story.eventImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: story.eventImageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.event,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.event,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.event,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Event title (truncated)
            Text(
              story.eventTitle.length > 8
                  ? '${story.eventTitle.substring(0, 8)}...'
                  : story.eventTitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
