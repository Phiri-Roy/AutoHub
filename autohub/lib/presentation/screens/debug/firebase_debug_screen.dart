import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/firebase_config_service.dart';
import '../../../data/services/notification_service.dart';

class FirebaseDebugScreen extends ConsumerStatefulWidget {
  const FirebaseDebugScreen({super.key});

  @override
  ConsumerState<FirebaseDebugScreen> createState() =>
      _FirebaseDebugScreenState();
}

class _FirebaseDebugScreenState extends ConsumerState<FirebaseDebugScreen> {
  Map<String, dynamic>? _configInfo;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConfigInfo();
  }

  Future<void> _loadConfigInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final configInfo = FirebaseConfigService.getConfigInfo();
      setState(() {
        _configInfo = configInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnectivity() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FirebaseConfigService.testConnectivity();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result ? 'Connectivity test PASSED' : 'Connectivity test FAILED',
            ),
            backgroundColor: result ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testNotification() async {
    try {
      await NotificationService.sendEventNotification(
        eventId: 'test-event-123',
        eventName: 'Test Event',
        userId: 'test-user-123',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getFCMToken() async {
    try {
      final token = await NotificationService.getToken();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('FCM Token'),
            content: SelectableText(token ?? 'No token available'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get FCM token: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConfigInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: $_errorMessage'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadConfigInfo,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Firebase Configuration'),
                  _buildConfigCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Firebase Services'),
                  _buildServicesCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Test Actions'),
                  _buildTestActionsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Project ID', _configInfo?['projectId'] ?? 'N/A'),
            _buildInfoRow('App ID', _configInfo?['appId'] ?? 'N/A'),
            _buildInfoRow('Platform', _configInfo?['platform'] ?? 'N/A'),
            _buildInfoRow(
              'Initialized',
              _configInfo?['isInitialized']?.toString() ?? 'false',
            ),
            _buildInfoRow('Auth User', _configInfo?['authUser'] ?? 'None'),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceStatus(
              'Firestore',
              _configInfo?['firestoreEnabled'] ?? false,
            ),
            _buildServiceStatus(
              'Storage',
              _configInfo?['storageEnabled'] ?? false,
            ),
            _buildServiceStatus(
              'Messaging',
              _configInfo?['messagingEnabled'] ?? false,
            ),
            _buildServiceStatus(
              'Analytics',
              _configInfo?['analyticsEnabled'] ?? false,
            ),
            _buildServiceStatus(
              'Database',
              _configInfo?['databaseEnabled'] ?? false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testConnectivity,
                icon: const Icon(Icons.wifi),
                label: const Text('Test Connectivity'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testNotification,
                icon: const Icon(Icons.notifications),
                label: const Text('Send Test Notification'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _getFCMToken,
                icon: const Icon(Icons.token),
                label: const Text('Get FCM Token'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatus(String service, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(service),
        ],
      ),
    );
  }
}
