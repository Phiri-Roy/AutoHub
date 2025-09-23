import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/app_providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
      ),
      body: leaderboardAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No winners yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Participate in events to climb the leaderboard!',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(leaderboardProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final rank = index + 1;
                
                return _buildLeaderboardItem(context, user, rank);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading leaderboard',
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
                  ref.invalidate(leaderboardProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, user, int rank) {
    Color rankColor;
    IconData rankIcon;
    
    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = Colors.grey[400]!;
        rankIcon = Icons.emoji_events;
        break;
      case 3:
        rankColor = Colors.brown[400]!;
        rankIcon = Icons.emoji_events;
        break;
      default:
        rankColor = Theme.of(context).colorScheme.primary;
        rankIcon = Icons.person;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: rank <= 3
                ? Icon(
                    rankIcon,
                    color: rankColor,
                    size: 24,
                  )
                : Text(
                    '$rank',
                    style: TextStyle(
                      color: rankColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
          ),
        ),
        title: Text(
          user.username,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${user.totalWins} wins',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: user.profilePhotoUrl != null
            ? CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(user.profilePhotoUrl!),
              )
            : CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
