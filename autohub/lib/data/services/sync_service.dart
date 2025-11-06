import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'offline_service.dart';
import 'offline_image_service.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/post_model.dart';
import 'firestore_service.dart';
import 'dart:convert';
import '../../providers/app_providers.dart';

class SyncService {
  final FirestoreService _firestoreService;

  SyncService(this._firestoreService);

  Future<void> syncAllData() async {
    if (!await OfflineService.isOnline()) {
      return; // No internet connection
    }

    try {
      // Sync offline images first
      await _syncOfflineImages();

      // Sync users
      await _syncUsers();

      // Sync events
      await _syncEvents();

      // Sync posts
      await _syncPosts();

      // Process sync queue
      await _processSyncQueue();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  /// Sync images that were saved offline
  Future<void> _syncOfflineImages() async {
    try {
      final imageIds = OfflineImageService.getAllLocalImageIds();
      print('📤 Syncing ${imageIds.length} offline images...');

      for (final imageId in imageIds) {
        try {
          final file = await OfflineImageService.getLocalImageFile(imageId);
          if (file == null) {
            print('⚠️ Image file not found: $imageId');
            continue;
          }

          // Determine path based on image ID
          String storagePath = 'post_images/$imageId.jpg';
          if (imageId.contains('car_')) {
            storagePath = 'car_images/$imageId.jpg';
          } else if (imageId.contains('profile_')) {
            storagePath = 'profile_images/$imageId.jpg';
          }

          // Upload to Firebase Storage
          final downloadUrl = await _firestoreService.uploadImage(
            file,
            storagePath,
          );
          print('✅ Image uploaded: $imageId -> $downloadUrl');

          // Delete local image after successful upload
          await OfflineImageService.deleteLocalImage(imageId);
        } catch (e) {
          print('❌ Error syncing image $imageId: $e');
          // Continue with other images
        }
      }
    } catch (e) {
      print('❌ Error syncing offline images: $e');
    }
  }

  Future<void> _syncUsers() async {
    try {
      // Get users from Firestore
      final onlineUsers = await _firestoreService.getAllUsers();

      // Save to local database
      for (final user in onlineUsers) {
        await OfflineService.saveUser(user);
      }
    } catch (e) {
      print('Error syncing users: $e');
    }
  }

  Future<void> _syncEvents() async {
    try {
      // Get events from Firestore
      final onlineEvents = await _firestoreService.getAllEvents();

      // Save to local database
      for (final event in onlineEvents) {
        await OfflineService.saveEvent(event);
      }
    } catch (e) {
      print('Error syncing events: $e');
    }
  }

  Future<void> _syncPosts() async {
    try {
      // Get posts from Firestore
      final onlinePosts = await _firestoreService.getAllPosts();

      // Save to local database
      for (final post in onlinePosts) {
        await OfflineService.savePost(post);
      }
    } catch (e) {
      print('Error syncing posts: $e');
    }
  }

  Future<void> _processSyncQueue() async {
    final syncQueue = await OfflineService.getSyncQueue();

    for (final item in syncQueue) {
      try {
        final tableName = item['table_name'] as String;
        final action = item['action'] as String;
        final data = jsonDecode(item['data'] as String) as Map<String, dynamic>;

        switch (tableName) {
          case 'users':
            await _processUserSync(action, data);
            break;
          case 'events':
            await _processEventSync(action, data);
            break;
          case 'posts':
            await _processPostSync(action, data);
            break;
        }

        // Remove from sync queue after successful sync
        await OfflineService.removeFromSyncQueue(item['id'] as int);
      } catch (e) {
        print('Error processing sync queue item: $e');
      }
    }
  }

  Future<void> _processUserSync(
    String action,
    Map<String, dynamic> data,
  ) async {
    switch (action) {
      case 'create':
        await _firestoreService.createUser(UserModel.fromMap(data));
        break;
      case 'update':
        await _firestoreService.updateUser(UserModel.fromMap(data));
        break;
      case 'delete':
        await _firestoreService.deleteUser(data['id'] as String);
        break;
    }
  }

  Future<void> _processEventSync(
    String action,
    Map<String, dynamic> data,
  ) async {
    switch (action) {
      case 'create':
        await _firestoreService.createEvent(EventModel.fromMap(data));
        break;
      case 'update':
        await _firestoreService.updateEvent(EventModel.fromMap(data));
        break;
      case 'delete':
        await _firestoreService.deleteEvent(data['id'] as String);
        break;
    }
  }

  Future<void> _processPostSync(
    String action,
    Map<String, dynamic> data,
  ) async {
    switch (action) {
      case 'create':
        await _firestoreService.createPost(PostModel.fromMap(data));
        break;
      case 'update':
        await _firestoreService.updatePost(PostModel.fromMap(data));
        break;
      case 'delete':
        await _firestoreService.deletePost(data['id'] as String);
        break;
    }
  }

  Future<void> queueUserForSync(String action, UserModel user) async {
    await OfflineService.addToSyncQueue('users', user.id, action, user.toMap());
  }

  Future<void> queueEventForSync(String action, EventModel event) async {
    await OfflineService.addToSyncQueue(
      'events',
      event.id,
      action,
      event.toMap(),
    );
  }

  Future<void> queuePostForSync(String action, PostModel post) async {
    await OfflineService.addToSyncQueue('posts', post.id, action, post.toMap());
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return SyncService(firestoreService);
});

// Offline-aware providers
final offlineUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  if (await OfflineService.isOnline()) {
    // Try to sync and get fresh data
    final syncService = ref.read(syncServiceProvider);
    await syncService.syncAllData();
  }

  // Return cached data
  return await OfflineService.getAllUsers();
});

final offlineEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  if (await OfflineService.isOnline()) {
    // Try to sync and get fresh data
    final syncService = ref.read(syncServiceProvider);
    await syncService.syncAllData();
  }

  // Return cached data
  return await OfflineService.getAllEvents();
});

final offlinePostsProvider = FutureProvider<List<PostModel>>((ref) async {
  if (await OfflineService.isOnline()) {
    // Try to sync and get fresh data
    final syncService = ref.read(syncServiceProvider);
    await syncService.syncAllData();
  }

  // Return cached data
  return await OfflineService.getAllPosts();
});

// Offline status provider - using StateNotifier for manual refresh capability
final isOnlineProvider = StateNotifierProvider<IsOnlineNotifier, AsyncValue<bool>>((ref) {
  final notifier = IsOnlineNotifier();
  
  // Listen to auth state changes and refresh connectivity when user logs in
  ref.listen(authStateProvider, (previous, next) {
    next.whenData((user) {
      // If user just logged in (was null, now not null), refresh connectivity
      // Since login requires internet, we know we're online at this point
      if (user != null) {
        // Optimistically set to online since login succeeded
        notifier.setOnline(true);
        // Then verify in the background
        notifier.refresh();
      }
    });
  });
  
  return notifier;
});

class IsOnlineNotifier extends StateNotifier<AsyncValue<bool>> {
  IsOnlineNotifier() : super(const AsyncValue.loading()) {
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      state = const AsyncValue.loading();
      final isOnline = await OfflineService.isOnline();
      state = AsyncValue.data(isOnline);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _checkConnectivity();
  }
  
  // Optimistically set online status (useful when we know we're online, e.g., after login)
  void setOnline(bool online) {
    state = AsyncValue.data(online);
  }
}

// Sync status provider
final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
      return SyncStatusNotifier();
    });

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  SyncStatusNotifier() : super(const SyncStatus());

  void setSyncing(bool syncing) {
    state = state.copyWith(isSyncing: syncing);
  }

  void setLastSync(DateTime lastSync) {
    state = state.copyWith(lastSync: lastSync);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }
}

class SyncStatus {
  final bool isSyncing;
  final DateTime? lastSync;
  final String? error;

  const SyncStatus({this.isSyncing = false, this.lastSync, this.error});

  SyncStatus copyWith({bool? isSyncing, DateTime? lastSync, String? error}) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSync: lastSync ?? this.lastSync,
      error: error ?? this.error,
    );
  }
}
