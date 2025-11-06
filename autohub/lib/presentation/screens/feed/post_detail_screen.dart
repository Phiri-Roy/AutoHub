import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM d, y • h:mm a').format(post.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            if (post.imageUrls.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post.imageUrls[index],
                        height: 200,
                        width: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          height: 200,
                          width: 300,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}











