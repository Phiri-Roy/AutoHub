import 'package:cloud_firestore/cloud_firestore.dart';

class EventSubmissionModel {
  final String id;
  final String eventId;
  final String userId;
  final String carId;
  final List<String> votes;
  final DateTime submittedAt;
  final bool isActive;

  EventSubmissionModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.carId,
    this.votes = const [],
    required this.submittedAt,
    this.isActive = true,
  });

  factory EventSubmissionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return EventSubmissionModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      carId: data['carId'] ?? '',
      votes: List<String>.from(data['votes'] ?? []),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'carId': carId,
      'votes': votes,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'isActive': isActive,
    };
  }

  EventSubmissionModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? carId,
    List<String>? votes,
    DateTime? submittedAt,
    bool? isActive,
  }) {
    return EventSubmissionModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      carId: carId ?? this.carId,
      votes: votes ?? this.votes,
      submittedAt: submittedAt ?? this.submittedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  int get voteCount => votes.length;
  bool hasVoted(String userId) => votes.contains(userId);
}

