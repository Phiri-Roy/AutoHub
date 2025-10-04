import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/utils/constants.dart';

class FollowScreen extends ConsumerStatefulWidget {
  final String userId;
  final String username;
  final bool showFollowers;

  const FollowScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.showFollowers,
  });

  @override
  ConsumerState<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends ConsumerState<FollowScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showFollowers
              ? '${widget.username}\'s Followers'
              : '${widget.username}\'s Following',
        ),
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<UserModel>>(
              stream: widget.showFollowers
                  ? ref
                        .read(firestoreServiceProvider)
                        .getFollowers(widget.userId)
                  : ref
                        .read(firestoreServiceProvider)
                        .getFollowing(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      widget.showFollowers
                          ? 'No followers yet'
                          : 'Not following anyone yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isCurrentUser = user.id == currentUser.id;

                    return _UserTile(
                      user: user,
                      isCurrentUser: isCurrentUser,
                      currentUserId: currentUser.id,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _UserTile extends ConsumerStatefulWidget {
  final UserModel user;
  final bool isCurrentUser;
  final String currentUserId;

  const _UserTile({
    required this.user,
    required this.isCurrentUser,
    required this.currentUserId,
  });

  @override
  ConsumerState<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends ConsumerState<_UserTile> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  Future<void> _checkFollowingStatus() async {
    if (widget.isCurrentUser) return;

    final isFollowing = await ref
        .read(firestoreServiceProvider)
        .isFollowing(widget.currentUserId, widget.user.id);

    if (mounted) {
      setState(() => _isFollowing = isFollowing);
    }
  }

  Future<void> _toggleFollow() async {
    if (widget.isCurrentUser || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentUser = ref.read(currentUserProvider).value!;

      if (_isFollowing) {
        await firestoreService.unfollowUser(
          widget.currentUserId,
          widget.user.id,
        );
        setState(() => _isFollowing = false);
      } else {
        await firestoreService.followUser(widget.currentUserId, widget.user.id);

        // Create follow notification
        await firestoreService.createFollowNotification(
          widget.currentUserId,
          widget.user.id,
          currentUser.username,
          currentUser.profilePhotoUrl,
        );

        setState(() => _isFollowing = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: widget.user.profilePhotoUrl != null
              ? ClipOval(
                  child: Image.network(
                    widget.user.profilePhotoUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, color: Colors.white);
                    },
                  ),
                )
              : const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          widget.user.username,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.user.bio != null && widget.user.bio!.isNotEmpty)
              Text(
                widget.user.bio!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${widget.user.followersCount} followers',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${widget.user.followingCount} following',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: widget.isCurrentUser
            ? null
            : _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ElevatedButton(
                onPressed: _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: _isFollowing
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text(_isFollowing ? 'Following' : 'Follow'),
              ),
      ),
    );
  }
}
