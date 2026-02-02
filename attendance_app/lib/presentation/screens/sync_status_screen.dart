import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui_components.dart';
import '../providers/app_provider.dart';

class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  late Future<Map<String, dynamic>> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = ref.read(syncServiceProvider).getSyncStatus();
  }

  void _refreshStatus() {
    setState(() {
      _statusFuture = ref.read(syncServiceProvider).getSyncStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SoftGradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshStatus();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle(title: 'Connection Status'),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh status',
                      onPressed: _refreshStatus,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ConnectionStatusCard(ref, onRefresh: _refreshStatus),
                const SizedBox(height: 24),
                const _SectionTitle(title: 'Synchronization'),
                const SizedBox(height: 12),
                _SyncStatusCard(ref, future: _statusFuture),
                const SizedBox(height: 16),
                _SyncActions(ref, onCompleted: _refreshStatus),
              ],
            ),
          ),
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
  const _ConnectionStatusCard(this.ref, {required this.onRefresh});

  final WidgetRef ref;
  final VoidCallback onRefresh;

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
              IconButton(
                icon: const Icon(Icons.sync),
                color: Colors.grey,
                tooltip: 'Recheck',
                onPressed: onRefresh,
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
  const _SyncStatusCard(this.ref, {required this.future});

  final WidgetRef ref;
  final Future<Map<String, dynamic>> future;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return _GlassCard(
      child: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final data =
              snapshot.data ??
              {
                'unsyncedCount': 0,
                'isOnline': false,
                'lastSyncTime': null,
                'lastError': null,
              };

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
                value: _formatDateTime(data['lastSyncTime']),
              ),
              if (data['lastError'] != null) ...[
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.error_outline,
                  label: 'Last Error',
                  value: data['lastError'],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _formatDateTime(dynamic dt) {
    DateTime? parsed;
    if (dt is DateTime) {
      parsed = dt;
    } else if (dt is String) {
      parsed = DateTime.tryParse(dt);
    }
    if (parsed == null) return 'Never';
    final safe = parsed.toLocal();
    return '${safe.year}-${safe.month.toString().padLeft(2, '0')}-${safe.day.toString().padLeft(2, '0')} '
        '${safe.hour.toString().padLeft(2, '0')}:${safe.minute.toString().padLeft(2, '0')}';
  }
}

/// =======================================================
/// SYNC ACTION BUTTONS
/// =======================================================
class _SyncActions extends ConsumerWidget {
  const _SyncActions(this.ref, {required this.onCompleted});

  final WidgetRef ref;
  final VoidCallback onCompleted;

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
              onCompleted();
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
              onCompleted();
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
