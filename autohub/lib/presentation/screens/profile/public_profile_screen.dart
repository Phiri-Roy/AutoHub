import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/app_providers.dart';
import '../../../data/models/user_model.dart';
import '../profile/follow_screen.dart';
import '../events/event_detail_screen.dart';
import '../feed/post_detail_screen.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFollowingState();
  }

  Future<void> _loadFollowingState() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null || currentUser.id == widget.userId) return;
    final isFollowing = await ref
        .read(firestoreServiceProvider)
        .isFollowing(currentUser.id, widget.userId);
    if (mounted) setState(() => _isFollowing = isFollowing);
  }

  Future<void> _toggleFollow(UserModel profileUser) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null || currentUser.id == widget.userId) return;
    if (_isLoadingFollow) return;

    setState(() => _isLoadingFollow = true);
    try {
      final firestore = ref.read(firestoreServiceProvider);
      if (_isFollowing) {
        await firestore.unfollowUser(currentUser.id, widget.userId);
        setState(() => _isFollowing = false);
      } else {
        await firestore.followUser(currentUser.id, widget.userId);
        setState(() => _isFollowing = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingFollow = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileFuture = ref.watch(userByIdProvider(widget.userId));

    return profileFuture.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('User not found')),
          );
        }

        final currentUser = ref.watch(currentUserProvider).value;
        final isOwn = currentUser?.id == user.id;

        return Scaffold(
          appBar: AppBar(
            title: Text(user.username),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Posts'),
                Tab(text: 'Events'),
                Tab(text: 'Cars'),
              ],
            ),
            actions: [
              if (!isOwn)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    onPressed: _isLoadingFollow
                        ? null
                        : () => _toggleFollow(user),
                    child: Text(_isFollowing ? 'Following' : 'Follow'),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatButton(
                      label: 'Cars',
                      value: '${user.cars.length}',
                      onTap: () {},
                    ),
                    _StatButton(
                      label: 'Followers',
                      value: '${user.followersCount}',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FollowScreen(
                              userId: user.id,
                              username: user.username,
                              showFollowers: true,
                            ),
                          ),
                        );
                      },
                    ),
                    _StatButton(
                      label: 'Following',
                      value: '${user.followingCount}',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FollowScreen(
                              userId: user.id,
                              username: user.username,
                              showFollowers: false,
                            ),
                          ),
                        );
                      },
                    ),
                    _StatButton(
                      label: 'Wins',
                      value: '${user.totalWins}',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _PostsTab(userId: user.id),
                    _EventsTab(userId: user.id),
                    _CarsTab(user: user),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: ${e.toString()}'))),
    );
  }
}

class _StatButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _StatButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

class _PostsTab extends ConsumerWidget {
  final String userId;
  const _PostsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsStream = ref.watch(userPostsProvider(userId));
    return postsStream.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet'));
        }
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(DateFormat('MMM d, y').format(post.timestamp)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: ${e.toString()}')),
    );
  }
}

class _EventsTab extends ConsumerWidget {
  final String userId;
  const _EventsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsStream = ref.watch(userAttendedEventsProvider(userId));
    return eventsStream.when(
      data: (events) {
        if (events.isEmpty) {
          return const Center(child: Text('No events attended yet'));
        }
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return ListTile(
              leading: const Icon(Icons.event_available_outlined),
              title: Text(event.eventName),
              subtitle: Text(
                '${DateFormat('MMM d, y').format(event.eventDate)} • ${event.location}',
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventDetailScreen(event: event),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: ${e.toString()}')),
    );
  }
}

class _CarsTab extends StatelessWidget {
  final UserModel user;
  const _CarsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.cars.isEmpty) {
      return const Center(child: Text('No cars added yet'));
    }
    return ListView.builder(
      itemCount: user.cars.length,
      itemBuilder: (context, index) {
        final car = user.cars[index];
        return ListTile(
          leading: const Icon(Icons.directions_car),
          title: Text('${car.make} ${car.model}'),
          subtitle: Text('Year ${car.year} • ${car.color ?? '—'}'),
        );
      },
    );
  }
}
