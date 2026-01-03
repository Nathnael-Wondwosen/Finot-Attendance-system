import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_provider.dart';
import 'sidebar_drawer.dart';
import 'dashboard_screen.dart';
import 'class_selection_screen.dart';
import 'attendance_summary_screen.dart';
import 'settings_screen.dart';

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Connection Status'),
            const SizedBox(height: 12),
            _ConnectionStatusCard(ref),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Synchronization'),
            const SizedBox(height: 12),
            _SyncStatusCard(ref),
            const Spacer(),
            _SyncActions(ref),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// SECTION TITLE
/// =======================================================
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}

/// =======================================================
/// CONNECTION STATUS CARD
/// =======================================================
class _ConnectionStatusCard extends ConsumerWidget {
  const _ConnectionStatusCard(this.ref);

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return _GlassCard(
      child: FutureBuilder<bool>(
        future: ref.read(syncServiceProvider).isOnline(),
        builder: (context, snapshot) {
          final connected = snapshot.data ?? false;

          return Row(
            children: [
              _StatusDot(color: connected ? Colors.green : Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  connected ? 'Connected to Network' : 'No Internet Connection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: connected ? Colors.green : Colors.red,
                  ),
                ),
              ),
              Icon(
                connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                color: connected ? Colors.green : Colors.red,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// =======================================================
/// SYNC STATUS CARD
/// =======================================================
class _SyncStatusCard extends ConsumerWidget {
  const _SyncStatusCard(this.ref);

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return _GlassCard(
      child: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(syncServiceProvider).getSyncStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final data =
              snapshot.data ??
              {'unsyncedCount': 0, 'isOnline': false, 'lastSyncTime': null};

          return Column(
            children: [
              _InfoRow(
                icon: Icons.sync_rounded,
                label: 'Pending Records',
                value: data['unsyncedCount'].toString(),
              ),
              const Divider(height: 24),
              _InfoRow(
                icon:
                    data['isOnline']
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_off_rounded,
                label: 'Cloud Status',
                value: data['isOnline'] ? 'Online' : 'Offline',
              ),
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Last Sync',
                value:
                    data['lastSyncTime'] != null
                        ? data['lastSyncTime'].toString()
                        : 'Never',
              ),
            ],
          );
        },
      ),
    );
  }
}

/// =======================================================
/// SYNC ACTION BUTTONS
/// =======================================================
class _SyncActions extends ConsumerWidget {
  const _SyncActions(this.ref);

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.sync),
            label: const Text('Sync Now'),
            onPressed: () async {
              final ok = await ref.read(syncServiceProvider).performFullSync();

              _showResult(
                context,
                ok,
                successMessage: 'Synchronization completed successfully',
                failureMessage: 'Synchronization failed',
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Upload Pending Attendance'),
            onPressed: () async {
              final ok =
                  await ref.read(syncServiceProvider).uploadAttendanceData();

              _showResult(
                context,
                ok,
                successMessage: 'Attendance uploaded successfully',
                failureMessage: 'Upload failed',
              );
            },
          ),
        ),
      ],
    );
  }

  void _showResult(
    BuildContext context,
    bool success, {
    required String successMessage,
    required String failureMessage,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : failureMessage),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}

/// =======================================================
/// GLASS CARD (REUSABLE)
/// =======================================================
class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// =======================================================
/// INFO ROW
/// =======================================================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// =======================================================
/// STATUS DOT
/// =======================================================
class _StatusDot extends StatelessWidget {
  final Color color;

  const _StatusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
