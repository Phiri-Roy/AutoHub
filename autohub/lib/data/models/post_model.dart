import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String content;
  final List<String> imageUrls;
  final String postedBy;
  final DateTime timestamp;
  final List<String> likes;
  final List<CommentModel> comments;
  final bool isActive;

  PostModel({
    required this.id,
    required this.content,
    this.imageUrls = const [],
    required this.postedBy,
    required this.timestamp,
    this.likes = const [],
    this.comments = const [],
    this.isActive = true,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PostModel(
      id: doc.id,
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      postedBy: data['postedBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((comment) => CommentModel.fromMap(comment))
          .toList(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'imageUrls': imageUrls,
      'postedBy': postedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'isActive': isActive,
    };
  }

  PostModel copyWith({
    String? id,
    String? content,
    List<String>? imageUrls,
    String? postedBy,
    DateTime? timestamp,
    List<String>? likes,
    List<CommentModel>? comments,
    bool? isActive,
  }) {
    return PostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      postedBy: postedBy ?? this.postedBy,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isActive: isActive ?? this.isActive,
    );
  }

  int get likeCount => likes.length;
  int get commentCount => comments.length;
  bool hasLiked(String userId) => likes.contains(userId);

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      postedBy: map['postedBy'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      likes: List<String>.from(map['likes'] ?? []),
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((comment) => CommentModel.fromMap(comment))
          .toList(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'imageUrls': imageUrls,
      'postedBy': postedBy,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'isActive': isActive,
    };
  }
}

class CommentModel {
  final String id;
  final String content;
  final String postedBy;
  final DateTime timestamp;
  final List<String> likes;

  CommentModel({
    required this.id,
    required this.content,
    required this.postedBy,
    required this.timestamp,
    this.likes = const [],
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      postedBy: map['postedBy'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      likes: List<String>.from(map['likes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'postedBy': postedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
    };
  }

  CommentModel copyWith({
    String? id,
    String? content,
    String? postedBy,
    DateTime? timestamp,
    List<String>? likes,
  }) {
    return CommentModel(
      id: id ?? this.id,
      content: content ?? this.content,
      postedBy: postedBy ?? this.postedBy,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
    );
  }

  int get likeCount => likes.length;
  bool hasLiked(String userId) => likes.contains(userId);
}
