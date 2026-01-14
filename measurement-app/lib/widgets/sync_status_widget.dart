import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../services/sync_service.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Usually we would listen to a stream from SyncService, but for now just poll or use connection state
      // Actually SyncService doesn't expose a stream yet, let's just make it a simple icon that assumes online/offline for now
      // Or better, let's create a Stream in SyncService later.
      // For now, let's rely on Connectivity from Provider if available, or just standard icon.
      // V2 Plan: "Non-intrusive Sync Status Indicator".
      // Let's make it a small rotating icon when syncing.
      future: Future.value(true),
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: StreamBuilder<bool>(
            stream: SyncService()
                .isSyncingStream, // We need to add this to SyncService
            initialData: false,
            builder: (context, snapshot) {
              final isSyncing = snapshot.data ?? false;
              if (isSyncing) {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black54,
                  ),
                );
              }
              return const Icon(
                FluentIcons.cloud_checkmark_24_regular,
                size: 24,
                color: Colors.black54,
              );
            },
          ),
        );
      },
    );
  }
}
