import 'package:cloud_firestore/cloud_firestore.dart';

class SocialPostModel {
  final String id;
  final String content;
  final String? imageUrl;
  final String postedBy;
  final String username;
  final String userHandle;
  final String? userAvatarUrl;
  final DateTime timestamp;
  final List<String> likes;
  final List<CommentModel> comments;
  final List<String> retweets;
  final List<String> bookmarks;
  final bool isActive;

  SocialPostModel({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.postedBy,
    required this.username,
    required this.userHandle,
    this.userAvatarUrl,
    required this.timestamp,
    this.likes = const [],
    this.comments = const [],
    this.retweets = const [],
    this.bookmarks = const [],
    this.isActive = true,
  });

  factory SocialPostModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return SocialPostModel(
      id: doc.id,
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      postedBy: data['postedBy'] ?? '',
      username: data['username'] ?? 'Unknown User',
      userHandle: data['userHandle'] ?? '@unknown',
      userAvatarUrl: data['userAvatarUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((comment) => CommentModel.fromMap(comment))
          .toList(),
      retweets: List<String>.from(data['retweets'] ?? []),
      bookmarks: List<String>.from(data['bookmarks'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'imageUrl': imageUrl,
      'postedBy': postedBy,
      'username': username,
      'userHandle': userHandle,
      'userAvatarUrl': userAvatarUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'retweets': retweets,
      'bookmarks': bookmarks,
      'isActive': isActive,
    };
  }

  SocialPostModel copyWith({
    String? id,
    String? content,
    String? imageUrl,
    String? postedBy,
    String? username,
    String? userHandle,
    String? userAvatarUrl,
    DateTime? timestamp,
    List<String>? likes,
    List<CommentModel>? comments,
    List<String>? retweets,
    List<String>? bookmarks,
    bool? isActive,
  }) {
    return SocialPostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      postedBy: postedBy ?? this.postedBy,
      username: username ?? this.username,
      userHandle: userHandle ?? this.userHandle,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      retweets: retweets ?? this.retweets,
      bookmarks: bookmarks ?? this.bookmarks,
      isActive: isActive ?? this.isActive,
    );
  }

  int get likeCount => likes.length;
  int get commentCount => comments.length;
  int get retweetCount => retweets.length;
  int get bookmarkCount => bookmarks.length;

  bool hasLiked(String userId) => likes.contains(userId);
  bool hasRetweeted(String userId) => retweets.contains(userId);
  bool hasBookmarked(String userId) => bookmarks.contains(userId);

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }
}

class CommentModel {
  final String id;
  final String content;
  final String postedBy;
  final String username;
  final String userHandle;
  final String? userAvatarUrl;
  final DateTime timestamp;
  final List<String> likes;

  CommentModel({
    required this.id,
    required this.content,
    required this.postedBy,
    required this.username,
    required this.userHandle,
    this.userAvatarUrl,
    required this.timestamp,
    this.likes = const [],
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      postedBy: map['postedBy'] ?? '',
      username: map['username'] ?? 'Unknown User',
      userHandle: map['userHandle'] ?? '@unknown',
      userAvatarUrl: map['userAvatarUrl'],
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
      'username': username,
      'userHandle': userHandle,
      'userAvatarUrl': userAvatarUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
    };
  }

  CommentModel copyWith({
    String? id,
    String? content,
    String? postedBy,
    String? username,
    String? userHandle,
    String? userAvatarUrl,
    DateTime? timestamp,
    List<String>? likes,
  }) {
    return CommentModel(
      id: id ?? this.id,
      content: content ?? this.content,
      postedBy: postedBy ?? this.postedBy,
      username: username ?? this.username,
      userHandle: userHandle ?? this.userHandle,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
    );
  }

  int get likeCount => likes.length;
  bool hasLiked(String userId) => likes.contains(userId);

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }
}


























