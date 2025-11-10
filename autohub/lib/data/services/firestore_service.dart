import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/post_model.dart';
import '../models/event_submission_model.dart';
import '../models/notification_model.dart';
import '../../core/utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // User operations
  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toFirestore());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .update(user.toFirestore());
  }

  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  // Event operations
  Future<String> createEvent(EventModel event) async {
    final docRef = await _firestore
        .collection(AppConstants.eventsCollection)
        .add(event.toFirestore());
    return docRef.id;
  }

  Future<EventModel?> getEvent(String eventId) async {
    final doc = await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .get();

    if (doc.exists) {
      return EventModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<EventModel?> getEventStream(String eventId) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return EventModel.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> updateEvent(EventModel event) async {
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(event.id)
        .update(event.toFirestore());
  }

  Stream<List<EventModel>> getEventsStream() {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<EventModel>> getUpcomingEventsStream() {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .where((event) => event.eventDate.isAfter(DateTime.now()))
              .toList(),
        );
  }

  Future<void> joinEvent(String eventId, String userId) async {
    // Get event details and user details for notification
    final eventDoc = await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .get();

    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (eventDoc.exists && userDoc.exists) {
      final eventData = eventDoc.data()!;
      final userData = userDoc.data()!;

      // Update attendees
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .update({
            'attendees': FieldValue.arrayUnion([userId]),
          });

      // Send notification to event owner (only if not joining own event)
      final eventOwnerId = eventData['createdBy'] as String;
      if (eventOwnerId != userId) {
        await createEventJoinNotification(
          userId,
          eventOwnerId,
          userData['username'] as String,
          userData['profilePhotoUrl'] as String?,
          eventId,
          eventData['eventName'] as String,
        );
      }
    }
  }

  Future<void> leaveEvent(String eventId, String userId) async {
    // Get event details and user details for notification
    final eventDoc = await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .get();

    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (eventDoc.exists && userDoc.exists) {
      final eventData = eventDoc.data()!;
      final userData = userDoc.data()!;

      // Update attendees
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .update({
            'attendees': FieldValue.arrayRemove([userId]),
          });

      // Send notification to event owner (only if not leaving own event)
      final eventOwnerId = eventData['createdBy'] as String;
      if (eventOwnerId != userId) {
        await createEventLeaveNotification(
          userId,
          eventOwnerId,
          userData['username'] as String,
          userData['profilePhotoUrl'] as String?,
          eventId,
          eventData['eventName'] as String,
        );
      }
    }
  }

  // Post operations
  Future<String> createPost(PostModel post) async {
    final docRef = await _firestore
        .collection(AppConstants.postsCollection)
        .add(post.toFirestore());
    return docRef.id;
  }

  Future<PostModel?> getPost(String postId) async {
    final doc = await _firestore
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .get();

    if (doc.exists) {
      return PostModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<PostModel?> getPostStream(String postId) {
    return _firestore
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return PostModel.fromFirestore(doc);
      }
      return null;
    });
  }

  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection(AppConstants.postsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList()
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
        );
  }

  // Posts by a specific user
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore
        .collection(AppConstants.postsCollection)
        .where('postedBy', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> likePost(String postId, String userId) async {
    await _firestore
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .update({
          'likes': FieldValue.arrayUnion([userId]),
        });
  }

  Future<void> unlikePost(String postId, String userId) async {
    await _firestore
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .update({
          'likes': FieldValue.arrayRemove([userId]),
        });
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    await _firestore
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .update({
          'comments': FieldValue.arrayUnion([comment.toMap()]),
        });
  }

  // Event submission operations
  Future<String> submitCarToEvent(EventSubmissionModel submission) async {
    final docRef = await _firestore
        .collection(AppConstants.eventSubmissionsCollection)
        .add(submission.toFirestore());
    return docRef.id;
  }

  Stream<List<EventSubmissionModel>> getEventSubmissions(
    String eventId,
  ) async* {
    yield* _firestore
        .collection(AppConstants.eventSubmissionsCollection)
        .where('eventId', isEqualTo: eventId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventSubmissionModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> voteForSubmission(String submissionId, String userId) async {
    await _firestore
        .collection(AppConstants.eventSubmissionsCollection)
        .doc(submissionId)
        .update({
          'votes': FieldValue.arrayUnion([userId]),
        });
  }

  Future<void> removeVoteFromSubmission(
    String submissionId,
    String userId,
  ) async {
    await _firestore
        .collection(AppConstants.eventSubmissionsCollection)
        .doc(submissionId)
        .update({
          'votes': FieldValue.arrayRemove([userId]),
        });
  }

  // Storage operations
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadImageFromXFile(XFile imageFile, String path) async {
    try {
      print('Starting upload to path: $path');
      print('Image file name: ${imageFile.name}');
      print('Image file size: ${await imageFile.length()} bytes');

      // Test Firebase Storage connection first
      try {
        await _storage
            .ref()
            .child('test')
            .putString('test')
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                throw Exception('Firebase Storage connection timeout');
              },
            );
        print('Firebase Storage connection test successful');
        // Clean up test file
        await _storage.ref().child('test').delete();
      } catch (testError) {
        print('Firebase Storage connection test failed: $testError');
        throw Exception('Firebase Storage not accessible: $testError');
      }

      final ref = _storage.ref().child(path);
      print('Storage reference created');

      final bytes = await imageFile.readAsBytes();
      print('Image bytes read: ${bytes.length} bytes');

      // Check if file is too large (limit to 10MB for web)
      if (bytes.length > 10 * 1024 * 1024) {
        throw Exception('Image file too large. Maximum size is 10MB.');
      }

      final uploadTask = await ref
          .putData(bytes, SettableMetadata(contentType: 'image/jpeg'))
          .timeout(
            const Duration(minutes: 2),
            onTimeout: () {
              throw Exception('Upload timeout after 2 minutes');
            },
          );
      print('Upload task completed');

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('Download URL obtained: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Log error but don't throw - image might already be deleted
      // In production, you might want to use a proper logging service
      // print('Failed to delete image: $e');
    }
  }

  // Leaderboard operations
  Stream<List<UserModel>> getLeaderboardStream() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('totalWins', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateUserWins(String userId) async {
    // Get all submissions by this user that won
    final submissions = await _firestore
        .collection(AppConstants.eventSubmissionsCollection)
        .where('userId', isEqualTo: userId)
        .get();

    int wins = 0;
    for (var submission in submissions.docs) {
      final eventId = submission.data()['eventId'];
      final submissionVotes = submission.data()['votes'] as List<dynamic>;

      // Get all submissions for this event
      final eventSubmissions = await _firestore
          .collection(AppConstants.eventSubmissionsCollection)
          .where('eventId', isEqualTo: eventId)
          .get();

      // Check if this submission has the most votes
      bool isWinner = true;
      for (var otherSubmission in eventSubmissions.docs) {
        if (otherSubmission.id != submission.id) {
          final otherVotes = otherSubmission.data()['votes'] as List<dynamic>;
          if (otherVotes.length >= submissionVotes.length) {
            isWinner = false;
            break;
          }
        }
      }

      if (isWinner && submissionVotes.isNotEmpty) {
        wins++;
      }
    }

    // Update user's total wins
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'totalWins': wins});
  }

  // Follow operations
  Future<void> followUser(String followerId, String followingId) async {
    // Check if already following
    final existingFollow = await _firestore
        .collection(AppConstants.followsCollection)
        .where('followerId', isEqualTo: followerId)
        .where('followingId', isEqualTo: followingId)
        .get();

    if (existingFollow.docs.isNotEmpty) {
      throw Exception('Already following this user');
    }

    // Create follow relationship
    await _firestore.collection(AppConstants.followsCollection).add({
      'followerId': followerId,
      'followingId': followingId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update follower count for the user being followed
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(followingId)
        .update({'followersCount': FieldValue.increment(1)});

    // Update following count for the follower
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(followerId)
        .update({'followingCount': FieldValue.increment(1)});
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    // Find and delete follow relationship
    final followQuery = await _firestore
        .collection(AppConstants.followsCollection)
        .where('followerId', isEqualTo: followerId)
        .where('followingId', isEqualTo: followingId)
        .get();

    if (followQuery.docs.isNotEmpty) {
      await _firestore
          .collection(AppConstants.followsCollection)
          .doc(followQuery.docs.first.id)
          .delete();

      // Update follower count for the user being unfollowed
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(followingId)
          .update({'followersCount': FieldValue.increment(-1)});

      // Update following count for the unfollower
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(followerId)
          .update({'followingCount': FieldValue.increment(-1)});
    }
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    final followQuery = await _firestore
        .collection(AppConstants.followsCollection)
        .where('followerId', isEqualTo: followerId)
        .where('followingId', isEqualTo: followingId)
        .get();

    return followQuery.docs.isNotEmpty;
  }

  Stream<List<UserModel>> getFollowers(String userId) {
    return _firestore
        .collection(AppConstants.followsCollection)
        .where('followingId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final followerIds = snapshot.docs
              .map((doc) => doc.data()['followerId'] as String)
              .toList();

          if (followerIds.isEmpty) return <UserModel>[];

          final users = await _firestore
              .collection(AppConstants.usersCollection)
              .where(FieldPath.documentId, whereIn: followerIds)
              .get();

          return users.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
        });
  }

  Stream<List<UserModel>> getFollowing(String userId) {
    return _firestore
        .collection(AppConstants.followsCollection)
        .where('followerId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final followingIds = snapshot.docs
              .map((doc) => doc.data()['followingId'] as String)
              .toList();

          if (followingIds.isEmpty) return <UserModel>[];

          final users = await _firestore
              .collection(AppConstants.usersCollection)
              .where(FieldPath.documentId, whereIn: followingIds)
              .get();

          return users.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
        });
  }

  Stream<List<PostModel>> getFollowingPosts(String userId) {
    return _firestore
        .collection(AppConstants.followsCollection)
        .where('followerId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final followingIds = snapshot.docs
              .map((doc) => doc.data()['followingId'] as String)
              .toList();

          // Include the current user's own posts in the feed
          final userIdsToFetch = <String>{userId};
          userIdsToFetch.addAll(followingIds);

          // Firestore whereIn has a limit of 10 items
          // Split into batches if needed
          final List<PostModel> allPosts = [];
          const int batchSize = 10;
          final userIdsList = userIdsToFetch.toList();

          if (userIdsList.isNotEmpty) {
            for (int i = 0; i < userIdsList.length; i += batchSize) {
              final batch = userIdsList.skip(i).take(batchSize).toList();
              
              final posts = await _firestore
                  .collection(AppConstants.postsCollection)
                  .where('postedBy', whereIn: batch)
                  .where('isActive', isEqualTo: true)
                  .orderBy('timestamp', descending: true)
                  .limit(50)
                  .get();

              allPosts.addAll(
                posts.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
              );
            }

            // Sort all posts by timestamp descending and limit to 50 most recent
            allPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            return allPosts.take(50).toList();
          } else {
            // If user has no posts and isn't following anyone, return empty list
            // (Feed will show "No posts yet" message)
            return <PostModel>[];
          }
        });
  }

  // Events attended by a specific user (based on attendees array)
  Stream<List<EventModel>> getEventsAttendedByUser(String userId) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('attendees', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('eventDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Notification operations
  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .add(notification.toFirestore());
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    final unreadQuery = await _firestore
        .collection(AppConstants.notificationsCollection)
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    return unreadQuery.docs.length;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final unreadQuery = await _firestore
        .collection(AppConstants.notificationsCollection)
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Helper method to create notifications for various activities
  Future<void> createFollowNotification(
    String followerId,
    String followingId,
    String followerName,
    String? followerProfilePhotoUrl,
  ) async {
    // Don't create notification if user is following themselves
    if (followerId == followingId) {
      return;
    }
    
    final notification = NotificationModel(
      id: '',
      recipientId: followingId,
      senderId: followerId,
      senderName: followerName,
      senderProfilePhotoUrl: followerProfilePhotoUrl,
      type: NotificationType.follow,
      message: '$followerName started following you',
      isRead: false,
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }

  Future<void> createLikeNotification(
    String likerId,
    String postOwnerId,
    String likerName,
    String? likerProfilePhotoUrl,
    String postId,
    String? postContent,
  ) async {
    // Don't create notification if user is liking their own post
    if (likerId == postOwnerId) {
      return;
    }
    
    final notification = NotificationModel(
      id: '',
      recipientId: postOwnerId,
      senderId: likerId,
      senderName: likerName,
      senderProfilePhotoUrl: likerProfilePhotoUrl,
      type: NotificationType.like,
      message: '$likerName liked your post',
      postId: postId,
      postContent: postContent,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }

  Future<void> createPostNotification(
    String posterId,
    String posterName,
    String? posterProfilePhotoUrl,
    String postId,
    String postContent,
  ) async {
    // Get all followers of the poster
    final followersQuery = await _firestore
        .collection(AppConstants.followsCollection)
        .where('followingId', isEqualTo: posterId)
        .get();

    final batch = _firestore.batch();
    for (final doc in followersQuery.docs) {
      final followerId = doc.data()['followerId'] as String;
      final notification = NotificationModel(
        id: '',
        recipientId: followerId,
        senderId: posterId,
        senderName: posterName,
        senderProfilePhotoUrl: posterProfilePhotoUrl,
        type: NotificationType.post,
        message: '$posterName made a new post',
        postId: postId,
        postContent: postContent,
        isRead: false,
        createdAt: DateTime.now(),
      );
      final notificationRef = _firestore
          .collection(AppConstants.notificationsCollection)
          .doc();
      batch.set(notificationRef, notification.toFirestore());
    }
    await batch.commit();
  }

  // Event notification methods
  Future<void> createEventJoinNotification(
    String joinerId,
    String eventOwnerId,
    String joinerName,
    String? joinerProfilePhotoUrl,
    String eventId,
    String eventTitle,
  ) async {
    final notification = NotificationModel(
      id: '',
      recipientId: eventOwnerId,
      senderId: joinerId,
      senderName: joinerName,
      senderProfilePhotoUrl: joinerProfilePhotoUrl,
      type: NotificationType.eventJoin,
      message: '$joinerName joined your event "$eventTitle"',
      eventId: eventId,
      eventTitle: eventTitle,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }

  Future<void> createEventLeaveNotification(
    String leaverId,
    String eventOwnerId,
    String leaverName,
    String? leaverProfilePhotoUrl,
    String eventId,
    String eventTitle,
  ) async {
    final notification = NotificationModel(
      id: '',
      recipientId: eventOwnerId,
      senderId: leaverId,
      senderName: leaverName,
      senderProfilePhotoUrl: leaverProfilePhotoUrl,
      type: NotificationType.eventLeave,
      message: '$leaverName left your event "$eventTitle"',
      eventId: eventId,
      eventTitle: eventTitle,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }

  // Additional methods for sync service
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  Future<List<EventModel>> getAllEvents() async {
    final snapshot = await _firestore
        .collection(AppConstants.eventsCollection)
        .orderBy('eventDate', descending: true)
        .get();

    return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
  }

  Future<List<PostModel>> getAllPosts() async {
    final snapshot = await _firestore
        .collection(AppConstants.postsCollection)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }

  Future<void> deleteUser(String userId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .delete();
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .delete();
  }

  Future<void> updatePost(PostModel post) async {
    await _firestore
        .collection(AppConstants.postsCollection)
        .doc(post.id)
        .update(post.toFirestore());
  }

  Future<void> deletePost(String postId) async {
    await _firestore
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .delete();
  }
}
