import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/app_providers.dart';
import '../../../core/utils/constants.dart';
import 'edit_profile_screen.dart';
import 'my_garage_screen.dart';
import 'follow_screen.dart';
import '../debug/firebase_debug_screen.dart';
import '../../widgets/common/theme_toggle.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please log in'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile photo
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: user.profilePhotoUrl != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: user.profilePhotoUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                      ),

                      const SizedBox(height: 16),

                      // Username
                      Text(
                        user.username,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 8),

                      // Email
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            context,
                            'Cars',
                            '${user.cars.length}',
                            Icons.directions_car,
                          ),
                          _buildStatItem(
                            context,
                            'Followers',
                            '${user.followersCount}',
                            Icons.people,
                            onTap: () => _navigateToFollowScreen(
                              context,
                              user.id,
                              user.username,
                              true,
                            ),
                          ),
                          _buildStatItem(
                            context,
                            'Following',
                            '${user.followingCount}',
                            Icons.person_add,
                            onTap: () => _navigateToFollowScreen(
                              context,
                              user.id,
                              user.username,
                              false,
                            ),
                          ),
                          _buildStatItem(
                            context,
                            'Wins',
                            '${user.totalWins}',
                            Icons.emoji_events,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Profile options
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      _buildProfileOption(
                        context,
                        'Edit Profile',
                        'Update your personal information',
                        Icons.edit,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildProfileOption(
                        context,
                        'My Garage',
                        'Manage your cars',
                        Icons.garage,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MyGarageScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildProfileOption(
                        context,
                        'Settings',
                        'App preferences and notifications',
                        Icons.settings,
                        () {
                          _showSettingsDialog(context);
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildProfileOption(
                        context,
                        'Firebase Debug',
                        'Test Firebase configuration',
                        Icons.bug_report,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const FirebaseDebugScreen(),
                            ),
                          );
                        },
                      ),
                      _buildProfileOption(
                        context,
                        'Help & Support',
                        'Get help and contact support',
                        Icons.help_outline,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Help & Support coming soon!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(currentUserProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFollowScreen(
    BuildContext context,
    String userId,
    String username,
    bool showFollowers,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FollowScreen(
          userId: userId,
          username: username,
          showFollowers: showFollowers,
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [ThemeSelector()],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // Clear all providers and state
                ref.invalidate(currentUserProvider);
                ref.invalidate(postsProvider);
                ref.invalidate(eventsProvider);
                ref.invalidate(upcomingEventsProvider);
                ref.invalidate(leaderboardProvider);

                // Sign out
                await ref.read(authServiceProvider).signOut();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
