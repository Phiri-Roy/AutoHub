import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/event_submission_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/utils/constants.dart';
import 'submit_car_screen.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final eventSubmissions = ref.watch(eventSubmissionsProvider(widget.event.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.eventName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            if (widget.event.imageUrl != null)
              CachedNetworkImage(
                imageUrl: widget.event.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.event, size: 50),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event name
                  Text(
                    widget.event.eventName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Event date and time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('EEEE, MMMM d, y • h:mm a').format(widget.event.eventDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.event.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Attendees count
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.event.attendeeCount} attendees',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Join/Leave button
                  if (currentUser.value != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isJoining ? null : () => _toggleAttendance(),
                        icon: _isJoining
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                widget.event.attendees.contains(currentUser.value!.id)
                                    ? Icons.exit_to_app
                                    : Icons.add,
                              ),
                        label: Text(
                          widget.event.attendees.contains(currentUser.value!.id)
                              ? 'Leave Event'
                              : 'Join Event',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Featured Car Showcase
                  Text(
                    'Featured Car Showcase',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vote for your favorite car!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Submit car button
                  if (currentUser.value != null && 
                      widget.event.attendees.contains(currentUser.value!.id)) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SubmitCarScreen(event: widget.event),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Submit Your Car'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Event submissions
                  eventSubmissions.when(
                    data: (submissions) {
                      if (submissions.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text('No cars submitted yet'),
                            ),
                          ),
                        );
                      }

                      // Sort by vote count
                      submissions.sort((a, b) => b.voteCount.compareTo(a.voteCount));

                      return Column(
                        children: submissions.map((submission) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text(
                                  submission.voteCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text('Car Submission'),
                              subtitle: Text('${submission.voteCount} votes'),
                              trailing: currentUser.value != null
                                  ? IconButton(
                                      icon: Icon(
                                        submission.hasVoted(currentUser.value!.id)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: submission.hasVoted(currentUser.value!.id)
                                            ? Colors.red
                                            : null,
                                      ),
                                      onPressed: () => _toggleVote(submission),
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading submissions: $error'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAttendance() async {
    if (_isJoining) return;

    setState(() => _isJoining = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) return;

      final firestoreService = ref.read(firestoreServiceProvider);
      
      if (widget.event.attendees.contains(currentUser.id)) {
        await firestoreService.leaveEvent(widget.event.id, currentUser.id);
      } else {
        await firestoreService.joinEvent(widget.event.id, currentUser.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update attendance: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _toggleVote(EventSubmissionModel submission) async {
    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) return;

      final firestoreService = ref.read(firestoreServiceProvider);
      
      if (submission.hasVoted(currentUser.id)) {
        await firestoreService.removeVoteFromSubmission(submission.id, currentUser.id);
      } else {
        await firestoreService.voteForSubmission(submission.id, currentUser.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to vote: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}








