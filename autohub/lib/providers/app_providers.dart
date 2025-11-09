import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';
import '../data/services/firestore_service.dart';
import '../data/models/user_model.dart';
import '../data/models/event_model.dart';
import '../data/models/post_model.dart';
import '../data/models/event_submission_model.dart';

// Service providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider - now reacts to auth state changes and streams user data
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return authService.authStateChanges.asyncExpand((user) {
    if (user != null) {
      // Stream the user document for real-time updates
      return firestoreService.getUserStream(user.uid);
    }
    return Stream.value(null);
  });
});

// User profile provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>((ref) {
      final authService = ref.watch(authServiceProvider);
      final firestoreService = ref.watch(firestoreServiceProvider);
      return UserProfileNotifier(authService, firestoreService);
    });

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  UserProfileNotifier(this._authService, this._firestoreService)
    : super(const AsyncValue.loading()) {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final user = await _authService.getCurrentUserData();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      await _firestoreService.updateUser(user);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Events provider - now reacts to auth state changes
final eventsProvider = StreamProvider<List<EventModel>>((ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  return currentUserAsync.when(
    data: (currentUser) {
      if (currentUser == null) {
        return Stream.value(<EventModel>[]);
      }
      return firestoreService.getEventsStream();
    },
    loading: () => Stream.value(<EventModel>[]),
    error: (error, stack) => Stream.error(error),
  );
});

final upcomingEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  return currentUserAsync.when(
    data: (currentUser) {
      if (currentUser == null) {
        return Stream.value(<EventModel>[]);
      }
      return firestoreService.getUpcomingEventsStream();
    },
    loading: () => Stream.value(<EventModel>[]),
    error: (error, stack) => Stream.error(error),
  );
});

// Posts provider - now reacts to auth state changes
final postsProvider = StreamProvider<List<PostModel>>((ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  return currentUserAsync.when(
    data: (currentUser) {
      if (currentUser == null) {
        return Stream.value(<PostModel>[]);
      }
      return firestoreService.getPostsStream();
    },
    loading: () => Stream.value(<PostModel>[]),
    error: (error, stack) => Stream.error(error),
  );
});

// Following posts provider
final followingPostsProvider = StreamProvider.family<List<PostModel>, String>((
  ref,
  userId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getFollowingPosts(userId);
});

// Event submissions provider
final eventSubmissionsProvider =
    StreamProvider.family<List<EventSubmissionModel>, String>((ref, eventId) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getEventSubmissions(eventId);
    });

// Leaderboard provider - now reacts to auth state changes
final leaderboardProvider = StreamProvider<List<UserModel>>((ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  return currentUserAsync.when(
    data: (currentUser) {
      if (currentUser == null) {
        return Stream.value(<UserModel>[]);
      }
      return firestoreService.getLeaderboardStream();
    },
    loading: () => Stream.value(<UserModel>[]),
    error: (error, stack) => Stream.error(error),
  );
});

// User by ID provider - streams user data for real-time updates
final userByIdProvider = StreamProvider.family<UserModel?, String>((
  ref,
  userId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserStream(userId);
});

// Activity providers by user
final userPostsProvider = StreamProvider.family<List<PostModel>, String>((
  ref,
  userId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserPosts(userId);
});

final userAttendedEventsProvider =
    StreamProvider.family<List<EventModel>, String>((ref, userId) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.getEventsAttendedByUser(userId);
    });

// Selected event provider
final selectedEventProvider = StateProvider<EventModel?>((ref) => null);

// Selected car provider
final selectedCarProvider = StateProvider<CarModel?>((ref) => null);
