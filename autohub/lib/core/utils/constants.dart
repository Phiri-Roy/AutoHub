class AppConstants {
  // App Information
  static const String appName = 'AutoHub';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String eventSubmissionsCollection = 'eventSubmissions';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String followsCollection = 'follows';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String carImagesPath = 'car_images';
  static const String postImagesPath = 'post_images';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 20;
  static const int maxBioLength = 150;
  static const int maxPostLength = 500;
  static const int maxCommentLength = 200;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pagination
  static const int postsPerPage = 10;
  static const int eventsPerPage = 10;
  static const int commentsPerPage = 20;

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String authError = 'Authentication failed. Please try again.';

  // Success Messages
  static const String profileUpdated = 'Profile updated successfully!';
  static const String carAdded = 'Car added to your garage!';
  static const String eventCreated = 'Event created successfully!';
  static const String postCreated = 'Post created successfully!';
  static const String voteSubmitted = 'Vote submitted successfully!';
}
