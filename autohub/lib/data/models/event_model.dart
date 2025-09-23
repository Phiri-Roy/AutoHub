import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String eventName;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime eventDate;
  final String createdBy;
  final DateTime createdAt;
  final List<String> attendees;
  final String? imageUrl;
  final bool isActive;

  EventModel({
    required this.id,
    required this.eventName,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    required this.eventDate,
    required this.createdBy,
    required this.createdAt,
    this.attendees = const [],
    this.imageUrl,
    this.isActive = true,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return EventModel(
      id: doc.id,
      eventName: data['eventName'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      attendees: List<String>.from(data['attendees'] ?? []),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventName': eventName,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'eventDate': Timestamp.fromDate(eventDate),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'attendees': attendees,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }

  EventModel copyWith({
    String? id,
    String? eventName,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? eventDate,
    String? createdBy,
    DateTime? createdAt,
    List<String>? attendees,
    String? imageUrl,
    bool? isActive,
  }) {
    return EventModel(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      eventDate: eventDate ?? this.eventDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      attendees: attendees ?? this.attendees,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isUpcoming => eventDate.isAfter(DateTime.now());
  bool get isPast => eventDate.isBefore(DateTime.now());
  int get attendeeCount => attendees.length;
}

