import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_model.dart';
import '../../providers/app_providers.dart';
import 'common/share_button.dart';
import 'package:intl/intl.dart';

class EventCard extends ConsumerStatefulWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  ConsumerState<EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  bool _isJoining = false;

  Future<void> _toggleJoin() async {
    if (_isJoining) return;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to join events')),
        );
      }
      return;
    }

    setState(() => _isJoining = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentEvent = ref.read(eventByIdProvider(widget.event.id)).value;
      final event = currentEvent ?? widget.event;

      if (event.attendees.contains(currentUser.id)) {
        await firestoreService.leaveEvent(event.id, currentUser.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Left event'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await firestoreService.joinEvent(event.id, currentUser.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Joined event'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    // Watch the event stream for real-time updates
    final eventAsync = ref.watch(eventByIdProvider(widget.event.id));
    final currentUser = ref.watch(currentUserProvider).value;

    return eventAsync.when(
      data: (streamedEvent) {
        final displayEvent = streamedEvent ?? widget.event;
        final isAttending = currentUser != null && displayEvent.attendees.contains(currentUser.id);
        
        return _buildCard(context, displayEvent, currentUser, isAttending);
      },
      loading: () => _buildCard(context, widget.event, currentUser, false),
      error: (_, __) => _buildCard(context, widget.event, currentUser, false),
    );
  }

  Widget _buildCard(
    BuildContext context,
    EventModel displayEvent,
    dynamic currentUser,
    bool isAttending,
  ) {

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayEvent.eventName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: displayEvent.isUpcoming
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayEvent.isUpcoming ? 'Upcoming' : 'Past',
                      style: TextStyle(
                        color: displayEvent.isUpcoming ? Colors.green : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (displayEvent.description.isNotEmpty) ...[
                Text(
                  displayEvent.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      displayEvent.location,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(displayEvent.eventDate),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${displayEvent.attendeeCount}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  ShareButton(
                    shareType: ShareType.event,
                    eventName: displayEvent.eventName,
                    eventDate: DateFormat(
                      'MMM d, y • h:mm a',
                    ).format(displayEvent.eventDate),
                    eventLocation: displayEvent.location,
                    eventDescription: displayEvent.description,
                    icon: Icons.share_outlined,
                  ),
                ],
              ),
              // Join/Leave button
              if (currentUser != null && displayEvent.isUpcoming) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isJoining ? null : _toggleJoin,
                    icon: _isJoining
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(isAttending ? Icons.exit_to_app : Icons.add),
                    label: Text(isAttending ? 'Leave Event' : 'Join Event'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAttending
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: isAttending
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }
}
