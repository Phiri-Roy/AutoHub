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

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUserData();
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

// Events provider
final eventsProvider = StreamProvider<List<EventModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getEventsStream();
});

final upcomingEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUpcomingEventsStream();
});

// Posts provider
final postsProvider = StreamProvider<List<PostModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPostsStream();
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

// Leaderboard provider
final leaderboardProvider = StreamProvider<List<UserModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getLeaderboardStream();
});

// User by ID provider
final userByIdProvider = FutureProvider.family<UserModel?, String>((
  ref,
  userId,
) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getUser(userId);
});

// Selected event provider
final selectedEventProvider = StateProvider<EventModel?>((ref) => null);

// Selected car provider
final selectedCarProvider = StateProvider<CarModel?>((ref) => null);
