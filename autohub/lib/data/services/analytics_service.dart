import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // User events
  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  static Future<void> logUserRegistration(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  static Future<void> logUserLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logUserLogout() async {
    await _analytics.logEvent(name: 'user_logout');
  }

  // Car events
  static Future<void> logCarAdded(String make, String model, int year) async {
    await _analytics.logEvent(
      name: 'car_added',
      parameters: {'car_make': make, 'car_model': model, 'car_year': year},
    );
  }

  static Future<void> logCarShared(
    String carId,
    String make,
    String model,
  ) async {
    await _analytics.logEvent(
      name: 'car_shared',
      parameters: {'car_id': carId, 'car_make': make, 'car_model': model},
    );
  }

  static Future<void> logCarComparison(List<String> carIds) async {
    await _analytics.logEvent(
      name: 'car_comparison',
      parameters: {'car_count': carIds.length, 'car_ids': carIds.join(',')},
    );
  }

  // Event events
  static Future<void> logEventCreated(String eventId, String eventName) async {
    await _analytics.logEvent(
      name: 'event_created',
      parameters: {'event_id': eventId, 'event_name': eventName},
    );
  }

  static Future<void> logEventJoined(String eventId, String eventName) async {
    await _analytics.logEvent(
      name: 'event_joined',
      parameters: {'event_id': eventId, 'event_name': eventName},
    );
  }

  static Future<void> logEventShared(String eventId, String eventName) async {
    await _analytics.logEvent(
      name: 'event_shared',
      parameters: {'event_id': eventId, 'event_name': eventName},
    );
  }

  // Post events
  static Future<void> logPostCreated(String postId, bool hasImages) async {
    await _analytics.logEvent(
      name: 'post_created',
      parameters: {'post_id': postId, 'has_images': hasImages},
    );
  }

  static Future<void> logPostLiked(String postId, String authorId) async {
    await _analytics.logEvent(
      name: 'post_liked',
      parameters: {'post_id': postId, 'author_id': authorId},
    );
  }

  static Future<void> logPostShared(String postId, String authorId) async {
    await _analytics.logEvent(
      name: 'post_shared',
      parameters: {'post_id': postId, 'author_id': authorId},
    );
  }

  static Future<void> logCommentAdded(String postId, String authorId) async {
    await _analytics.logEvent(
      name: 'comment_added',
      parameters: {'post_id': postId, 'author_id': authorId},
    );
  }

  // Voting events
  static Future<void> logVoteCast(String eventId, String carId) async {
    await _analytics.logEvent(
      name: 'vote_cast',
      parameters: {'event_id': eventId, 'car_id': carId},
    );
  }

  static Future<void> logCarSubmitted(String eventId, String carId) async {
    await _analytics.logEvent(
      name: 'car_submitted',
      parameters: {'event_id': eventId, 'car_id': carId},
    );
  }

  // Search events
  static Future<void> logSearchPerformed(
    String query,
    String searchType,
  ) async {
    await _analytics.logSearch(
      searchTerm: query,
      parameters: {'search_type': searchType},
    );
  }

  static Future<void> logSearchFilterUsed(
    String filterType,
    String filterValue,
  ) async {
    await _analytics.logEvent(
      name: 'search_filter_used',
      parameters: {'filter_type': filterType, 'filter_value': filterValue},
    );
  }

  // Navigation events
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  static Future<void> logNavigation(String fromScreen, String toScreen) async {
    await _analytics.logEvent(
      name: 'navigation',
      parameters: {'from_screen': fromScreen, 'to_screen': toScreen},
    );
  }

  // Feature usage events
  static Future<void> logFeatureUsed(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {'feature_name': featureName},
    );
  }

  static Future<void> logThemeChanged(String themeMode) async {
    await _analytics.logEvent(
      name: 'theme_changed',
      parameters: {'theme_mode': themeMode},
    );
  }

  // Error events
  static Future<void> logError(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'error_occurred',
      parameters: {'error_type': errorType, 'error_message': errorMessage},
    );
  }

  // User properties
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}

// Analytics provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// User engagement tracking
class UserEngagementTracker {
  static final Map<String, DateTime> _screenStartTimes = {};
  static final Map<String, int> _screenViewCounts = {};
  static final Map<String, int> _featureUsageCounts = {};

  static void trackScreenStart(String screenName) {
    _screenStartTimes[screenName] = DateTime.now();
    _screenViewCounts[screenName] = (_screenViewCounts[screenName] ?? 0) + 1;
  }

  static void trackScreenEnd(String screenName) {
    final startTime = _screenStartTimes[screenName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      AnalyticsService.logEvent(
        'screen_time',
        parameters: {
          'screen_name': screenName,
          'duration_seconds': duration.inSeconds,
        },
      );
      _screenStartTimes.remove(screenName);
    }
  }

  static void trackFeatureUsage(String featureName) {
    _featureUsageCounts[featureName] =
        (_featureUsageCounts[featureName] ?? 0) + 1;
    AnalyticsService.logFeatureUsed(featureName);
  }

  static Map<String, int> getScreenViewCounts() => Map.from(_screenViewCounts);
  static Map<String, int> getFeatureUsageCounts() =>
      Map.from(_featureUsageCounts);
}

// Analytics insights provider
final analyticsInsightsProvider = FutureProvider<AnalyticsInsights>((
  ref,
) async {
  // This would typically fetch data from Firebase Analytics or your backend
  // For now, we'll return mock data
  return AnalyticsInsights(
    totalUsers: 1250,
    activeUsers: 890,
    totalPosts: 3450,
    totalEvents: 156,
    totalCars: 2340,
    engagementRate: 0.72,
    averageSessionDuration: Duration(minutes: 12),
    topFeatures: [
      FeatureUsage('Feed', 95),
      FeatureUsage('Events', 78),
      FeatureUsage('My Garage', 65),
      FeatureUsage('Search', 45),
      FeatureUsage('Car Comparison', 32),
    ],
    userGrowth: [
      UserGrowthData(DateTime.now().subtract(const Duration(days: 30)), 1000),
      UserGrowthData(DateTime.now().subtract(const Duration(days: 20)), 1100),
      UserGrowthData(DateTime.now().subtract(const Duration(days: 10)), 1200),
      UserGrowthData(DateTime.now(), 1250),
    ],
  );
});

class AnalyticsInsights {
  final int totalUsers;
  final int activeUsers;
  final int totalPosts;
  final int totalEvents;
  final int totalCars;
  final double engagementRate;
  final Duration averageSessionDuration;
  final List<FeatureUsage> topFeatures;
  final List<UserGrowthData> userGrowth;

  AnalyticsInsights({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalPosts,
    required this.totalEvents,
    required this.totalCars,
    required this.engagementRate,
    required this.averageSessionDuration,
    required this.topFeatures,
    required this.userGrowth,
  });
}

class FeatureUsage {
  final String name;
  final int usageCount;

  FeatureUsage(this.name, this.usageCount);
}

class UserGrowthData {
  final DateTime date;
  final int userCount;

  UserGrowthData(this.date, this.userCount);
}

// Analytics screen
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(analyticsInsightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Insights')),
      body: insights.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(context, data),
              const SizedBox(height: 16),
              _buildEngagementCard(context, data),
              const SizedBox(height: 16),
              _buildTopFeaturesCard(context, data),
              const SizedBox(height: 16),
              _buildUserGrowthCard(context, data),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading analytics: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, AnalyticsInsights data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Users',
                    data.totalUsers.toString(),
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Active Users',
                    data.activeUsers.toString(),
                    Icons.person,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Posts',
                    data.totalPosts.toString(),
                    Icons.post_add,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Events',
                    data.totalEvents.toString(),
                    Icons.event,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Cars',
                    data.totalCars.toString(),
                    Icons.directions_car,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Engagement Rate',
                    '${(data.engagementRate * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementCard(BuildContext context, AnalyticsInsights data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Engagement', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildStatItem(
              context,
              'Average Session Duration',
              '${data.averageSessionDuration.inMinutes} minutes',
              Icons.timer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFeaturesCard(BuildContext context, AnalyticsInsights data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Features', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...data.topFeatures.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(feature.name),
                    Text('${feature.usageCount}%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGrowthCard(BuildContext context, AnalyticsInsights data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Growth', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // This would typically show a chart
            Text('User growth chart would be displayed here'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
