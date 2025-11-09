import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/search_service.dart';
import '../../widgets/common/share_button.dart';
import '../profile/public_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../providers/app_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchType _selectedType = SearchType.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar and filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchState.hasQuery
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchProvider.notifier).setQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(searchProvider.notifier).setQuery(value);
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SearchType.values.map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getSearchTypeLabel(type)),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = type;
                            });
                            ref
                                .read(searchProvider.notifier)
                                .setSearchType(type);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Search results
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchState = ref.watch(searchProvider);

    if (!searchState.hasQuery) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Start typing to search',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Search for users, events, posts, and cars',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    switch (_selectedType) {
      case SearchType.all:
        return _buildAllResults();
      case SearchType.users:
        return _buildUsersResults();
      case SearchType.events:
        return _buildEventsResults();
      case SearchType.posts:
        return _buildPostsResults();
      case SearchType.cars:
        return _buildCarsResults();
    }
  }

  Widget _buildAllResults() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSectionHeader('Users', () => _buildUsersResults()),
          _buildUsersResults(limit: 3),
          _buildSectionHeader('Events', () => _buildEventsResults()),
          _buildEventsResults(limit: 3),
          _buildSectionHeader('Posts', () => _buildPostsResults()),
          _buildPostsResults(limit: 3),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          TextButton(onPressed: onTap, child: const Text('See all')),
        ],
      ),
    );
  }

  Widget _buildUsersResults({int? limit}) {
    final users = ref.watch(filteredUsersProvider);
    final limitedUsers = limit != null ? users.take(limit).toList() : users;

    if (limitedUsers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No users found'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: limitedUsers.length,
      itemBuilder: (context, index) {
        final user = limitedUsers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: user.profilePhotoUrl != null
                  ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                  : null,
              child: user.profilePhotoUrl == null
                  ? Text(
                      user.username.isNotEmpty
                          ? user.username[0].toUpperCase()
                          : 'U',
                    )
                  : null,
            ),
            title: Text(user.username),
            subtitle: Text('${user.cars.length} cars • ${user.totalWins} wins'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FollowButton(userId: user.id),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PublicProfileScreen(userId: user.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEventsResults({int? limit}) {
    final events = ref.watch(filteredEventsProvider);
    final limitedEvents = limit != null ? events.take(limit).toList() : events;

    if (limitedEvents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No events found'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: limitedEvents.length,
      itemBuilder: (context, index) {
        final event = limitedEvents[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: event.isUpcoming ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event, color: Colors.white),
            ),
            title: Text(event.eventName),
            subtitle: Text(
              '${DateFormat('MMM d, y').format(event.eventDate)} • ${event.location}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShareButton(
                  shareType: ShareType.event,
                  eventName: event.eventName,
                  eventDate: DateFormat(
                    'MMM d, y • h:mm a',
                  ).format(event.eventDate),
                  eventLocation: event.location,
                  eventDescription: event.description,
                  icon: Icons.share_outlined,
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () {
              // TODO: Navigate to event details
            },
          ),
        );
      },
    );
  }

  Widget _buildPostsResults({int? limit}) {
    final posts = ref.watch(filteredPostsProvider);
    final limitedPosts = limit != null ? posts.take(limit).toList() : posts;

    if (limitedPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No posts found'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: limitedPosts.length,
      itemBuilder: (context, index) {
        final post = limitedPosts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(DateFormat('MMM d, y').format(post.timestamp)),
            trailing: ShareButton(
              shareType: ShareType.post,
              content: post.content,
              imageUrl: post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
              icon: Icons.share_outlined,
            ),
            onTap: () {
              // TODO: Navigate to post details
            },
          ),
        );
      },
    );
  }

  Widget _buildCarsResults() {
    // This would need to be implemented based on how cars are stored
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Car search coming soon!'),
    );
  }

  String _getSearchTypeLabel(SearchType type) {
    switch (type) {
      case SearchType.all:
        return 'All';
      case SearchType.users:
        return 'Users';
      case SearchType.events:
        return 'Events';
      case SearchType.posts:
        return 'Posts';
      case SearchType.cars:
        return 'Cars';
    }
  }

  void _showFiltersDialog(BuildContext context) {
    final currentFilters = ref.read(searchProvider).filters;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Car filters
              if (_selectedType == SearchType.all ||
                  _selectedType == SearchType.cars) ...[
                const Text(
                  'Car Filters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Make',
                    hintText: 'e.g., Toyota, BMW',
                  ),
                  onChanged: (value) {
                    // Update filters
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    hintText: 'e.g., Camry, X5',
                  ),
                  onChanged: (value) {
                    // Update filters
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Min Year',
                          hintText: '2000',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // Update filters
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Max Year',
                          hintText: '2024',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // Update filters
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Event filters
              if (_selectedType == SearchType.all ||
                  _selectedType == SearchType.events) ...[
                const Text(
                  'Event Filters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., New York, Los Angeles',
                  ),
                  onChanged: (value) {
                    // Update filters
                  },
                ),
                CheckboxListTile(
                  title: const Text('Upcoming events only'),
                  value: currentFilters.upcomingEventsOnly ?? false,
                  onChanged: (value) {
                    // Update filters
                  },
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(searchProvider.notifier).clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends ConsumerStatefulWidget {
  final String userId;
  const _FollowButton({required this.userId});

  @override
  ConsumerState<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<_FollowButton> {
  bool _isFollowing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final me = ref.read(currentUserProvider).value;
    if (me == null || me.id == widget.userId) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }
    final isFollowing = await ref
        .read(firestoreServiceProvider)
        .isFollowing(me.id, widget.userId);
    if (mounted) {
      setState(() {
        _isFollowing = isFollowing;
        _loading = false;
      });
    }
  }

  Future<void> _toggle() async {
    final me = ref.read(currentUserProvider).value;
    if (me == null || me.id == widget.userId || _loading) return;
    setState(() => _loading = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      if (_isFollowing) {
        await fs.unfollowUser(me.id, widget.userId);
        if (mounted) {
          setState(() => _isFollowing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unfollowed'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await fs.followUser(me.id, widget.userId);
        
        // Create follow notification
        await fs.createFollowNotification(
          me.id,
          widget.userId,
          me.username,
          me.profilePhotoUrl,
        );
        
        if (mounted) {
          setState(() => _isFollowing = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Following'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider).value;
    if (_loading) {
      return const SizedBox(
        height: 32,
        width: 32,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (me == null || me.id == widget.userId) {
      return const SizedBox.shrink();
    }
    return OutlinedButton(
      onPressed: _toggle,
      child: Text(_isFollowing ? 'Following' : 'Follow'),
    );
  }
}
