import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_model.dart';

class StoryModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String? eventImageUrl;
  final String eventDescription;
  final DateTime eventDate;
  final String eventLocation;
  final DateTime createdAt;
  final bool isActive;

  StoryModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    this.eventImageUrl,
    required this.eventDescription,
    required this.eventDate,
    required this.eventLocation,
    required this.createdAt,
    required this.isActive,
  });

  factory StoryModel.fromEvent(EventModel event) {
    return StoryModel(
      id: 'story_${event.id}',
      eventId: event.id,
      eventTitle: event.eventName,
      eventImageUrl: event.imageUrl,
      eventDescription: event.description,
      eventDate: event.eventDate,
      eventLocation: event.location,
      createdAt: DateTime.now(),
      isActive: true,
    );
  }

  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoryModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      eventImageUrl: data['eventImageUrl'],
      eventDescription: data['eventDescription'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      eventLocation: data['eventLocation'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventImageUrl': eventImageUrl,
      'eventDescription': eventDescription,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventLocation': eventLocation,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  StoryModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? eventImageUrl,
    String? eventDescription,
    DateTime? eventDate,
    String? eventLocation,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return StoryModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventImageUrl: eventImageUrl ?? this.eventImageUrl,
      eventDescription: eventDescription ?? this.eventDescription,
      eventDate: eventDate ?? this.eventDate,
      eventLocation: eventLocation ?? this.eventLocation,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isExpired {
    // Stories expire after 24 hours
    return DateTime.now().difference(createdAt).inHours > 24;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
