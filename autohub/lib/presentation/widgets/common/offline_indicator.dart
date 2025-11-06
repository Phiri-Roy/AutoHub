import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/sync_service.dart';

class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return isOnline.when(
      data: (online) {
        if (online) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange,
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'You\'re offline. Some features may be limited.',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              if (syncStatus.isSyncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    if (!syncStatus.isSyncing && syncStatus.error == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: syncStatus.error != null ? Colors.red : Colors.blue,
      child: Row(
        children: [
          if (syncStatus.isSyncing) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Syncing data...',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ] else if (syncStatus.error != null) ...[
            const Icon(Icons.error, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sync error: ${syncStatus.error}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 16),
              onPressed: () {
                ref.read(syncStatusProvider.notifier).setError(null);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class OfflineAwareWidget extends ConsumerWidget {
  final Widget child;
  final Widget? offlineChild;

  const OfflineAwareWidget({super.key, required this.child, this.offlineChild});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return isOnline.when(
      data: (online) {
        if (online) {
          return child;
        } else {
          return offlineChild ?? child;
        }
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}
