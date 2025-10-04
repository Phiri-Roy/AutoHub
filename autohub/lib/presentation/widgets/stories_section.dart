import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/story_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/utils/constants.dart';
import 'story_circle.dart';
import 'story_popup.dart';

class StoriesSection extends ConsumerStatefulWidget {
  const StoriesSection({super.key});

  @override
  ConsumerState<StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends ConsumerState<StoriesSection> {
  final Set<String> _viewedStories = {};

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return eventsAsync.when(
      data: (events) {
        // Convert events to stories (only upcoming events)
        final now = DateTime.now();
        final upcomingEvents = events
            .where((event) => event.eventDate.isAfter(now))
            .take(10) // Limit to 10 stories
            .toList();

        if (upcomingEvents.isEmpty) {
          return const SizedBox.shrink();
        }

        final stories = upcomingEvents
            .map((event) => StoryModel.fromEvent(event))
            .toList();

        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.defaultPadding,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              final isViewed = _viewedStories.contains(story.id);

              return StoryCircle(
                story: story,
                isViewed: isViewed,
                onTap: () => _showStoryPopup(story),
              );
            },
          ),
        );
      },
      loading: () => Container(
        height: 100,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.defaultPadding,
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  void _showStoryPopup(StoryModel story) {
    // Mark story as viewed
    setState(() {
      _viewedStories.add(story.id);
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => StoryPopup(
        story: story,
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
