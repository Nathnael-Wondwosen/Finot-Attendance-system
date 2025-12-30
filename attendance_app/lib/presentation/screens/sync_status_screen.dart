import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../../core/sync_service.dart';
import '../providers/app_provider.dart';

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Status'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildConnectionStatusCard(ref),
            const SizedBox(height: 24),
            const Text(
              'Sync Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSyncInfoCard(ref),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Sync Now',
              onPressed: () async {
                final syncService = ref.read(syncServiceProvider);
                final result = await syncService.performFullSync();

                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sync completed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sync failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Upload Pending Attendance',
              isOutlined: true,
              onPressed: () async {
                final syncService = ref.read(syncServiceProvider);
                final result = await syncService.uploadAttendanceData();

                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attendance uploaded successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Upload failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<bool>(
          future: ref.read(syncServiceProvider).isOnline(),
          builder: (context, snapshot) {
            final isConnected = snapshot.data ?? false;
            final status = isConnected ? 'Connected' : 'Disconnected';
            final color = isConnected ? Colors.green : Colors.red;

            return Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                Icon(isConnected ? Icons.wifi : Icons.wifi_off, color: color),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSyncInfoCard(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: ref.read(syncServiceProvider).getSyncStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data =
                snapshot.data ??
                {
                  'unsyncedCount': 0,
                  'isOnline': false,
                  'lastSyncTime': DateTime.now(),
                };

            final unsyncedCount = data['unsyncedCount'] ?? 0;
            final isOnline = data['isOnline'] ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Pending Sync',
                  unsyncedCount.toString(),
                  Icons.sync,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Connection',
                  isOnline ? 'Online' : 'Offline',
                  isOnline ? Icons.cloud_done : Icons.cloud_off,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Last Sync',
                  data['lastSyncTime']?.toString() ?? 'Never',
                  Icons.access_time,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
