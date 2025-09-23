import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/notification_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/utils/constants.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _markAllAsRead();
  }

  Future<void> _markAllAsRead() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      await ref
          .read(firestoreServiceProvider)
          .markAllNotificationsAsRead(currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<NotificationModel>>(
              stream: ref
                  .read(firestoreServiceProvider)
                  .getNotifications(currentUser.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _NotificationTile(notification: notification);
                  },
                );
              },
            ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  Future<void> _markAsRead(WidgetRef ref) async {
    if (!notification.isRead) {
      await ref
          .read(firestoreServiceProvider)
          .markNotificationAsRead(notification.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      color: notification.isRead
          ? null
          : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: InkWell(
        onTap: () => _markAsRead(ref),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile photo
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: notification.senderProfilePhotoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          notification.senderProfilePhotoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            );
                          },
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: notification.senderName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: ' ${notification.message}'),
                              ],
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    if (notification.postContent != null &&
                        notification.postContent!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          notification.postContent!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],

                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getNotificationIcon(),
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(notification.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.post:
        return Icons.post_add;
      case NotificationType.comment:
        return Icons.comment;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
