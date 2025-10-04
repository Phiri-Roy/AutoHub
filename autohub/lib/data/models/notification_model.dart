import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { follow, like, post, comment, eventJoin, eventLeave }

class NotificationModel {
  final String id;
  final String recipientId;
  final String senderId;
  final String senderName;
  final String? senderProfilePhotoUrl;
  final NotificationType type;
  final String message;
  final String? postId;
  final String? postContent;
  final String? eventId;
  final String? eventTitle;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePhotoUrl,
    required this.type,
    required this.message,
    this.postId,
    this.postContent,
    this.eventId,
    this.eventTitle,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderProfilePhotoUrl: data['senderProfilePhotoUrl'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.post,
      ),
      message: data['message'] ?? '',
      postId: data['postId'],
      postContent: data['postContent'],
      eventId: data['eventId'],
      eventTitle: data['eventTitle'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName,
      'senderProfilePhotoUrl': senderProfilePhotoUrl,
      'type': type.toString().split('.').last,
      'message': message,
      'postId': postId,
      'postContent': postContent,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? senderId,
    String? senderName,
    String? senderProfilePhotoUrl,
    NotificationType? type,
    String? message,
    String? postId,
    String? postContent,
    String? eventId,
    String? eventTitle,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfilePhotoUrl:
          senderProfilePhotoUrl ?? this.senderProfilePhotoUrl,
      type: type ?? this.type,
      message: message ?? this.message,
      postId: postId ?? this.postId,
      postContent: postContent ?? this.postContent,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.follow:
        return 'Followed you';
      case NotificationType.like:
        return 'Liked your post';
      case NotificationType.post:
        return 'Made a new post';
      case NotificationType.comment:
        return 'Commented on your post';
      case NotificationType.eventJoin:
        return 'Joined your event';
      case NotificationType.eventLeave:
        return 'Left your event';
    }
  }

  String get iconName {
    switch (type) {
      case NotificationType.follow:
        return 'person_add';
      case NotificationType.like:
        return 'favorite';
      case NotificationType.post:
        return 'post_add';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.eventJoin:
        return 'event_available';
      case NotificationType.eventLeave:
        return 'event_busy';
    }
  }
}
