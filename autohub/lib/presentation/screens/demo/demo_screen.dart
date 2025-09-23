import 'package:flutter/material.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoHub - Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _FeedDemo(),
          _EventsDemo(),
          _LeaderboardDemo(),
          _ProfileDemo(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _FeedDemo extends StatelessWidget {
  const _FeedDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDemoCard(
              context,
              'Welcome to AutoHub!',
              'This is a demo of the car enthusiast community app. The full version includes Firebase integration for real-time data.',
              Icons.directions_car,
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              context,
              'Community Feed',
              'Users can create posts with images, like and comment on posts, and share their car experiences.',
              Icons.feed,
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              context,
              'Car Showcase',
              'Submit your cars to events and let the community vote for their favorites!',
              Icons.emoji_events,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Post - Requires Firebase setup')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDemoCard(BuildContext context, String title, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsDemo extends StatelessWidget {
  const _EventsDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEventCard(
              context,
              'Car Meet & Greet',
              'Downtown Plaza',
              '2024-10-15',
              '18:00',
              '25 attendees',
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              context,
              'Track Day',
              'Speedway Circuit',
              '2024-10-20',
              '09:00',
              '12 attendees',
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              context,
              'Show & Shine',
              'City Park',
              '2024-10-25',
              '14:00',
              '8 attendees',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Event - Requires Firebase setup')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, String title, String location, String date, String time, String attendees) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text(location, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text('$date at $time', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text(attendees, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardDemo extends StatelessWidget {
  const _LeaderboardDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLeaderboardItem(context, 'SpeedDemon', '5 wins', 1, Colors.amber),
          _buildLeaderboardItem(context, 'TurboRider', '3 wins', 2, Colors.grey),
          _buildLeaderboardItem(context, 'CarLover99', '2 wins', 3, Colors.brown),
          _buildLeaderboardItem(context, 'AutoFan', '1 win', 4, Theme.of(context).colorScheme.primary),
          _buildLeaderboardItem(context, 'RacingPro', '1 win', 5, Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, String username, String wins, int rank, Color rankColor) {
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
                ? Icon(Icons.emoji_events, color: rankColor, size: 24)
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
        title: Text(username),
        subtitle: Text(wins),
        trailing: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _ProfileDemo extends StatelessWidget {
  const _ProfileDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      'U',
                      style: TextStyle(
                        fontSize: 50,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Demo User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'demo@autohub.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(context, 'Cars', '3', Icons.directions_car),
                      _buildStatItem(context, 'Wins', '1', Icons.emoji_events),
                      _buildStatItem(context, 'Member', '1', Icons.calendar_today),
                    ],
                  ),
                ],
              ),
            ),
            // Profile options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileOption(context, 'Edit Profile', 'Update your information', Icons.edit),
                  const SizedBox(height: 8),
                  _buildProfileOption(context, 'My Garage', 'Manage your cars', Icons.garage),
                  const SizedBox(height: 8),
                  _buildProfileOption(context, 'Settings', 'App preferences', Icons.settings),
                  const SizedBox(height: 8),
                  _buildProfileOption(context, 'Help & Support', 'Get help', Icons.help_outline),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
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
    );
  }

  Widget _buildProfileOption(BuildContext context, String title, String subtitle, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title - Requires Firebase setup')),
          );
        },
      ),
    );
  }
}

